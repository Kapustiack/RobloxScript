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

-- (Hitbox namecall hook is now managed centrally in modules/Hooks.lua)

getgenv().HitboxButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().hitboxEnabled = not getgenv().hitboxEnabled
    if getgenv().hitboxEnabled then
        getgenv().HitboxButton.Text = "Hitbox: ON"; getgenv().HitboxButton.BackgroundColor3 = getgenv().COL_ON
        applyHitboxExpansion()
    else
        getgenv().HitboxButton.Text = "Hitbox: OFF"; getgenv().HitboxButton.BackgroundColor3 = getgenv().COL_OFF
        removeHitboxExpansion()
    end
end)

getgenv().HitboxButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().HitboxSettingsFrame) end
end)

getgenv().HitboxVisualBtn.MouseButton1Click:Connect(function()
    getgenv().hitboxVisual = not getgenv().hitboxVisual
    getgenv().HitboxVisualBtn.Text = "Visual: " .. (getgenv().hitboxVisual and "ON" or "OFF")
    getgenv().HitboxVisualBtn.BackgroundColor3 = getgenv().hitboxVisual and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().hitboxVisual then for _, a in pairs(getgenv().hitboxAdornments) do a:Destroy() end; getgenv().hitboxAdornments = {} end
end)

getgenv().applyHitboxExpansion = applyHitboxExpansion
getgenv().removeHitboxExpansion = removeHitboxExpansion
