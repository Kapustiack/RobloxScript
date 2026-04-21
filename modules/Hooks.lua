local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Hooks = {}

function Hooks:InstallHitboxHook(config)
    print("[Hooks] Installing Hitbox Namecall Hook...")
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return nil end
    local okSet = pcall(setreadonly, mt, false)
    if not okSet then return nil end
    
    local old_nc = rawget(mt, "__namecall")
    if not old_nc then pcall(setreadonly, mt, true); return nil end

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
                                if changed then
                                    return old_nc(self, table.unpack(args))
                                end
                            end
                        end
                    end
                end
            end
        end
        return old_nc(self, ...)
    end

    local final = (newcclosure and newcclosure(hookedNamecall)) or hookedNamecall
    rawset(mt, "__namecall", final)
    pcall(setreadonly, mt, true)

    return function()
        local ok2, mt2 = pcall(getrawmetatable, game)
        if ok2 and mt2 then
            pcall(setreadonly, mt2, false)
            rawset(mt2, "__namecall", old_nc)
            pcall(setreadonly, mt2, true)
        end
    end
end

return Hooks
