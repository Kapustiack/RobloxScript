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
    
    getgenv().flyVelocity = Instance.new("BodyVelocity")
    getgenv().flyVelocity.Name = "FlyVelocity"; getgenv().flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    getgenv().flyVelocity.Velocity = Vector3.new(0, 0, 0); getgenv().flyVelocity.Parent = char.HumanoidRootPart
    
    getgenv().bodyGyro = Instance.new("BodyGyro")
    getgenv().bodyGyro.Name = "FlyGyro"; getgenv().bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    getgenv().bodyGyro.P = 10000; getgenv().bodyGyro.CFrame = char.HumanoidRootPart.CFrame; getgenv().bodyGyro.Parent = char.HumanoidRootPart
end

local function disableFlight()
    getgenv().flying = false; local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if getgenv().flyVelocity then getgenv().flyVelocity:Destroy(); getgenv().flyVelocity = nil end
        if getgenv().bodyGyro then getgenv().bodyGyro:Destroy(); getgenv().bodyGyro = nil end
        local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = false end
    end
end

local function updateFlight()
    if not getgenv().flying or not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if getgenv().flyVelocity and getgenv().bodyGyro then
        local moveVector = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector * getgenv().flightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, getgenv().flightSpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0, getgenv().flightSpeed, 0) end
        getgenv().flyVelocity.Velocity = moveVector; getgenv().bodyGyro.CFrame = Camera.CFrame
    end
end

getgenv().FlightButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().flightEnabled = not getgenv().flightEnabled
    if getgenv().flightEnabled then getgenv().FlightButton.Text = "Flight: ON"; getgenv().FlightButton.BackgroundColor3 = getgenv().COL_ON; enableFlight()
    else getgenv().FlightButton.Text = "Flight: OFF"; getgenv().FlightButton.BackgroundColor3 = getgenv().COL_OFF; disableFlight() end
end)

getgenv().NoclipButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noclipEnabled = not getgenv().noclipEnabled
    if getgenv().noclipEnabled then
        getgenv().NoclipButton.Text = "Noclip: ON"; getgenv().NoclipButton.BackgroundColor3 = getgenv().COL_ON
        getgenv().noclipConnection = RunService.Stepped:Connect(function()
            if getgenv().noclipEnabled and getgenv().scriptEnabled then
                local char = LocalPlayer.Character; if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
            end
        end)
    else
        getgenv().NoclipButton.Text = "Noclip: OFF"; getgenv().NoclipButton.BackgroundColor3 = getgenv().COL_OFF
        if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    end
end)

getgenv().InfiniteJumpButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().infiniteJumpEnabled = not getgenv().infiniteJumpEnabled
    if getgenv().infiniteJumpEnabled then
        getgenv().InfiniteJumpButton.Text = "Inf Jump: ON"; getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().COL_ON
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect() end
        getgenv().infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if getgenv().infiniteJumpEnabled and getgenv().scriptEnabled then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end
        end)
    else
        getgenv().InfiniteJumpButton.Text = "Inf Jump: OFF"; getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().COL_OFF
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect(); getgenv().infiniteJumpConnection = nil end
    end
end)

local function installNoDamageHook()
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return nil end
    pcall(setreadonly, mt, false); local old_ni = rawget(mt, "__newindex")
    if not old_ni then pcall(setreadonly, mt, true); return nil end
    local function hookedNewindex(self, key, value)
        if getgenv().noDamageEnabled and getgenv().scriptEnabled and key == "Health" and typeof(self) == "Instance" and self:IsA("Humanoid") then
            local char = LocalPlayer.Character; local myHum = char and char:FindFirstChildOfClass("Humanoid")
            if myHum and self == myHum and typeof(value) == "number" and value < myHum.MaxHealth and value >= 0 then return old_ni(self, key, myHum.MaxHealth) end
        end
        return old_ni(self, key, value)
    end
    rawset(mt, "__newindex", (newcclosure and newcclosure(hookedNewindex)) or hookedNewindex)
    pcall(setreadonly, mt, true)
    return function() local ok2, mt2 = pcall(getrawmetatable, game); if ok2 and mt2 then pcall(setreadonly, mt2, false); rawset(mt2, "__newindex", old_ni); pcall(setreadonly, mt2, true) end end
end

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noDamageEnabled = not getgenv().noDamageEnabled
    if getgenv().noDamageEnabled then
        getgenv().NoDamageButton.Text = "No Damage: ON"; getgenv().NoDamageButton.BackgroundColor3 = getgenv().COL_ON
        if not getgenv().noDamageRestoreFunc then getgenv().noDamageRestoreFunc = installNoDamageHook() end
        if getgenv().noDamageLoop then getgenv().noDamageLoop:Disconnect() end
        getgenv().noDamageLoop = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        end)
    else
        getgenv().NoDamageButton.Text = "No Damage: OFF"; getgenv().NoDamageButton.BackgroundColor3 = getgenv().COL_OFF
        if getgenv().noDamageLoop then getgenv().noDamageLoop:Disconnect(); getgenv().noDamageLoop = nil end
        if getgenv().noDamageRestoreFunc then pcall(getgenv().noDamageRestoreFunc); getgenv().noDamageRestoreFunc = nil end
    end
end)

getgenv().updateFlight = updateFlight
