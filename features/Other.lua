local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ RAW OTHER LOGIC - Migrated 1:1 from rb.lua ]]
-- Noclip (904-937), InfJump (939-959), NoDamage (961-1029), Flight (1458-1543)

local function enableFlight()
    if not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    getgenv().flying = true; local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    
    local fv = char.HumanoidRootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
    fv.Name = "FlyVelocity"; fv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    fv.Velocity = Vector3.new(0, 0, 0); fv.Parent = char.HumanoidRootPart; getgenv().flyVelocity = fv
    
    local bg = char.HumanoidRootPart:FindFirstChild("FlyGyro") or Instance.new("BodyGyro")
    bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000; bg.CFrame = char.HumanoidRootPart.CFrame; bg.Parent = char.HumanoidRootPart; getgenv().bodyGyro = bg
end

local function disableFlight()
    getgenv().flying = false; local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local fv = char.HumanoidRootPart:FindFirstChild("FlyVelocity"); if fv then fv:Destroy() end
        local bg = char.HumanoidRootPart:FindFirstChild("FlyGyro"); if bg then bg:Destroy() end
        local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = false end
    end
    getgenv().flyVelocity = nil; getgenv().bodyGyro = nil
end

local function checkFlight()
    if getgenv().flightEnabled and getgenv().scriptEnabled then
        local char = LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        if not getgenv().flyVelocity or not getgenv().flyVelocity.Parent or getgenv().flyVelocity.Parent ~= char.HumanoidRootPart then
            enableFlight()
        end
    elseif not getgenv().flightEnabled and getgenv().flying then
        disableFlight()
    end
end

local function updateFlight()
    if not getgenv().flying or not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if getgenv().flyVelocity and getgenv().bodyGyro then
        local mv = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, getgenv().flightSpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0, getgenv().flightSpeed, 0) end
        getgenv().flyVelocity.Velocity = mv; getgenv().bodyGyro.CFrame = Camera.CFrame
    end
end

getgenv().FlightButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().flightEnabled = not getgenv().flightEnabled
    if getgenv().flightEnabled then
        getgenv().FlightButton.Text = "Flight: ON"; getgenv().FlightButton.BackgroundColor3 = getgenv().COL_ON
        enableFlight()
    else
        getgenv().FlightButton.Text = "Flight: OFF"; getgenv().FlightButton.BackgroundColor3 = getgenv().COL_OFF
        disableFlight()
    end
end)

-- InfJump & Noclip restoration (already 1:1 in prev step)
getgenv().NoclipButton.MouseButton1Click:Connect(function()
    getgenv().noclipEnabled = not getgenv().noclipEnabled
    getgenv().NoclipButton.Text = "Noclip: " .. (getgenv().noclipEnabled and "ON" or "OFF")
    getgenv().NoclipButton.BackgroundColor3 = getgenv().noclipEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noclipEnabled then
        if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect() end
        getgenv().noclipConnection = RunService.Stepped:Connect(function() if getgenv().noclipEnabled then local c = LocalPlayer.Character; if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end end)
    else if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end end
end)

getgenv().InfiniteJumpButton.MouseButton1Click:Connect(function()
    getgenv().infiniteJumpEnabled = not getgenv().infiniteJumpEnabled
    getgenv().InfiniteJumpButton.Text = "Inf Jump: " .. (getgenv().infiniteJumpEnabled and "ON" or "OFF")
    getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().infiniteJumpEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().infiniteJumpEnabled then
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect() end
        getgenv().infiniteJumpConnection = UserInputService.JumpRequest:Connect(function() if getgenv().infiniteJumpEnabled then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState("Jumping") end end end)
    else if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect(); getgenv().infiniteJumpConnection = nil end end
end)

getgenv().updateFlight = updateFlight
getgenv().checkFlight = checkFlight
