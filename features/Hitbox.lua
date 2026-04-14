local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ RAW HITBOX LOGIC - Migrated 1:1 from rb.lua ]]
-- Logic (1572 - 1715), UI (2376 - 2412), Loop (2552 - 2555)

local function applyHitboxExpansion()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(getgenv().hitboxSize, getgenv().hitboxSize, getgenv().hitboxSize)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
                
                if getgenv().hitboxVisual then
                    if not getgenv().hitboxAdornments[p] or not getgenv().hitboxAdornments[p].Parent then
                        local a = Instance.new("SphereHandleAdornment")
                        a.Name = "HitboxAdornment"
                        a.Radius = getgenv().hitboxSize / 2
                        a.Color3 = Color3.fromRGB(220, 60, 60)
                        a.AlwaysOnTop = true
                        a.Transparency = 0.5
                        a.Adornee = hrp
                        a.ZIndex = 5
                        a.Parent = workspace
                        getgenv().hitboxAdornments[p] = a
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
    for p, a in pairs(getgenv().hitboxAdornments) do
        if a and a.Parent then a:Destroy() end
    end
    getgenv().hitboxAdornments = {}
end

local function enableHitbox()
    getgenv().hitboxEnabled = true
    applyHitboxExpansion()
    if not getgenv().hitboxRestoreFunc then
        getgenv().hitboxRestoreFunc = getgenv().Hooks:InstallHitboxHook({
            GetHitboxEnabled = function() return getgenv().hitboxEnabled end,
            GetScriptEnabled = function() return getgenv().scriptEnabled end,
            GetHitboxSize = function() return getgenv().hitboxSize end,
            FindNearestAlivePlayer = function() return getgenv().Utils:FindNearestAlivePlayer() end
        })
    end
end

local function disableHitbox()
    getgenv().hitboxEnabled = false
    removeHitboxExpansion()
    if getgenv().hitboxRestoreFunc then
        pcall(getgenv().hitboxRestoreFunc)
        getgenv().hitboxRestoreFunc = nil
    end
end

getgenv().HitboxButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().hitboxEnabled = not getgenv().hitboxEnabled
    if getgenv().hitboxEnabled then
        enableHitbox()
        getgenv().HitboxButton.Text = "Hitbox: ON"
        getgenv().HitboxButton.BackgroundColor3 = getgenv().COL_ON
    else
        disableHitbox()
        getgenv().HitboxButton.Text = "Hitbox: OFF"
        getgenv().HitboxButton.BackgroundColor3 = getgenv().COL_OFF
    end
    -- saveSettings() -- Call global later
end)

getgenv().HitboxButton.MouseButton2Click:Connect(function()
    getgenv().HitboxSettingsFrame.Visible = not getgenv().HitboxSettingsFrame.Visible
    getgenv().ESPSettingsFrame.Visible = false
    getgenv().SpeedSettingsFrame.Visible = false
    getgenv().FOVSettingsFrame.Visible = false
    getgenv().FollowSettingsFrame.Visible = false
    getgenv().ReachSettingsFrame.Visible = false
end)

getgenv().HitboxVisualBtn.MouseButton1Click:Connect(function()
    getgenv().hitboxVisual = not getgenv().hitboxVisual
    getgenv().HitboxVisualBtn.Text = "Visual: " .. (getgenv().hitboxVisual and "ON" or "OFF")
    getgenv().HitboxVisualBtn.BackgroundColor3 = getgenv().hitboxVisual and getgenv().COL_ON or getgenv().COL_OFF
    for p, a in pairs(getgenv().hitboxAdornments) do if a and a.Parent then a:Destroy() end end
    getgenv().hitboxAdornments = {}
    if getgenv().hitboxEnabled then applyHitboxExpansion() end
end)

getgenv().applyHitboxExpansion = applyHitboxExpansion
getgenv().removeHitboxExpansion = removeHitboxExpansion
getgenv().enableHitbox = enableHitbox
getgenv().disableHitbox = disableHitbox
