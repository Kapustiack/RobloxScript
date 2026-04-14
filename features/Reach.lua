local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local Reach = {}

-- [[ RAW REACH LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1729 - 1807, 2339 - 2374, 2491 - 2528

function Reach:Init(state, utils, featHitbox)
    local function hookReachTool()
        if state.reachActivatedConn then state.reachActivatedConn:Disconnect(); state.reachActivatedConn = nil end
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end

        state.reachActivatedConn = tool.Activated:Connect(function()
            if not state.reachEnabled or not state.scriptEnabled then return end
            local target = (state.followTarget and state.followTarget.Character) and state.followTarget or nil
            if not target then target = utils:FindNearestAlivePlayer(nil) end
            if not target then return end
            local targetChar = target.Character or target
            if not targetChar then return end
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP then return end
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end

            local savedCF = myHRP.CFrame
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.2)
            if featHitbox then featHitbox:apply() end

            if state.reachIndicator then state.reachIndicator.Color3 = Color3.fromRGB(255, 140, 0) end

            task.defer(function()
                if myHRP and myHRP.Parent then myHRP.CFrame = savedCF end
                if state.reachIndicator then state.reachIndicator.Color3 = Color3.fromRGB(60, 220, 120) end
                if not state.hitboxEnabled and featHitbox then featHitbox:remove() end
            end)
        end)
    end

    local function enableReach()
        if not state.scriptEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if state.reachIndicator then state.reachIndicator:Destroy() end
        state.reachIndicator = Instance.new("SphereHandleAdornment")
        state.reachIndicator.Radius = 0.5
        state.reachIndicator.Color3 = Color3.fromRGB(60, 220, 120)
        state.reachIndicator.AlwaysOnTop = true
        state.reachIndicator.Transparency = 0.3
        state.reachIndicator.ZIndex = 5
        state.reachIndicator.Adornee = hrp
        state.reachIndicator.CFrame = CFrame.new(0, 0, -state.reachDistance)
        state.reachIndicator.Parent = workspace

        hookReachTool()

        if state.reachToolWatcher then state.reachToolWatcher:Disconnect() end
        state.reachToolWatcher = char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and state.reachEnabled then
                task.wait()
                hookReachTool()
            end
        end)
    end

    local function disableReach()
        state.reachEnabled = false
        if state.reachIndicator then state.reachIndicator:Destroy(); state.reachIndicator = nil end
        if state.reachActivatedConn then state.reachActivatedConn:Disconnect(); state.reachActivatedConn = nil end
        if state.reachToolWatcher then state.reachToolWatcher:Disconnect(); state.reachToolWatcher = nil end
    end

    self.enable = enableReach
    self.disable = disableReach
    
    return self
end

return Reach
