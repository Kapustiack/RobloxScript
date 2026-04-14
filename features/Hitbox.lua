local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ RAW HITBOX LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1582 - 1715, 1627 - 1696 (Namecall Hook)

local function applyHitboxExpansion()
    if not getgenv().hitboxEnabled or not getgenv().scriptEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(getgenv().hitboxSize, getgenv().hitboxSize, getgenv().hitboxSize)
                if getgenv().hitboxVisual then
                    local existing = getgenv().hitboxAdornments[p]
                    if not existing or not existing.Parent then
                        local a = Instance.new("SphereHandleAdornment")
                        a.Radius = getgenv().hitboxSize / 2; a.Color3 = Color3.fromRGB(60, 200, 255); a.AlwaysOnTop = false; a.Transparency = 0.55; a.Adornee = hrp; a.Parent = workspace
                        getgenv().hitboxAdornments[p] = a
                    else existing.Radius = getgenv().hitboxSize / 2 end
                end
            end
        end
    end
end

local function removeHitboxExpansion()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(2, 2, 1) end
        end
    end
    for p, a in pairs(getgenv().hitboxAdornments) do if a and a.Parent then a:Destroy() end end
    getgenv().hitboxAdornments = {}
end

local function installNamecallHook()
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return nil end
    pcall(setreadonly, mt, false)
    local old_nc = rawget(mt, "__namecall")
    if not old_nc then pcall(setreadonly, mt, true); return nil end

    local function hookedNamecall(self, ...)
        if getgenv().hitboxEnabled and getgenv().scriptEnabled then
            local method = getnamecallmethod()
            local isRemote = (method == "FireServer" and self:IsA("RemoteEvent")) or (method == "InvokeServer" and self:IsA("RemoteFunction"))
            if isRemote then
                local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local nearest = getgenv().Utils:FindNearestAlivePlayer(nil)
                    if nearest and nearest.Character then
                        local nearHRP = nearest.Character:FindFirstChild("HumanoidRootPart")
                        if nearHRP and (nearHRP.Position - myHRP.Position).Magnitude <= getgenv().hitboxSize * 2 then
                            local args = {...}; local changed = false
                            for i, arg in ipairs(args) do
                                if typeof(arg) == "Instance" then
                                    if arg:IsA("BasePart") then
                                        local hitOwner = Players:GetPlayerFromCharacter(arg.Parent)
                                        if not hitOwner or hitOwner == LocalPlayer then args[i] = nearHRP; changed = true end
                                    elseif arg:IsA("Model") then
                                        local hitOwner = Players:GetPlayerFromCharacter(arg)
                                        if not hitOwner or hitOwner == LocalPlayer then args[i] = nearest.Character; changed = true end
                                    elseif arg:IsA("Player") and arg == LocalPlayer then args[i] = nearest; changed = true end
                                end
                            end
                            if changed then return old_nc(self, table.unpack(args)) end
                        end
                    end
                end
            end
        end
        return old_nc(self, ...)
    end
    rawset(mt, "__namecall", (newcclosure and newcclosure(hookedNamecall)) or hookedNamecall)
    pcall(setreadonly, mt, true)
    return function() local ok2, mt2 = pcall(getrawmetatable, game); if ok2 and mt2 then pcall(setreadonly, mt2, false); rawset(mt2, "__namecall", old_nc); pcall(setreadonly, mt2, true) end end
end

getgenv().HitboxButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().hitboxEnabled = not getgenv().hitboxEnabled
    if getgenv().hitboxEnabled then
        getgenv().HitboxButton.Text = "Hitbox: ON"; getgenv().HitboxButton.BackgroundColor3 = getgenv().COL_ON
        applyHitboxExpansion()
        if not getgenv().hitboxRestoreFunc then getgenv().hitboxRestoreFunc = installNamecallHook() end
    else
        getgenv().HitboxButton.Text = "Hitbox: OFF"; getgenv().HitboxButton.BackgroundColor3 = getgenv().COL_OFF
        removeHitboxExpansion()
        if getgenv().hitboxRestoreFunc then pcall(getgenv().hitboxRestoreFunc); getgenv().hitboxRestoreFunc = nil end
    end
end)

getgenv().HitboxButton.MouseButton2Click:Connect(function()
    getgenv().HitboxSettingsFrame.Visible = not getgenv().HitboxSettingsFrame.Visible
end)

getgenv().HitboxVisualBtn.MouseButton1Click:Connect(function()
    getgenv().hitboxVisual = not getgenv().hitboxVisual
    getgenv().HitboxVisualBtn.Text = "Visual: " .. (getgenv().hitboxVisual and "ON" or "OFF")
    getgenv().HitboxVisualBtn.BackgroundColor3 = getgenv().hitboxVisual and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().hitboxVisual then for _, a in pairs(getgenv().hitboxAdornments) do a:Destroy() end; getgenv().hitboxAdornments = {} end
end)

getgenv().applyHitboxExpansion = applyHitboxExpansion
getgenv().removeHitboxExpansion = removeHitboxExpansion
