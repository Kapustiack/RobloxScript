local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- [[ RAW MISC LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1032 - 1202, 2135 - 2158

local function applyFullbright()
    Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e9; Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.Ambient = Color3.fromRGB(128, 128, 128)
end

local function enableFullbright()
    if not getgenv().originalLightingSettings.saved then
        local s = getgenv().originalLightingSettings
        s.saved = true; s.Brightness = Lighting.Brightness; s.ClockTime = Lighting.ClockTime; s.FogEnd = Lighting.FogEnd; s.GlobalShadows = Lighting.GlobalShadows; s.Ambient = Lighting.Ambient
    end
    applyFullbright()
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect() end
    getgenv().fullbrightLoop = game:GetService("RunService").Heartbeat:Connect(function() if getgenv().fullbrightEnabled then applyFullbright() end end)
end

local function disableFullbright()
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect(); getgenv().fullbrightLoop = nil end
    local s = getgenv().originalLightingSettings
    if s.saved then Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime; Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows; Lighting.Ambient = s.Ambient end
end

getgenv().FullbrightButton.MouseButton1Click:Connect(function()
    getgenv().fullbrightEnabled = not getgenv().fullbrightEnabled
    if getgenv().fullbrightEnabled then getgenv().FullbrightButton.Text = "Fullbright: ON"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_ON; enableFullbright()
    else getgenv().FullbrightButton.Text = "Fullbright: OFF"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_OFF; disableFullbright() end
end)

getgenv().ShiftLockButton.MouseButton1Click:Connect(function()
    getgenv().shiftLockDisabled = not getgenv().shiftLockDisabled
    if getgenv().shiftLockDisabled then
        getgenv().ShiftLockButton.Text = "Shift Lock: ON"; getgenv().ShiftLockButton.BackgroundColor3 = getgenv().COL_ON
        ContextActionService:BindAction("DisableShiftLock", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", true) end)
    else
        getgenv().ShiftLockButton.Text = "Shift Lock: OFF"; getgenv().ShiftLockButton.BackgroundColor3 = getgenv().COL_OFF
        ContextActionService:UnbindAction("DisableShiftLock")
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", false) end)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        getgenv().guiHidden = not getgenv().guiHidden
        getgenv().MainFrame.Visible = not getgenv().guiHidden
    end
end)

getgenv().FOVButton.MouseButton2Click:Connect(function() getgenv().FOVSettingsFrame.Visible = not getgenv().FOVSettingsFrame.Visible end)
