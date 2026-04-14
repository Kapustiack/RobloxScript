local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- [[ RAW REACH LOGIC - Migrated 1:1 from rb.lua ]]
-- Logic (1729 - 1807), UI (2339 - 2374), RenderStepped (2491 - 2528)

local function hookReachTool()
    if getgenv().reachActivatedConn then getgenv().reachActivatedConn:Disconnect(); getgenv().reachActivatedConn = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    getgenv().reachActivatedConn = tool.Activated:Connect(function()
        if not getgenv().reachEnabled or not getgenv().scriptEnabled then return end
        local target = (getgenv().followTarget and getgenv().followTarget.Character) and getgenv().followTarget or nil
        if not target then target = getgenv().Utils:FindNearestAlivePlayer(nil) end
        if not target then return end
        local targetChar = target.Character or target
        if not targetChar then return end
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local savedCF = myHRP.CFrame
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.2)
        if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end

        if getgenv().reachIndicator then getgenv().reachIndicator.Color3 = Color3.fromRGB(255, 140, 0) end

        task.defer(function()
            if myHRP and myHRP.Parent then myHRP.CFrame = savedCF end
            if getgenv().reachIndicator then getgenv().reachIndicator.Color3 = Color3.fromRGB(60, 220, 120) end
            if not getgenv().hitboxEnabled and getgenv().removeHitboxExpansion then getgenv().removeHitboxExpansion() end
        end)
    end)
end

local function enableReach()
    if not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if getgenv().reachIndicator then getgenv().reachIndicator:Destroy() end
    getgenv().reachIndicator = Instance.new("SphereHandleAdornment")
    getgenv().reachIndicator.Radius = 0.5
    getgenv().reachIndicator.Color3 = Color3.fromRGB(60, 220, 120)
    getgenv().reachIndicator.AlwaysOnTop = true
    getgenv().reachIndicator.Transparency = 0.3
    getgenv().reachIndicator.ZIndex = 5
    getgenv().reachIndicator.Adornee = hrp
    getgenv().reachIndicator.CFrame = CFrame.new(0, 0, -getgenv().reachDistance)
    getgenv().reachIndicator.Parent = getgenv().reachVisual and workspace or nil

    hookReachTool()

    if getgenv().reachToolWatcher then getgenv().reachToolWatcher:Disconnect() end
    getgenv().reachToolWatcher = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and getgenv().reachEnabled then
            task.wait()
            hookReachTool()
        end
    end)
end

local function disableReach()
    getgenv().reachEnabled = false
    if getgenv().reachIndicator then getgenv().reachIndicator:Destroy(); getgenv().reachIndicator = nil end
    if getgenv().reachActivatedConn then getgenv().reachActivatedConn:Disconnect(); getgenv().reachActivatedConn = nil end
    if getgenv().reachToolWatcher then getgenv().reachToolWatcher:Disconnect(); getgenv().reachToolWatcher = nil end
end

getgenv().ReachButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().reachEnabled = not getgenv().reachEnabled
    if getgenv().reachEnabled then
        enableReach()
        getgenv().ReachButton.Text = "Reach: ON"
        getgenv().ReachButton.BackgroundColor3 = getgenv().COL_ON
    else
        disableReach()
        getgenv().ReachButton.Text = "Reach: OFF"
        getgenv().ReachButton.BackgroundColor3 = getgenv().COL_OFF
    end
end)

getgenv().ReachButton.MouseButton2Click:Connect(function()
    getgenv().ReachSettingsFrame.Visible = not getgenv().ReachSettingsFrame.Visible
    getgenv().ESPSettingsFrame.Visible = false
    getgenv().SpeedSettingsFrame.Visible = false
    getgenv().FOVSettingsFrame.Visible = false
    getgenv().FollowSettingsFrame.Visible = false
end)

getgenv().ReachVisualBtn.MouseButton1Click:Connect(function()
    getgenv().reachVisual = not getgenv().reachVisual
    getgenv().ReachVisualBtn.Text = "Visual: " .. (getgenv().reachVisual and "ON" or "OFF")
    getgenv().ReachVisualBtn.BackgroundColor3 = getgenv().reachVisual and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().reachIndicator then getgenv().reachIndicator.Parent = getgenv().reachVisual and workspace or nil end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().reachEnabled or not getgenv().reachVisual or not getgenv().reachIndicator then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if getgenv().reachIndicator.Adornee ~= hrp then getgenv().reachIndicator.Adornee = hrp end
    if getgenv().reachIndicator.Parent ~= workspace then getgenv().reachIndicator.Parent = workspace end
    getgenv().reachIndicator.Radius = math.max(0.4, getgenv().reachDistance * 0.06)
    getgenv().reachIndicator.CFrame = CFrame.new(0, 0, -getgenv().reachDistance)
    
    local nearest = getgenv().Utils:FindNearestAlivePlayer(nil)
    if nearest and nearest.Character then
        local nhrp = nearest.Character:FindFirstChild("HumanoidRootPart")
        if nhrp then
            local d = (nhrp.Position - hrp.Position).Magnitude
            if d <= getgenv().reachDistance then getgenv().reachIndicator.Color3 = Color3.fromRGB(220, 60, 60)
            elseif d <= getgenv().reachDistance * 2 then getgenv().reachIndicator.Color3 = Color3.fromRGB(255, 160, 0)
            else getgenv().reachIndicator.Color3 = Color3.fromRGB(60, 220, 120) end
        end
    else getgenv().reachIndicator.Color3 = Color3.fromRGB(60, 220, 120) end
end)

getgenv().hookReachTool = hookReachTool
getgenv().enableReach = enableReach
getgenv().disableReach = disableReach
