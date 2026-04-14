local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- [[ RAW MISC LOGIC - Migrated 1:1 from rb.lua ]]

-- 1. FULLBRIGHT
local function applyFullbright()
    Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e9; Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.Ambient = Color3.fromRGB(128, 128, 128)
end
local function enableFullbright()
    if not getgenv().originalLightingSettings.saved then
        local s = getgenv().originalLightingSettings; s.saved = true; s.Brightness = Lighting.Brightness; s.ClockTime = Lighting.ClockTime; s.FogEnd = Lighting.FogEnd; s.GlobalShadows = Lighting.GlobalShadows; s.Ambient = Lighting.Ambient
    end
    applyFullbright()
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect() end
    getgenv().fullbrightLoop = RunService.Heartbeat:Connect(function() if getgenv().fullbrightEnabled then applyFullbright() end end)
end
local function disableFullbright()
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect(); getgenv().fullbrightLoop = nil end
    local s = getgenv().originalLightingSettings; if s.saved then Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime; Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows; Lighting.Ambient = s.Ambient end
end

getgenv().FullbrightButton.MouseButton1Click:Connect(function()
    getgenv().fullbrightEnabled = not getgenv().fullbrightEnabled
    if getgenv().fullbrightEnabled then getgenv().FullbrightButton.Text = "Fullbright: ON"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_ON; enableFullbright()
    else getgenv().FullbrightButton.Text = "Fullbright: OFF"; getgenv().FullbrightButton.BackgroundColor3 = getgenv().COL_OFF; disableFullbright() end
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
        getgenv().CtrlLockButton.Text = "Ctrl Lock: ON"; getgenv().CtrlLockButton.BackgroundColor3 = getgenv().COL_ON
        ContextActionService:BindAction("DisableCtrlSwitch", function() return Enum.ContextActionResult.Sink end, false, Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl)
    else
        getgenv().CtrlLockButton.Text = "Ctrl Lock: OFF"; getgenv().CtrlLockButton.BackgroundColor3 = getgenv().COL_OFF
        ContextActionService:UnbindAction("DisableCtrlSwitch")
    end
end)

-- 3. FOV
getgenv().FOVButton.MouseButton1Click:Connect(function()
    getgenv().fovChangerEnabled = not getgenv().fovChangerEnabled
    if getgenv().fovChangerEnabled then getgenv().FOVButton.Text = "FOV: ON"; getgenv().FOVButton.BackgroundColor3 = getgenv().COL_ON; Camera.FieldOfView = getgenv().currentFOV
    else getgenv().FOVButton.Text = "FOV: OFF"; getgenv().FOVButton.BackgroundColor3 = getgenv().COL_OFF; Camera.FieldOfView = getgenv().defaultFOV end
end)
getgenv().FOVButton.MouseButton2Click:Connect(function() if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().FOVSettingsFrame) end end)

-- 4. WALLHACK
local function enableWallhack()
    if getgenv().wallhackLoop then getgenv().wallhackLoop:Disconnect() end
    getgenv().wallhackLoop = RunService.Stepped:Connect(function()
        if not getgenv().wallhackEnabled then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false; part.Transparency = 0.5 end
                end
            end
        end
    end)
end
local function disableWallhack()
    if getgenv().wallhackLoop then getgenv().wallhackLoop:Disconnect(); getgenv().wallhackLoop = nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then for _, part in pairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true; part.Transparency = 0 end end end
    end
end
getgenv().WallhackButton.MouseButton1Click:Connect(function()
    getgenv().wallhackEnabled = not getgenv().wallhackEnabled
    if getgenv().wallhackEnabled then getgenv().WallhackButton.Text = "Wallhack: ON"; getgenv().WallhackButton.BackgroundColor3 = getgenv().COL_ON; enableWallhack()
    else getgenv().WallhackButton.Text = "Wallhack: OFF"; getgenv().WallhackButton.BackgroundColor3 = getgenv().COL_OFF; disableWallhack() end
end)

-- 5. SERVER UTILS
getgenv().RejoinButton.MouseButton1Click:Connect(function() if getgenv().Utils then getgenv().Utils:RejoinServer() end end)
getgenv().JoinInstanceButton.MouseButton1Click:Connect(function() if getgenv().Utils then getgenv().Utils:JoinNewInstance() end end)

getgenv().disableFOVChanger = function() Camera.FieldOfView = getgenv().defaultFOV end
getgenv().disableWallhack = disableWallhack
