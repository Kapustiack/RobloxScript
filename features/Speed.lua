local LocalPlayer = game:GetService("Players").LocalPlayer

-- [[ RAW SPEED LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1269 - 1301, 1984 - 2011, 2300 - 2308 (part), 2536 - 2550

local function updateSpeed()
    if not getgenv().scriptEnabled then return end
    if getgenv().speedhackEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local ts = getgenv().walkSpeed * getgenv().speedMultiplier
                local tj = getgenv().jumpPower * getgenv().speedMultiplier
                if hum.WalkSpeed ~= ts then hum.WalkSpeed = ts end
                if hum.JumpPower ~= tj then hum.JumpPower = tj end
            end
        end
    end
end

getgenv().SpeedButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().speedhackEnabled = not getgenv().speedhackEnabled
    if getgenv().speedhackEnabled then
        getgenv().SpeedButton.Text = "Speed: ON"
        getgenv().SpeedButton.BackgroundColor3 = getgenv().COL_ON
    else
        getgenv().SpeedButton.Text = "Speed: OFF"
        getgenv().SpeedButton.BackgroundColor3 = getgenv().COL_OFF
        local char = LocalPlayer.Character
        if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = getgenv().walkSpeed; hum.JumpPower = getgenv().jumpPower end end
    end
end)

getgenv().SpeedButton.MouseButton2Click:Connect(function()
    getgenv().SpeedSettingsFrame.Visible = not getgenv().SpeedSettingsFrame.Visible
end)

getgenv().updateSpeedLoop = updateSpeed
