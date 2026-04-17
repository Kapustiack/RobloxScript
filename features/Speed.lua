-- [[ SPEED — Fully wired, 1:1 from rb.lua ]]
local LocalPlayer = game:GetService("Players").LocalPlayer

local function enableSpeedhack()
    if not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().walkSpeed * getgenv().speedMultiplier
        hum.JumpPower  = getgenv().jumpPower  * getgenv().speedMultiplier
    end
end

local function disableSpeedhack()
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = getgenv().walkSpeed
        hum.JumpPower  = getgenv().jumpPower
    end
end

-- Continuously reapply (handles respawn / external resets)
local function updateSpeed()
    if not getgenv().scriptEnabled or not getgenv().speedhackEnabled then return end
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local ts = getgenv().walkSpeed * getgenv().speedMultiplier
    local tj = getgenv().jumpPower  * getgenv().speedMultiplier
    if hum.WalkSpeed ~= ts then hum.WalkSpeed = ts end
    if hum.JumpPower  ~= tj then hum.JumpPower  = tj end
end

-- Left click = toggle speed
getgenv().SpeedButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().speedhackEnabled = not getgenv().speedhackEnabled
    if getgenv().speedhackEnabled then
        getgenv().SpeedButton.Text = "Speed: ON"
        getgenv().SpeedButton.BackgroundColor3 = getgenv().COL_ON
        enableSpeedhack()
    else
        getgenv().SpeedButton.Text = "Speed: OFF"
        getgenv().SpeedButton.BackgroundColor3 = getgenv().COL_OFF
        disableSpeedhack()
    end
end)

-- Right click = open Speed Settings panel
getgenv().SpeedButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().SpeedSettingsFrame) end
end)

getgenv().updateSpeedLoop = updateSpeed
getgenv().disableSpeedhack = disableSpeedhack
getgenv().enableSpeedhack = enableSpeedhack
