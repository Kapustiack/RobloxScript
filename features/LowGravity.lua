-- [[ LOW GRAVITY ]]
local RunService = game:GetService("RunService")
local DEFAULT_GRAVITY = 196.2

local function applyGravity()
    if not getgenv().lowGravityEnabled or not getgenv().scriptEnabled then return end
    workspace.Gravity = getgenv().lowGravityValue or 50
end

local function disableLowGravity()
    getgenv().lowGravityEnabled = false
    workspace.Gravity = DEFAULT_GRAVITY
end

getgenv().LowGravityButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().lowGravityEnabled = not getgenv().lowGravityEnabled
    getgenv().LowGravityButton.Text = "Low Gravity: " .. (getgenv().lowGravityEnabled and "ON" or "OFF")
    getgenv().LowGravityButton.BackgroundColor3 = getgenv().lowGravityEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().lowGravityEnabled then applyGravity() else disableLowGravity() end
end)

getgenv().LowGravityButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().LowGravitySettingsFrame) end
end)

-- Settings slider wired via Input.lua (draggingLowGravity / lowGravityValue)
-- Live-apply when slider changes
getgenv().applyLowGravity = applyGravity
getgenv().disableLowGravity = disableLowGravity

-- Keep applying on Heartbeat in case other scripts reset it
RunService.Heartbeat:Connect(function()
    if getgenv().lowGravityEnabled and getgenv().scriptEnabled then
        if workspace.Gravity ~= (getgenv().lowGravityValue or 50) then
            workspace.Gravity = getgenv().lowGravityValue or 50
        end
    end
end)
