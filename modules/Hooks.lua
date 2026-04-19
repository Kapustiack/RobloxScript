local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Hooks = {}
local old_nc = nil

-- Consolidated Namecall Hook for Hitbox and Remote Blocking
function Hooks:InstallMainHook(config)
    if old_nc then return end -- Already installed

    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return end
    pcall(setreadonly, mt, false)
    
    old_nc = rawget(mt, "__namecall")
    if not old_nc then pcall(setreadonly, mt, true); return end

    local function hookedNamecall(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        local name = ""
        pcall(function() name = string.lower(self.Name) end)

        -- 1. REMOTE BLOCKER (Fall Damage / Generic Damage)
        if getgenv().noFallDamageEnabled and getgenv().scriptEnabled then
            if method == "FireServer" or method == "InvokeServer" then
                if string.find(name, "fall") or string.find(name, "land") or string.find(name, "damage") then
                    return nil
                end
            end
        end

        -- 2. HITBOX EXPANSION (Redirect hits to nearest player)
        if config.GetHitboxEnabled() and config.GetScriptEnabled() then
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
                                            if not hitOwner or hitOwner == LocalPlayer then
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

    rawset(mt, "__namecall", (newcclosure and newcclosure(hookedNamecall)) or hookedNamecall)
    pcall(setreadonly, mt, true)
end

function Hooks:UninstallMainHook()
    local ok, mt = pcall(getrawmetatable, game)
    if ok and mt and old_nc then
        pcall(setreadonly, mt, false)
        rawset(mt, "__namecall", old_nc)
        pcall(setreadonly, mt, true)
        old_nc = nil
    end
end

return Hooks
