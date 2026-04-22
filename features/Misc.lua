local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
-- BUG 10 FIX: Players was never imported, causing crash in Wallhack loop
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ RAW MISC LOGIC - 1:1 from rb.lua ]]

-- 1. FULLBRIGHT — BUG 2 FIX: Full effect save/restore (was only saving 5 of 14 properties)
local function applyFullbright()
    Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e9; Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.EnvironmentDiffuseScale = 1; Lighting.EnvironmentSpecularScale = 1
    for _, effect in ipairs(Lighting:GetDescendants()) do
        pcall(function()
            if effect:IsA("Atmosphere") then
                effect.Density = 0; effect.Offset = 0; effect.Haze = 0
                effect.Glare = 0; effect.Color = Color3.fromRGB(199, 170, 120)
            elseif effect:IsA("ColorCorrectionEffect") then
                effect.Brightness = 0; effect.Contrast = 0; effect.Saturation = 0
                effect.TintColor = Color3.fromRGB(255,255,255); effect.Enabled = false
            elseif effect:IsA("BloomEffect") then
                effect.Intensity = 0; effect.Size = 0; effect.Threshold = 1e9; effect.Enabled = false
            elseif effect:IsA("SunRaysEffect") then
                effect.Intensity = 0; effect.Spread = 0; effect.Enabled = false
            elseif effect:IsA("DepthOfFieldEffect") then
                effect.FarIntensity = 0; effect.NearIntensity = 0; effect.Enabled = false
            elseif effect:IsA("BlurEffect") then
                effect.Size = 0; effect.Enabled = false
            end
        end)
    end
end

local function enableFullbright()
    if not getgenv().scriptEnabled then return end
    if not getgenv().originalLightingSettings.saved then
        local s = getgenv().originalLightingSettings; s.saved = true
        s.Brightness = Lighting.Brightness; s.ClockTime = Lighting.ClockTime
        s.FogEnd = Lighting.FogEnd; s.FogStart = Lighting.FogStart
        s.GlobalShadows = Lighting.GlobalShadows
        s.OutdoorAmbient = Lighting.OutdoorAmbient; s.Ambient = Lighting.Ambient
        s.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
        s.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
        s.effects = {}
        for _, effect in ipairs(Lighting:GetDescendants()) do
            pcall(function()
                local saved = { instance = effect }
                if effect:IsA("Atmosphere") then
                    saved.Density = effect.Density; saved.Offset = effect.Offset
                    saved.Haze = effect.Haze; saved.Glare = effect.Glare; saved.Color = effect.Color
                elseif effect:IsA("ColorCorrectionEffect") then
                    saved.Brightness = effect.Brightness; saved.Contrast = effect.Contrast
                    saved.Saturation = effect.Saturation; saved.TintColor = effect.TintColor; saved.Enabled = effect.Enabled
                elseif effect:IsA("BloomEffect") then
                    saved.Intensity = effect.Intensity; saved.Size = effect.Size
                    saved.Threshold = effect.Threshold; saved.Enabled = effect.Enabled
                elseif effect:IsA("SunRaysEffect") then
                    saved.Intensity = effect.Intensity; saved.Spread = effect.Spread; saved.Enabled = effect.Enabled
                elseif effect:IsA("DepthOfFieldEffect") then
                    saved.FarIntensity = effect.FarIntensity; saved.NearIntensity = effect.NearIntensity; saved.Enabled = effect.Enabled
                elseif effect:IsA("BlurEffect") then
                    saved.Size = effect.Size; saved.Enabled = effect.Enabled
                else return end
                table.insert(s.effects, saved)
            end)
        end
    end
    applyFullbright()
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect() end
    getgenv().fullbrightLoop = RunService.Heartbeat:Connect(function()
        if getgenv().fullbrightEnabled and getgenv().scriptEnabled then applyFullbright() end
    end)
end

local function disableFullbright()
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect(); getgenv().fullbrightLoop = nil end
    local s = getgenv().originalLightingSettings
    if not s.saved then return end
    pcall(function() Lighting.Brightness = s.Brightness end)
    pcall(function() Lighting.ClockTime = s.ClockTime end)
    pcall(function() Lighting.FogEnd = s.FogEnd end)
    pcall(function() Lighting.FogStart = s.FogStart end)
    pcall(function() Lighting.GlobalShadows = s.GlobalShadows end)
    pcall(function() Lighting.OutdoorAmbient = s.OutdoorAmbient end)
    pcall(function() Lighting.Ambient = s.Ambient end)
    pcall(function() Lighting.EnvironmentDiffuseScale = s.EnvironmentDiffuseScale end)
    pcall(function() Lighting.EnvironmentSpecularScale = s.EnvironmentSpecularScale end)
    if s.effects then
        for _, saved in ipairs(s.effects) do
            pcall(function()
                local e = saved.instance; if not e or not e.Parent then return end
                if e:IsA("Atmosphere") then
                    e.Density = saved.Density; e.Offset = saved.Offset
                    e.Haze = saved.Haze; e.Glare = saved.Glare; e.Color = saved.Color
                elseif e:IsA("ColorCorrectionEffect") then
                    e.Brightness = saved.Brightness; e.Contrast = saved.Contrast
                    e.Saturation = saved.Saturation; e.TintColor = saved.TintColor; e.Enabled = saved.Enabled
                elseif e:IsA("BloomEffect") then
                    e.Intensity = saved.Intensity; e.Size = saved.Size; e.Threshold = saved.Threshold; e.Enabled = saved.Enabled
                elseif e:IsA("SunRaysEffect") then
                    e.Intensity = saved.Intensity; e.Spread = saved.Spread; e.Enabled = saved.Enabled
                elseif e:IsA("DepthOfFieldEffect") then
                    e.FarIntensity = saved.FarIntensity; e.NearIntensity = saved.NearIntensity; e.Enabled = saved.Enabled
                elseif e:IsA("BlurEffect") then
                    e.Size = saved.Size; e.Enabled = saved.Enabled
                end
            end)
        end
    end
    s.saved = false
end

getgenv().FullbrightButton.MouseButton1Click:Connect(function()
    getgenv().fullbrightEnabled = not getgenv().fullbrightEnabled
    if getgenv().fullbrightEnabled then
        getgenv().FullbrightButton.Text = "Fullbright: ON"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_ON; enableFullbright()
    else
        getgenv().FullbrightButton.Text = "Fullbright: OFF"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_OFF; disableFullbright()
    end
end)

-- 2. LOCKS
getgenv().ShiftLockButton.MouseButton1Click:Connect(function()
    getgenv().shiftLockDisabled = not getgenv().shiftLockDisabled
    if getgenv().shiftLockDisabled then
        getgenv().ShiftLockButton.Text = "Shift Lock: ON"; getgenv().ShiftLockButton.BackgroundColor3 = getgenv().COL_ON
        ContextActionService:BindAction("DisableShiftLock", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", true) end)
    else
        getgenv().ShiftLockButton.Text = "Shift Lock: OFF"; getgenv().ShiftLockButton.BackgroundColor3 = getgenv().COL_OFF
        ContextActionService:UnbindAction("DisableShiftLock"); pcall(function() StarterGui:SetCore("ShiftLockDisabled", false) end)
    end
end)

getgenv().CtrlLockButton.MouseButton1Click:Connect(function()
    getgenv().ctrlLockDisabled = not getgenv().ctrlLockDisabled
    if getgenv().ctrlLockDisabled then
        getgenv().CtrlLockButton.Text = "Ctrl Lock (R): ON"
        getgenv().CtrlLockButton.BackgroundColor3 = getgenv().COL_ON
        -- Keep LeftControl free so Ctrl+Click teleport always works.
        ContextActionService:BindAction("DisableCtrlSwitch", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.RightControl)
    else
        getgenv().CtrlLockButton.Text = "Ctrl Lock (R): OFF"
        getgenv().CtrlLockButton.BackgroundColor3 = getgenv().COL_OFF
        ContextActionService:UnbindAction("DisableCtrlSwitch")
    end
end)

-- 3. FOV
getgenv().FOVButton.MouseButton1Click:Connect(function()
    getgenv().fovChangerEnabled = not getgenv().fovChangerEnabled
    if getgenv().fovChangerEnabled then
        getgenv().FOVButton.Text = "FOV: ON"; getgenv().FOVButton.BackgroundColor3 = getgenv().COL_ON; Camera.FieldOfView = getgenv().currentFOV
    else
        getgenv().FOVButton.Text = "FOV: OFF"; getgenv().FOVButton.BackgroundColor3 = getgenv().COL_OFF; Camera.FieldOfView = getgenv().defaultFOV
    end
end)
if getgenv().BindPanelButton and getgenv().FOVSettingsFrame then
    getgenv().BindPanelButton(getgenv().FOVButton, getgenv().FOVSettingsFrame)
end

-- 4. WALLHACK — Dynamic transparency + optional team check
local function shouldSkipPlayer(p)
    if p == LocalPlayer then return true end
    if getgenv().wallhackTeamCheck then
        -- Skip teammates (same Team object)
        if LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then return true end
    end
    return false
end

local function enableWallhack()
    if getgenv().wallhackLoop then getgenv().wallhackLoop:Disconnect() end
    getgenv().wallhackLoop = RunService.Stepped:Connect(function()
        if not getgenv().wallhackEnabled or not getgenv().scriptEnabled then return end
        local transp = getgenv().wallhackTransparency or 0.5
        for _, p in pairs(Players:GetPlayers()) do
            if not shouldSkipPlayer(p) and p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = transp
                    end
                end
            end
        end
    end)
end

local function disableWallhack()
    if getgenv().wallhackLoop then getgenv().wallhackLoop:Disconnect(); getgenv().wallhackLoop = nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in pairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
            end
        end
    end
end

-- Left click = toggle
getgenv().WallhackButton.MouseButton1Click:Connect(function()
    getgenv().wallhackEnabled = not getgenv().wallhackEnabled
    if getgenv().wallhackEnabled then
        getgenv().WallhackButton.Text = "Wallhack: ON"; getgenv().WallhackButton.BackgroundColor3 = getgenv().COL_ON; enableWallhack()
    else
        getgenv().WallhackButton.Text = "Wallhack: OFF"; getgenv().WallhackButton.BackgroundColor3 = getgenv().COL_OFF; disableWallhack()
    end
end)

-- Right click = open Wallhack Settings panel
if getgenv().BindPanelButton and getgenv().WallhackSettingsFrame then
    getgenv().BindPanelButton(getgenv().WallhackButton, getgenv().WallhackSettingsFrame)
end

-- Settings: Team Check toggle
getgenv().WallhackTeamCheckBtn.MouseButton1Click:Connect(function()
    getgenv().wallhackTeamCheck = not getgenv().wallhackTeamCheck
    getgenv().WallhackTeamCheckBtn.Text = "Skip Teammates: " .. (getgenv().wallhackTeamCheck and "ON" or "OFF")
    getgenv().WallhackTeamCheckBtn.BackgroundColor3 = getgenv().wallhackTeamCheck and getgenv().COL_ON or getgenv().COL_OFF
    -- If wallhack is on, restart loop to apply change immediately
    if getgenv().wallhackEnabled then
        disableWallhack(); enableWallhack()
    end
end)


-- 5. SERVER UTILS
getgenv().RejoinButton.MouseButton1Click:Connect(function() if getgenv().Utils then getgenv().Utils:RejoinServer() end end)
getgenv().JoinInstanceButton.MouseButton1Click:Connect(function() if getgenv().Utils then getgenv().Utils:JoinNewInstance() end end)

-- 6. SAVE BUTTON — BUG 11 FIX: was missing entirely
getgenv().SaveButton.MouseButton1Click:Connect(function()
    if getgenv().saveSettings then getgenv().saveSettings() end
end)

getgenv().disableFOVChanger = function() Camera.FieldOfView = getgenv().defaultFOV end
getgenv().enableWallhack = enableWallhack
getgenv().disableWallhack = disableWallhack
getgenv().enableFullbright = enableFullbright
getgenv().disableFullbright = disableFullbright
