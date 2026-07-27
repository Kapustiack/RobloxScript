local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local PathfindingService = game:GetService("PathfindingService")

-- Pathfinding-around-obstacles state. Recomputed only when line-of-sight to
-- the desired follow position is actually blocked, and throttled, since
-- Path:ComputeAsync is relatively expensive to call every frame.
local pathWaypoints = nil
local pathIndex = 1
local pathComputing = false
local lastPathAttempt = 0
local lastObstructionCheck = 0
local isObstructed = false

local function checkObstruction(myHRP, targetPos, char, targetChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, targetChar}
    local dir = targetPos - myHRP.Position
    local dist = dir.Magnitude
    if dist < 1 then return false end
    local result = workspace:Raycast(myHRP.Position, dir.Unit * dist, params)
    return result ~= nil
end

local function computeFollowPath(myHRP, targetPos)
    if pathComputing then return end
    pathComputing = true
    task.spawn(function()
        local ok, path = pcall(function()
            local p = PathfindingService:CreatePath({
                AgentRadius = 2.5, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true,
            })
            p:ComputeAsync(myHRP.Position, targetPos)
            return p
        end)
        if ok and path and path.Status == Enum.PathStatus.Success then
            pathWaypoints = path:GetWaypoints()
            pathIndex = 2 -- index 1 is our own starting position
        else
            pathWaypoints = nil
        end
        pathComputing = false
    end)
end


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

    local lastTargetVel = nil
    pathWaypoints = nil
    isObstructed = false

    getgenv().followConnection = RunService.RenderStepped:Connect(function(dt)
        if not getgenv().followEnabled or not getgenv().followTarget or not getgenv().followTarget.Character then return end
        local targetChar = getgenv().followTarget.Character
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character; local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not targetHRP or not myHRP then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if hum and hum.AutoRotate then hum.AutoRotate = false end

        local now = os.clock()
        if getgenv().clickCheckEnabled and (getgenv().leftMouseClicked or now < getgenv().clickLingerUntil) then
            myHRP.CFrame = targetHRP.CFrame; return
        end

        local targetVel = targetHRP.AssemblyLinearVelocity
        local targetSpeed = targetVel.Magnitude

        -- Acceleration-aware prediction: derive accel from the velocity delta
        -- since the last frame, so following anticipates a direction change
        -- (juking, starting a sprint) instead of only reacting to the
        -- target's current velocity.
        local accel = Vector3.new(0, 0, 0)
        if lastTargetVel and dt > 0 then
            accel = (targetVel - lastTargetVel) / dt
            local accelMag = accel.Magnitude
            if accelMag > 200 then accel = accel.Unit * 200 end -- clamp spikes from teleports/respawns
        end
        lastTargetVel = targetVel

        local isUnder = getgenv().followUnderneath
        local desiredCF
        if isUnder then
            desiredCF = CFrame.new(targetHRP.Position - Vector3.new(0, getgenv().followDistance, 0))
            desiredCF = CFrame.new(desiredCF.Position, desiredCF.Position + targetHRP.CFrame.LookVector)
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        else
            desiredCF = targetHRP.CFrame * CFrame.new(0, getgenv().followHeight, getgenv().followDistance)
        end
        local desiredPos = desiredCF.Position; local toTarget = desiredPos - myHRP.Position
        local movingAway = targetSpeed > 3 and toTarget.Magnitude > 0.1 and targetVel:Dot(toTarget.Unit) > 2
        if movingAway then
            local predT = 0.09
            local pred = math.min(targetSpeed * predT, 5)
            local accelPred = accel * (0.5 * predT * predT)
            desiredPos = desiredPos + targetVel.Unit * pred + accelPred
            if isUnder then
                desiredCF = CFrame.new(desiredPos, desiredPos + targetHRP.CFrame.LookVector)
            else
                desiredCF = CFrame.new(desiredPos, desiredPos - targetHRP.CFrame.LookVector)
            end
        end

        -- Pathfinding around obstacles: only kick in when the direct line to
        -- the desired follow spot is actually blocked, and only recompute on
        -- a cooldown, since ComputeAsync is too expensive to call every frame.
        if getgenv().followUsePathfinding then
            if now - lastObstructionCheck > 0.25 then
                lastObstructionCheck = now
                isObstructed = checkObstruction(myHRP, desiredPos, char, targetChar)
                if not isObstructed then
                    pathWaypoints = nil
                elseif not pathWaypoints and not pathComputing and (now - lastPathAttempt > 0.6) then
                    lastPathAttempt = now
                    computeFollowPath(myHRP, desiredPos)
                end
            end

            if isObstructed and pathWaypoints and pathWaypoints[pathIndex] then
                local wpPos = pathWaypoints[pathIndex].Position
                local flatDist = (Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z) - Vector3.new(wpPos.X, 0, wpPos.Z)).Magnitude
                if flatDist < 4 then
                    pathIndex = pathIndex + 1
                    if pathIndex > #pathWaypoints then pathWaypoints = nil end
                end
                if pathWaypoints and pathWaypoints[pathIndex] then
                    desiredPos = pathWaypoints[pathIndex].Position + Vector3.new(0, getgenv().followHeight, 0)
                    desiredCF = CFrame.new(desiredPos, targetHRP.Position)
                end
            end
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
    if getgenv().followEnabled then
        stopFollow()
    else
        local nearestPlayer = nil
        local nearestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end

        if nearestPlayer then
            getgenv().followEnabled = true
            getgenv().FollowButton.Text = "Follow: ON"
            getgenv().FollowButton.BackgroundColor3 = getgenv().COL_ON
            startFollow(nearestPlayer)
            if getgenv().Utils and getgenv().Utils.Notify then
                getgenv().Utils:Notify("Follow", "Now following " .. nearestPlayer.Name, Color3.fromRGB(0, 255, 0))
            end
        else
            if getgenv().Utils and getgenv().Utils.Notify then
                getgenv().Utils:Notify("Follow", "No nearby player found.", Color3.fromRGB(220, 60, 60))
            end
        end
    end
end)

if getgenv().BindPanelButton and getgenv().FollowSettingsFrame then
    getgenv().BindPanelButton(getgenv().FollowButton, getgenv().FollowSettingsFrame)
end

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

getgenv().ClickCheckBtn.MouseButton1Click:Connect(function()
    getgenv().clickCheckEnabled = not getgenv().clickCheckEnabled
    getgenv().ClickCheckBtn.Text = "Click Check: " .. (getgenv().clickCheckEnabled and "ON" or "OFF")
    getgenv().ClickCheckBtn.BackgroundColor3 = getgenv().clickCheckEnabled and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().SwitchTargetBtn.MouseButton1Click:Connect(function()
    if getgenv().switchTarget then getgenv().switchTarget() end
end)

if getgenv().PathfindBtn then
    getgenv().PathfindBtn.MouseButton1Click:Connect(function()
        getgenv().followUsePathfinding = not getgenv().followUsePathfinding
        getgenv().PathfindBtn.Text = "Pathfind Around Obstacles: " .. (getgenv().followUsePathfinding and "ON" or "OFF")
        getgenv().PathfindBtn.BackgroundColor3 = getgenv().followUsePathfinding and getgenv().COL_ON or getgenv().COL_OFF
    end)
end

if getgenv().FollowPositionBtn then
    getgenv().FollowPositionBtn.MouseButton1Click:Connect(function()
        getgenv().followUnderneath = not getgenv().followUnderneath
        getgenv().FollowPositionBtn.Text = "Position: " .. (getgenv().followUnderneath and "Underneath" or "Behind")
        getgenv().FollowPositionBtn.BackgroundColor3 = getgenv().followUnderneath and getgenv().COL_ON or getgenv().COL_OFF
    end)
end

-- Target history lets auto-switch / manual switch avoid bouncing straight back
-- to a player we just left. main.lua's death-auto-switch calls pushHistory too.
getgenv().targetHistory = getgenv().targetHistory or {}
local function pushHistory(player)
    if not player then return end
    local hist = getgenv().targetHistory
    hist[#hist + 1] = player
    while #hist > 10 do table.remove(hist, 1) end
end

local function switchTarget()
    if not getgenv().scriptEnabled then return end
    if not getgenv().followEnabled then
        if getgenv().Utils then getgenv().Utils:Notify("Follow", "Enable Follow first.", Color3.fromRGB(220, 60, 60)) end
        return
    end
    local current = getgenv().followTarget
    local nextTarget
    if getgenv().Utils and typeof(getgenv().Utils.FindNearestAlivePlayer) == "function" then
        nextTarget = getgenv().Utils:FindNearestAlivePlayer(current)
    end
    if nextTarget then
        if current then pushHistory(current) end
        getgenv().followTarget = nextTarget
        startFollow(nextTarget)
        if getgenv().Utils then getgenv().Utils:Notify("Follow", "Switched to " .. nextTarget.Name, Color3.fromRGB(255, 160, 0)) end
    else
        if getgenv().Utils then getgenv().Utils:Notify("Follow", "No other players to switch to.", Color3.fromRGB(220, 60, 60)) end
    end
end

getgenv().switchTarget = switchTarget
getgenv().pushHistory = pushHistory
getgenv().startFollow = startFollow
getgenv().stopFollow = stopFollow
