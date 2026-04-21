local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- [[ RAW REACH LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1729 - 1807

local reachIndicator = nil

local function hookReachTool()
    if getgenv().reachActivatedConn then getgenv().reachActivatedConn:Disconnect(); getgenv().reachActivatedConn = nil end
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end

    getgenv().reachActivatedConn = tool.Activated:Connect(function()
        if not getgenv().reachEnabled or not getgenv().scriptEnabled then return end
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
end

local function enableReach()
    if reachIndicator then reachIndicator:Destroy() end
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    reachIndicator = Instance.new("SphereHandleAdornment")
    reachIndicator.Radius = 0.5; reachIndicator.Color3 = Color3.fromRGB(60, 220, 120); reachIndicator.AlwaysOnTop = true; reachIndicator.Transparency = 0.3; reachIndicator.ZIndex = 5; reachIndicator.Adornee = hrp; reachIndicator.CFrame = CFrame.new(0, 0, -getgenv().reachDistance); reachIndicator.Parent = Workspace

    hookReachTool()
    if getgenv().reachToolWatcher then getgenv().reachToolWatcher:Disconnect() end
    getgenv().reachToolWatcher = char.ChildAdded:Connect(function(child) if child:IsA("Tool") and getgenv().reachEnabled then task.wait(); hookReachTool() end end)
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

getgenv().ReachButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().ReachSettingsFrame) end
end)

getgenv().ReachVisualBtn.MouseButton1Click:Connect(function()
    getgenv().reachVisual = not getgenv().reachVisual
    getgenv().ReachVisualBtn.Text = "Visual: " .. (getgenv().reachVisual and "ON" or "OFF")
    getgenv().ReachVisualBtn.BackgroundColor3 = getgenv().reachVisual and getgenv().COL_ON or getgenv().COL_OFF
    if reachIndicator then reachIndicator.Transparency = getgenv().reachVisual and 0.3 or 1 end
end)

getgenv().enableReach = enableReach
getgenv().disableReach = disableReach

-- BUG 3 FIX: Reach indicator RenderStepped loop was completely missing.
-- Original rb.lua (lines 2492-2528): reattaches adornee every frame (survives respawn),
-- scales radius dynamically with reachDistance, and color-codes the sphere.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().reachRenderConn = RunService.RenderStepped:Connect(function()
    if not getgenv().reachEnabled or not reachIndicator then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Reattach adornee every frame — survives respawn/character changes
    if reachIndicator.Adornee ~= hrp then reachIndicator.Adornee = hrp end
    if reachIndicator.Parent ~= workspace then reachIndicator.Parent = workspace end

    -- Scale radius with reach distance for visual clarity
    reachIndicator.Radius = math.max(0.4, getgenv().reachDistance * 0.06)
    reachIndicator.CFrame = CFrame.new(0, 0, -getgenv().reachDistance)

    -- Hide if visual toggled off
    reachIndicator.Transparency = getgenv().reachVisual and 0.3 or 1

    -- Color: red = enemy in reach, orange = close, green = far
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
