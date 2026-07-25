local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function getCurrentSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.SeatPart or nil
end

local function enableFlight()
    if not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    getgenv().flying = true

    local hum  = char:FindFirstChildOfClass("Humanoid")
    local seat = getCurrentSeat()

    getgenv().flightWasSeated = (seat ~= nil)
    if hum and not seat then
        hum.PlatformStand = true
    end

    local fv = char.HumanoidRootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
    fv.Name = "FlyVelocity"
    if getgenv().flightSoftMode then
        -- Finite force lets collisions actually push back against the flier
        -- (smoother against geometry) instead of infinite force fighting a
        -- wall and jittering/clipping through thin obstacles.
        fv.MaxForce = Vector3.new(9000, 9000, 9000)
        fv.P = 3000
    else
        fv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        fv.P = 50000
    end
    fv.Velocity = Vector3.new(0, 0, 0); fv.Parent = char.HumanoidRootPart
    getgenv().flyVelocity = fv

    local bg = char.HumanoidRootPart:FindFirstChild("FlyGyro") or Instance.new("BodyGyro")
    bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000; bg.CFrame = char.HumanoidRootPart.CFrame; bg.Parent = char.HumanoidRootPart
    getgenv().bodyGyro = bg
end

local function disableFlight()
    getgenv().flying = false
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local fv = char.HumanoidRootPart:FindFirstChild("FlyVelocity"); if fv then fv:Destroy() end
        local bg = char.HumanoidRootPart:FindFirstChild("FlyGyro"); if bg then bg:Destroy() end
        local hum = char:FindFirstChildOfClass("Humanoid")
        -- Only restore PlatformStand if we actually set it (i.e. player was NOT seated when flight enabled)
        if hum and not getgenv().flightWasSeated then
            hum.PlatformStand = false
        end
    end
    getgenv().flyVelocity     = nil
    getgenv().bodyGyro        = nil
    getgenv().flightWasSeated = nil
end

local function updateFlight()
    if not getgenv().flying or not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not getgenv().flyVelocity or not getgenv().flyVelocity.Parent then
        enableFlight(); return
    end
    if getgenv().flyVelocity and getgenv().bodyGyro then
        local sprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        local speed = getgenv().flightSpeed * (sprinting and 1.75 or 1)
        local mv = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector  * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector  * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then mv = mv + Vector3.new(0,  speed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then mv = mv - Vector3.new(0,  speed, 0) end
        getgenv().flyVelocity.Velocity = mv
        getgenv().bodyGyro.CFrame      = Camera.CFrame
    end
end

getgenv().FlightButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().flightEnabled = not getgenv().flightEnabled
    if getgenv().flightEnabled then
        getgenv().FlightButton.Text = "Flight: ON"
        getgenv().FlightButton.BackgroundColor3 = getgenv().COL_ON
        local char = LocalPlayer.Character
        if not (char and char:FindFirstChild("HumanoidRootPart")) and getgenv().Utils then
            getgenv().Utils:Notify("Flight", "Character not ready yet — will start once it loads.", Color3.fromRGB(255, 160, 0))
        end
        enableFlight()
    else
        getgenv().FlightButton.Text = "Flight: OFF"
        getgenv().FlightButton.BackgroundColor3 = getgenv().COL_OFF
        disableFlight()
    end
end)

if getgenv().BindPanelButton and getgenv().FlightSettingsFrame then
    getgenv().BindPanelButton(getgenv().FlightButton, getgenv().FlightSettingsFrame)
end

if getgenv().FlightModeBtn then
    getgenv().FlightModeBtn.MouseButton1Click:Connect(function()
        getgenv().flightSoftMode = not getgenv().flightSoftMode
        getgenv().FlightModeBtn.Text = "Mode: " .. (getgenv().flightSoftMode and "Soft (Collides)" or "Hard (Noclip-like)")
        getgenv().FlightModeBtn.BackgroundColor3 = getgenv().flightSoftMode and getgenv().COL_ON or getgenv().COL_OFF
        if getgenv().flyVelocity then
            if getgenv().flightSoftMode then
                getgenv().flyVelocity.MaxForce = Vector3.new(9000, 9000, 9000)
                getgenv().flyVelocity.P = 3000
            else
                getgenv().flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                getgenv().flyVelocity.P = 50000
            end
        end
    end)
end

getgenv().updateFlight  = updateFlight
getgenv().disableFlight = disableFlight
getgenv().enableFlight  = enableFlight
