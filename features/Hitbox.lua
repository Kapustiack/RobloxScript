local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Hitbox = {}

-- [[ RAW HITBOX LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1572 - 1715, 2376 - 2412, 2553 - 2556

function Hitbox:Init(state, utils, hooks)
    local function applyHitboxExpansion()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                    
                    if state.hitboxVisual then
                        if not state.hitboxAdornments[p] or not state.hitboxAdornments[p].Parent then
                            local a = Instance.new("SphereHandleAdornment")
                            a.Name = "HitboxAdornment"
                            a.Radius = state.hitboxSize / 2
                            a.Color3 = Color3.fromRGB(220, 60, 60)
                            a.AlwaysOnTop = true
                            a.Transparency = 0.5
                            a.Adornee = hrp
                            a.ZIndex = 5
                            a.Parent = workspace
                            state.hitboxAdornments[p] = a
                        end
                    end
                end
            end
        end
    end

    local function removeHitboxExpansion()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true end
            end
        end
        for p, a in pairs(state.hitboxAdornments) do
            if a and a.Parent then a:Destroy() end
        end
        state.hitboxAdornments = {}
    end

    local function enableHitbox()
        state.hitboxEnabled = true
        applyHitboxExpansion()
        if not state.hitboxRestoreFunc then
            state.hitboxRestoreFunc = hooks:InstallHitboxHook({
                GetHitboxEnabled = function() return state.hitboxEnabled end,
                GetScriptEnabled = function() return state.scriptEnabled end,
                GetHitboxSize = function() return state.hitboxSize end,
                FindNearestAlivePlayer = function() return utils:FindNearestAlivePlayer() end
            })
        end
    end

    local function disableHitbox()
        state.hitboxEnabled = false
        removeHitboxExpansion()
        if state.hitboxRestoreFunc then
            pcall(state.hitboxRestoreFunc)
            state.hitboxRestoreFunc = nil
        end
    end

    self.apply = applyHitboxExpansion
    self.remove = removeHitboxExpansion
    self.enable = enableHitbox
    self.disable = disableHitbox
    
    return self
end

return Hitbox
