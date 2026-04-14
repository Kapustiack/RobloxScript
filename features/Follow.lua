local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- [[ RAW FOLLOW LOGIC - Migrated 1:1 from rb.lua ]]
-- Logic (463 - 591), UI (2440 - 2476, 2558 - 2611)

local function stopFollow()
    getgenv().followEnabled = false
    getgenv().followTarget  = nil
    if getgenv().followConnection then getgenv().followConnection:Disconnect(); getgenv().followConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
    getgenv().FollowButton.Text = "Follow: OFF"
    getgenv().FollowButton.BackgroundColor3 = getgenv().COL_OFF
end

local function startFollow(targetPlayer)
    if not getgenv().scriptEnabled or not getgenv().followEnabled then return end
    getgenv().followTarget = targetPlayer
    if getgenv().followConnection then getgenv().followConnection:Disconnect(); getgenv().followConnection = nil end

    getgenv().followConnection = RunService.RenderStepped:Connect(function(dt)
        if not getgenv().followEnabled or not getgenv().followTarget or not getgenv().followTarget.Character then return end
        local targetHRP = getgenv().followTarget.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local char = LocalPlayer.Character
        if not char then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.AutoRotate then hum.AutoRotate = false end

        local now = os.clock()
        local inClickOrLinger = getgenv().clickCheckEnabled and (getgenv().leftMouseClicked or now < getgenv().clickLingerUntil)
        if inClickOrLinger then
            myHRP.CFrame = targetHRP.CFrame
            return
        end

        local targetVel   = targetHRP.AssemblyLinearVelocity
        local targetSpeed = targetVel.Magnitude
        local desiredCF   = targetHRP.CFrame * CFrame.new(0, getgenv().followHeight, getgenv().followDistance)
        local desiredPos  = desiredCF.Position
        local toTarget    = desiredPos - myHRP.Position
        local movingAway  = targetSpeed > 3 and toTarget.Magnitude > 0.1
                            and targetVel:Dot(toTarget.Unit) > 2
        if movingAway then
            local pred = math.min(targetSpeed * 0.09, 5)
            desiredPos = desiredPos + targetVel.Unit * pred
            desiredCF  = CFrame.new(desiredPos, desiredPos - targetHRP.CFrame.LookVector)
        end
        local deltaMag = (desiredPos - myHRP.Position).Magnitude
        if deltaMag > 40 then myHRP.CFrame = desiredCF; return end
        local rate  = movingAway and 14 or 8
        local alpha = 1 - math.exp(-rate * dt)
        alpha = math.clamp(alpha + deltaMag * 0.012, alpha, 0.98)
        myHRP.CFrame = myHRP.CFrame:Lerp(desiredCF, alpha)
    end)
end

local function pushHistory(player)
    if player == nil then return end
    for i = #getgenv().targetHistory, 1, -1 do
        if getgenv().targetHistory[i] == player then table.remove(getgenv().targetHistory, i) end
    end
    table.insert(getgenv().targetHistory, player)
    while #getgenv().targetHistory > 2 do table.remove(getgenv().targetHistory, 1) end
end

local function switchTarget()
    if not getgenv().followEnabled then return end
    local candidates = {}
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p ~= getgenv().followTarget and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local d = (hrp.Position - myChar.HumanoidRootPart.Position).Magnitude
                table.insert(candidates, {player = p, dist = d})
            end
        end
    end

    if #candidates == 0 then return end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)

    local inHistory = {}
    for _, p in ipairs(getgenv().targetHistory) do inHistory[p] = true end

    local chosen = nil
    for _, c in ipairs(candidates) do
        if not inHistory[c.player] then chosen = c.player; break end
    end
    if chosen == nil then chosen = candidates[1].player end

    pushHistory(getgenv().followTarget)
    getgenv().followTarget = chosen
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[Follow] Switched to " .. chosen.Name;
            Color = Color3.fromRGB(80, 200, 255);
            Font = Enum.Font.GothamBold;
        })
    end)
end

local function toggleFollow()
    if not getgenv().scriptEnabled then return end
    if getgenv().followEnabled then
        stopFollow()
    else
        local nearest = getgenv().Utils:FindNearestAlivePlayer(nil)
        if nearest then
            getgenv().followEnabled = true
            getgenv().FollowButton.Text = "Follow: ON"
            getgenv().FollowButton.BackgroundColor3 = getgenv().COL_ON
            startFollow(nearest)
        end
    end
end

getgenv().FollowButton.MouseButton1Click:Connect(toggleFollow)

getgenv().FollowButton.MouseButton2Click:Connect(function()
    getgenv().FollowSettingsFrame.Visible = not getgenv().FollowSettingsFrame.Visible
    getgenv().ESPSettingsFrame.Visible = false
    getgenv().SpeedSettingsFrame.Visible = false
    getgenv().FOVSettingsFrame.Visible = false
end)

getgenv().ClickCheckBtn.MouseButton1Click:Connect(function()
    getgenv().clickCheckEnabled = not getgenv().clickCheckEnabled
    getgenv().ClickCheckBtn.Text = "Click Check: " .. (getgenv().clickCheckEnabled and "ON" or "OFF")
    getgenv().ClickCheckBtn.BackgroundColor3 = getgenv().clickCheckEnabled and getgenv().COL_ON or getgenv().COL_OFF
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

getgenv().SwitchTargetBtn.MouseButton1Click:Connect(switchTarget)

getgenv().stopFollow = stopFollow
getgenv().startFollow = startFollow
getgenv().pushHistory = pushHistory
getgenv().switchTarget = switchTarget
getgenv().toggleFollow = toggleFollow
