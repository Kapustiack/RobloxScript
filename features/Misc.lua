local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

-- [[ RAW MISC LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1911 - 2142, 2300 - 2308, 2478 - 2489

local function toggleFullbright()
    getgenv().fullbrightEnabled = not getgenv().fullbrightEnabled
    if getgenv().fullbrightEnabled then
        getgenv().originalLightingSettings = {Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient}
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        getgenv().FullbrightButton.Text = "Fullbright: ON"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_ON
    else
        local s = getgenv().originalLightingSettings
        if s.Brightness then Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime; Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows; Lighting.Ambient = s.Ambient end
        getgenv().FullbrightButton.Text = "Fullbright: OFF"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_OFF
    end
end

local function toggleShiftLock()
    local cas = game:GetService("ContextActionService")
    getgenv().shiftLockDisabled = not getgenv().shiftLockDisabled
    if getgenv().shiftLockDisabled then
        getgenv().ShiftLockButton.Text = "Shift Lock: ON"; getgenv().ShiftLockButton.BackgroundColor3 = getgenv().COL_ON
        cas:BindAction("DisableShiftLock", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", true) end)
    else
        getgenv().ShiftLockButton.Text = "Shift Lock: OFF"; getgenv().ShiftLockButton.BackgroundColor3 = getgenv().COL_OFF
        cas:UnbindAction("DisableShiftLock")
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", false) end)
    end
end

local function toggleCtrlLock()
    getgenv().ctrlLockDisabled = not getgenv().ctrlLockDisabled
    local cas = game:GetService("ContextActionService")
    if getgenv().ctrlLockDisabled then
        getgenv().CtrlLockButton.Text = "Ctrl Lock: ON"; getgenv().CtrlLockButton.BackgroundColor3 = getgenv().COL_ON
        cas:BindAction("DisableCtrlSwitch", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl)
    else
        getgenv().CtrlLockButton.Text = "Ctrl Lock: OFF"; getgenv().CtrlLockButton.BackgroundColor3 = getgenv().COL_OFF
        cas:UnbindAction("DisableCtrlSwitch")
    end
end

getgenv().FullbrightButton.MouseButton1Click:Connect(toggleFullbright)
getgenv().ShiftLockButton.MouseButton1Click:Connect(toggleShiftLock)
getgenv().CtrlLockButton.MouseButton1Click:Connect(toggleCtrlLock)

getgenv().FOVButton.MouseButton2Click:Connect(function() getgenv().FOVSettingsFrame.Visible = not getgenv().FOVSettingsFrame.Visible end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        getgenv().guiHidden = not getgenv().guiHidden
        getgenv().MainFrame.Visible = not getgenv().guiHidden
    end
end)

getgenv().toggleFullbright = toggleFullbright
getgenv().toggleShiftLock = toggleShiftLock
getgenv().toggleCtrlLock = toggleCtrlLock
