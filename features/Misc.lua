local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

local Misc = {}

-- [[ RAW MISC LOGIC - Migrated 1:1 from rb.lua ]]
-- Fullbright, FOV, ShiftLock, CtrlLock

function Misc:ToggleFullbright(state_val, state)
    if state_val then
        state.originalLightingSettings = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient
        }
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        local s = state.originalLightingSettings
        if s.Brightness then
            Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime
            Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows
            Lighting.Ambient = s.Ambient
        end
    end
end

function Misc:UpdateFOV(state)
    Camera.FieldOfView = state.currentFOV
end

function Misc:ToggleShiftLock(state_val)
    if state_val then
        ContextActionService:BindAction("DisableShiftLock", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift)
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", true) end)
    else
        ContextActionService:UnbindAction("DisableShiftLock")
        pcall(function() StarterGui:SetCore("ShiftLockDisabled", false) end)
    end
end

function Misc:ToggleCtrlLock(state_val)
    if state_val then
        ContextActionService:BindAction("DisableCtrlSwitch", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl)
    else
        ContextActionService:UnbindAction("DisableCtrlSwitch")
    end
end

return Misc
