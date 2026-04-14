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
        local target = (getgenv().followTarget and getgenv().followTarget.Character) and getgenv().followTarget or getgenv().Utils:FindNearestAlivePlayer(nil)
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
    getgenv().ReachSettingsFrame.Visible = not getgenv().ReachSettingsFrame.Visible
end)

getgenv().ReachVisualBtn.MouseButton1Click:Connect(function()
    getgenv().reachVisual = not getgenv().reachVisual
    getgenv().ReachVisualBtn.Text = "Visual: " .. (getgenv().reachVisual and "ON" or "OFF")
    getgenv().ReachVisualBtn.BackgroundColor3 = getgenv().reachVisual and getgenv().COL_ON or getgenv().COL_OFF
    if reachIndicator then reachIndicator.Transparency = getgenv().reachVisual and 0.3 or 1 end
end)

getgenv().enableReach = enableReach
getgenv().disableReach = disableReach
