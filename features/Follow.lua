local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- [[ RAW FOLLOW LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 465 - 629

local function stopFollow()
    getgenv().followEnabled = false
    getgenv().followTarget = nil
    if getgenv().followConnection then getgenv().followConnection:Disconnect(); getgenv().followConnection = nil end
    local char = LocalPlayer.Character
    if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = true end end
    getgenv().FollowButton.Text = "Follow: OFF"; getgenv().FollowButton.BackgroundColor3 = getgenv().COL_OFF
end

local function startFollow(targetPlayer)
    if not getgenv().scriptEnabled or not getgenv().followEnabled then return end
    getgenv().followTarget = targetPlayer
    if getgenv().followConnection then getgenv().followConnection:Disconnect(); getgenv().followConnection = nil end

    getgenv().followConnection = RunService.RenderStepped:Connect(function(dt)
        if not getgenv().followEnabled or not getgenv().followTarget or not getgenv().followTarget.Character then return end
        local targetHRP = getgenv().followTarget.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character; local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not targetHRP or not myHRP then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if hum and hum.AutoRotate then hum.AutoRotate = false end

        local now = os.clock()
        if getgenv().clickCheckEnabled and (getgenv().leftMouseClicked or now < getgenv().clickLingerUntil) then
            myHRP.CFrame = targetHRP.CFrame; return
        end

        local targetVel = targetHRP.AssemblyLinearVelocity
        local targetSpeed = targetVel.Magnitude
        local desiredCF = targetHRP.CFrame * CFrame.new(0, getgenv().followHeight, getgenv().followDistance)
        local desiredPos = desiredCF.Position; local toTarget = desiredPos - myHRP.Position
        local movingAway = targetSpeed > 3 and toTarget.Magnitude > 0.1 and targetVel:Dot(toTarget.Unit) > 2
        if movingAway then
            local pred = math.min(targetSpeed * 0.09, 5)
            desiredPos = desiredPos + targetVel.Unit * pred
            desiredCF = CFrame.new(desiredPos, desiredPos - targetHRP.CFrame.LookVector)
        end
        local deltaMag = (desiredPos - myHRP.Position).Magnitude
        if deltaMag > 40 then myHRP.CFrame = desiredCF; return end
        local rate = movingAway and 14 or 8
        local alpha = math.clamp((1 - math.exp(-rate * dt)) + deltaMag * 0.012, 0, 0.98)
        myHRP.CFrame = myHRP.CFrame:Lerp(desiredCF, alpha)
    end)
end

getgenv().FollowButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().followEnabled then stopFollow()
    else
        local nearest = getgenv().Utils:FindNearestAlivePlayer(nil)
        if nearest then
            getgenv().followEnabled = true; getgenv().FollowButton.Text = "Follow: ON"; getgenv().FollowButton.BackgroundColor3 = getgenv().COL_ON
            startFollow(nearest)
        end
    end
end)

getgenv().FollowButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().FollowSettingsFrame) end
end)

getgenv().DeathCheckBtn.MouseButton1Click:Connect(function()
    getgenv().deathCheckEnabled = not getgenv().deathCheckEnabled
    getgenv().DeathCheckBtn.Text = "Death Check: " .. (getgenv().deathCheckEnabled and "ON" or "OFF")
    getgenv().DeathCheckBtn.BackgroundColor3 = getgenv().deathCheckEnabled and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().AutoSwitchBtn.MouseButton1Click:Connect(function()
    getgenv().autoSwitchEnabled = not getgenv().autoSwitchEnabled
    getgenv().AutoSwitchBtn.Text = "Auto Switch: " .. (getgenv().autoSwitchEnabled and "ON" or "OFF")
    getgenv().AutoSwitchBtn.BackgroundColor3 = getgenv().autoSwitchEnabled and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().startFollow = startFollow
getgenv().stopFollow = stopFollow
