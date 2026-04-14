local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Follow = {}

-- [[ RAW FOLLOW LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 463 - 591, 2143 - 2158, 2440 - 2476, 2558 - 2611

function Follow:Init(state, utils)
    local function stopFollow()
        state.followEnabled = false
        state.followTarget  = nil
        if state.followConnection then state.followConnection:Disconnect(); state.followConnection = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end

    local function startFollow(targetPlayer)
        if not state.scriptEnabled or not state.followEnabled then return end
        state.followTarget = targetPlayer
        if state.followConnection then state.followConnection:Disconnect(); state.followConnection = nil end

        state.followConnection = RunService.RenderStepped:Connect(function(dt)
            if not state.followEnabled or not state.followTarget or not state.followTarget.Character then return end
            local targetHRP = state.followTarget.Character:FindFirstChild("HumanoidRootPart")
            if not targetHRP then return end
            local char = LocalPlayer.Character
            if not char then return end
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.AutoRotate then hum.AutoRotate = false end

            local now = os.clock()
            local inClickOrLinger = state.clickCheckEnabled and (state.leftMouseClicked or now < state.clickLingerUntil)
            if inClickOrLinger then
                myHRP.CFrame = targetHRP.CFrame
                return
            end

            local targetVel   = targetHRP.AssemblyLinearVelocity
            local targetSpeed = targetVel.Magnitude
            local desiredCF   = targetHRP.CFrame * CFrame.new(0, state.followHeight, state.followDistance)
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
        for i = #state.targetHistory, 1, -1 do
            if state.targetHistory[i] == player then table.remove(state.targetHistory, i) end
        end
        table.insert(state.targetHistory, player)
        while #state.targetHistory > 2 do table.remove(state.targetHistory, 1) end
    end

    local function switchTarget()
        if not state.followEnabled then return end
        local candidates = {}
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p ~= state.followTarget and p.Character then
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
        for _, p in ipairs(state.targetHistory) do inHistory[p] = true end

        local chosen = nil
        for _, c in ipairs(candidates) do
            if not inHistory[c.player] then chosen = c.player; break end
        end
        if chosen == nil then chosen = candidates[1].player end

        pushHistory(state.followTarget)
        state.followTarget = chosen
        utils:Notify("Follow", "Switched to " .. chosen.Name, Color3.fromRGB(80, 200, 255))
    end

    self.start = startFollow
    self.stop = stopFollow
    self.switch = switchTarget
    self.pushHistory = pushHistory
    
    return self
end

return Follow
