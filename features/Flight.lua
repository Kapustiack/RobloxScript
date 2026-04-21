-- [[ FLIGHT — Fully wired, 1:1 from rb.lua ]]
-- CHANGE: enableFlight now preserves seat state so toggling flight back on
--         does NOT eject the character from whatever they are sitting in.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Helper: returns the SeatPart the humanoid is currently sitting in, or nil
local function getCurrentSeat()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then return hum.SeatPart end
    return nil
end

local function enableFlight()
    if not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    getgenv().flying = true

    local hum = char:FindFirstChildOfClass("Humanoid")
    local seat = getCurrentSeat()

    -- SEAT FIX: Only set PlatformStand if the character is NOT already seated.
    -- Setting PlatformStand=true while seated breaks the seat weld and ejects
    -- the character. We skip it here; the BodyVelocity will still give control.
    if hum and not seat then
        hum.PlatformStand = true
    end

    -- Remember whether we were seated when flight was enabled so disableFlight
    -- can restore PlatformStand correctly.
    getgenv().flightWasSeated = (seat ~= nil)

    local fv = char.HumanoidRootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
    fv.Name = "FlyVelocity"; fv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
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
        -- SEAT FIX: Only restore PlatformStand=false if we actually set it to true.
        -- If we were seated when flight enabled, we never changed PlatformStand,
        -- so we must not touch it now (that would also eject from seat).
        if hum and not getgenv().flightWasSeated then
            hum.PlatformStand = false
        end
    end
    getgenv().flyVelocity = nil
    getgenv().bodyGyro = nil
    getgenv().flightWasSeated = nil
end

local function updateFlight()
    if not getgenv().flying or not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Re-create BodyVelocity if it got deleted (respawn, anti-cheat, etc.)
    if not getgenv().flyVelocity or not getgenv().flyVelocity.Parent then
        enableFlight(); return
    end

    if getgenv().flyVelocity and getgenv().bodyGyro then
        local mv = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, getgenv().flightSpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0, getgenv().flightSpeed, 0) end
        getgenv().flyVelocity.Velocity = mv
        getgenv().bodyGyro.CFrame = Camera.CFrame
    end
end

-- FlightButton: left click = toggle, right click = open Flight Settings
getgenv().FlightButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().flightEnabled = not getgenv().flightEnabled
    if getgenv().flightEnabled then
        getgenv().FlightButton.Text = "Flight: ON"
        getgenv().FlightButton.BackgroundColor3 = getgenv().COL_ON
        enableFlight()
    else
        getgenv().FlightButton.Text = "Flight: OFF"
        getgenv().FlightButton.BackgroundColor3 = getgenv().COL_OFF
        disableFlight()
    end
end)

getgenv().FlightButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().FlightSettingsFrame) end
end)

-- Export for main.lua heartbeat loop and destroyScript
getgenv().updateFlight = updateFlight
getgenv().disableFlight = disableFlight
getgenv().enableFlight = enableFlight