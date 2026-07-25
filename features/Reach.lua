local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local reachIndicator = nil

-- Look for a game-authored Range/Reach/Distance attribute (or matching
-- NumberValue child) on the equipped tool so lunges never overshoot farther
-- than the tool could ever legitimately hit. Returns nil if the game doesn't
-- expose one, in which case the manual reachDistance slider is used as-is.
local ATTR_RANGE_NAMES = {"Range", "Reach", "Distance"}
local function detectToolRange(tool)
    for _, name in ipairs(ATTR_RANGE_NAMES) do
        local attr = tool:GetAttribute(name)
        if type(attr) == "number" and attr > 0 then return attr end
    end
    for _, name in ipairs(ATTR_RANGE_NAMES) do
        local child = tool:FindFirstChild(name)
        if child and child:IsA("NumberValue") and child.Value > 0 then return child.Value end
    end
    return nil
end

-- Same idea for a Cooldown/Rate/AttackSpeed attribute. If the game doesn't
-- expose one, we fall back to learning the tool's real activation cadence
-- from observed Activated gaps, so we never lunge faster than the tool could
-- actually fire.
local ATTR_COOLDOWN_NAMES = {"Cooldown", "Rate", "AttackSpeed"}
local function detectToolCooldown(tool)
    for _, name in ipairs(ATTR_COOLDOWN_NAMES) do
        local attr = tool:GetAttribute(name)
        if type(attr) == "number" and attr > 0 then return attr end
    end
    for _, name in ipairs(ATTR_COOLDOWN_NAMES) do
        local child = tool:FindFirstChild(name)
        if child and child:IsA("NumberValue") and child.Value > 0 then return child.Value end
    end
    return nil
end

local function hookReachTool()
    if getgenv().reachActivatedConn then getgenv().reachActivatedConn:Disconnect(); getgenv().reachActivatedConn = nil end
    local char = LocalPlayer.Character; if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return false end

    local detectedRange = detectToolRange(tool)
    local detectedCooldown = detectToolCooldown(tool) or 0.1 -- sane floor if nothing is exposed/learned yet
    local lastActivationAt = 0
    local observedGap = nil
    local lastActivationTick = nil

    getgenv().reachActivatedConn = tool.Activated:Connect(function()
        if not getgenv().reachEnabled or not getgenv().scriptEnabled then return end

        local nowTick = os.clock()
        if lastActivationTick then
            local gap = nowTick - lastActivationTick
            if gap > 0.02 then observedGap = observedGap and math.min(observedGap, gap) or gap end
        end
        lastActivationTick = nowTick

        local effectiveCooldown = detectedCooldown
        if observedGap then effectiveCooldown = math.max(effectiveCooldown * 0.5, observedGap * 0.9) end
        if nowTick - lastActivationAt < effectiveCooldown then return end
        lastActivationAt = nowTick

        local target
        if getgenv().followTarget and getgenv().followTarget.Character then
            target = getgenv().followTarget
        elseif getgenv().Utils and typeof(getgenv().Utils.FindNearestAlivePlayer) == "function" then
            target = getgenv().Utils:FindNearestAlivePlayer(nil)
        end
        if not target or not target.Character then return end
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not targetHRP or not myHRP then return end

        -- Never lunge at something wildly farther than the tool's real range.
        local maxDist = detectedRange and math.min(getgenv().reachDistance, detectedRange) or getgenv().reachDistance
        local dist = (targetHRP.Position - myHRP.Position).Magnitude
        if dist > maxDist * 2.5 then return end

        local savedCF = myHRP.CFrame
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.2)
        if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
        if reachIndicator then reachIndicator.Color3 = Color3.fromRGB(255, 140, 0) end

        task.defer(function()
            if myHRP and myHRP.Parent then myHRP.CFrame = savedCF end
            if reachIndicator then reachIndicator.Color3 = Color3.fromRGB(60, 220, 120) end
            if not getgenv().hitboxEnabled and getgenv().removeHitboxExpansion then getgenv().removeHitboxExpansion() end
        end)
    end)
    return true
end

local function enableReach()
    if reachIndicator then reachIndicator:Destroy() end
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    reachIndicator = Instance.new("SphereHandleAdornment")
    reachIndicator.Radius = 0.5; reachIndicator.Color3 = Color3.fromRGB(60, 220, 120); reachIndicator.AlwaysOnTop = true; reachIndicator.Transparency = 0.3; reachIndicator.ZIndex = 5; reachIndicator.Adornee = hrp; reachIndicator.CFrame = CFrame.new(0, 0, -getgenv().reachDistance); reachIndicator.Parent = Workspace

    -- Give explicit feedback instead of silently no-op'ing when Reach is
    -- turned on but there's nothing to hook yet (no tool equipped).
    local hooked = hookReachTool()
    if not hooked and getgenv().Utils then
        getgenv().Utils:Notify("Reach", "No tool equipped — will activate once you equip one.", Color3.fromRGB(255, 160, 0))
    end
    if getgenv().reachToolWatcher then getgenv().reachToolWatcher:Disconnect() end
    getgenv().reachToolWatcher = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and getgenv().reachEnabled then
            task.wait()
            if hookReachTool() and getgenv().Utils then
                getgenv().Utils:Notify("Reach", "Tool hooked: " .. child.Name, Color3.fromRGB(80, 200, 120))
            end
        end
    end)
end

local function disableReach()
    getgenv().reachEnabled = false
    if reachIndicator then reachIndicator:Destroy(); reachIndicator = nil end
    if getgenv().reachActivatedConn then getgenv().reachActivatedConn:Disconnect(); getgenv().reachActivatedConn = nil end
    if getgenv().reachToolWatcher then getgenv().reachToolWatcher:Disconnect(); getgenv().reachToolWatcher = nil end
    if getgenv().reachRenderConn then getgenv().reachRenderConn:Disconnect(); getgenv().reachRenderConn = nil end
end

getgenv().ReachButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().reachEnabled = not getgenv().reachEnabled
    if getgenv().reachEnabled then
        getgenv().ReachButton.Text = "Reach: ON"; getgenv().ReachButton.BackgroundColor3 = getgenv().COL_ON
        enableReach()
    else
        getgenv().ReachButton.Text = "Reach: OFF"; getgenv().ReachButton.BackgroundColor3 = getgenv().COL_OFF
        disableReach()
    end
end)

if getgenv().BindPanelButton and getgenv().ReachSettingsFrame then
    getgenv().BindPanelButton(getgenv().ReachButton, getgenv().ReachSettingsFrame)
end

getgenv().ReachVisualBtn.MouseButton1Click:Connect(function()
    getgenv().reachVisual = not getgenv().reachVisual
    getgenv().ReachVisualBtn.Text = "Visual: " .. (getgenv().reachVisual and "ON" or "OFF")
    getgenv().ReachVisualBtn.BackgroundColor3 = getgenv().reachVisual and getgenv().COL_ON or getgenv().COL_OFF
    if reachIndicator then reachIndicator.Transparency = getgenv().reachVisual and 0.3 or 1 end
end)

getgenv().enableReach = enableReach
getgenv().disableReach = disableReach

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().reachRenderConn = RunService.RenderStepped:Connect(function()
    if not getgenv().reachEnabled or not reachIndicator then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if reachIndicator.Adornee ~= hrp then reachIndicator.Adornee = hrp end
    if reachIndicator.Parent ~= workspace then reachIndicator.Parent = workspace end

    reachIndicator.Radius = math.max(0.4, getgenv().reachDistance * 0.06)
    reachIndicator.CFrame = CFrame.new(0, 0, -getgenv().reachDistance)

    reachIndicator.Transparency = getgenv().reachVisual and 0.3 or 1

    if getgenv().reachVisual then
        local nearest = getgenv().Utils and getgenv().Utils:FindNearestAlivePlayer(nil)
        if nearest and nearest.Character then
            local nhrp = nearest.Character:FindFirstChild("HumanoidRootPart")
            if nhrp then
                local d = (nhrp.Position - hrp.Position).Magnitude
                if d <= getgenv().reachDistance then
                    reachIndicator.Color3 = Color3.fromRGB(220, 60, 60)
                elseif d <= getgenv().reachDistance * 2 then
                    reachIndicator.Color3 = Color3.fromRGB(255, 160, 0)
                else
                    reachIndicator.Color3 = Color3.fromRGB(60, 220, 120)
                end
            end
        else
            reachIndicator.Color3 = Color3.fromRGB(60, 220, 120)
        end
    end
end)
