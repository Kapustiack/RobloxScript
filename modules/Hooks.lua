local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Hooks = {}

function Hooks:InstallMainHook(config)
    print("[Hooks] Installing Metatable Hooks...")
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return nil end
    local okSet = pcall(setreadonly, mt, false)
    if not okSet then return nil end
    
    local old_nc  = rawget(mt, "__namecall")
    local old_idx = rawget(mt, "__index")
    
    -- [[ 1. NAMECALL HOOK (Hitbox/Reach) ]]
    local function hookedNamecall(self, ...)
        if config.GetHitboxEnabled() and config.GetScriptEnabled() then
            local method = getnamecallmethod()
            local isRemote = (method == "FireServer" and self:IsA("RemoteEvent"))
                          or (method == "InvokeServer" and self:IsA("RemoteFunction"))
            
            if isRemote then
                local myChar = LocalPlayer.Character
                local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local nearest = config.FindNearestAlivePlayer()
                    if nearest and nearest.Character then
                        local nearHRP = nearest.Character:FindFirstChild("HumanoidRootPart")
                        if nearHRP then
                            local d = (nearHRP.Position - myHRP.Position).Magnitude
                            if d <= config.GetHitboxSize() * 2 then
                                local args    = {...}
                                local changed = false
                                for i, arg in ipairs(args) do
                                    if typeof(arg) == "Instance" then
                                        if arg:IsA("BasePart") then
                                            local hitOwner = Players:GetPlayerFromCharacter(arg.Parent)
                                            if not hitOwner or hitOwner == LocalPlayer then
                                                args[i] = nearHRP; changed = true
                                            end
                                        elseif arg:IsA("Model") then
                                            local hitOwner = Players:GetPlayerFromCharacter(arg)
                                            if hitOwner == LocalPlayer then
                                                args[i] = nearest.Character; changed = true
                                            end
                                        elseif arg:IsA("Player") and arg == LocalPlayer then
                                            args[i] = nearest; changed = true
                                        end
                                    end
                                end
                                if changed then return old_nc(self, table.unpack(args)) end
                            end
                        end
                    end
                end
            end
        end
        return old_nc(self, ...)
    end

    -- [[ 2. INDEX HOOK (Speed/Jump Anti-Cheat Bypass) ]]
    local function hookedIndex(self, key)
        if not checkcaller() and config.GetScriptEnabled() then
            if typeof(self) == "Instance" and self:IsA("Humanoid") then
                if key == "WalkSpeed" and config.GetSpeedhackEnabled() then
                    return config.GetWalkSpeed() or 16
                elseif key == "JumpPower" and config.GetSpeedhackEnabled() then
                    return config.GetJumpPower() or 50
                end
            end
        end
        return old_idx(self, key)
    end

    local finalNC  = (newcclosure and newcclosure(hookedNamecall)) or hookedNamecall
    local finalIDX = (newcclosure and newcclosure(hookedIndex))    or hookedIndex
    
    rawset(mt, "__namecall", finalNC)
    rawset(mt, "__index",    finalIDX)
    
    pcall(setreadonly, mt, true)

    return function()
        local ok2, mt2 = pcall(getrawmetatable, game)
        if ok2 and mt2 then
            pcall(setreadonly, mt2, false)
            rawset(mt2, "__namecall", old_nc)
            rawset(mt2, "__index",    old_idx)
            pcall(setreadonly, mt2, true)
        end
    end
end

return Hooks
