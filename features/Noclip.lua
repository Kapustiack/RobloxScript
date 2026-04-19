-- [[ NOCLIP — Assembly-Aware Update ]]
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function enableNoclip()
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect() end
    getgenv().noclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().noclipEnabled or not getgenv().scriptEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- 1. Noclip the Character and all descendants (Tools, Hats, etc.)
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end

        -- 2. Noclip the whole Assembly (Vehicles, connected objects)
        if hrp then
            for _, p in pairs(hrp:GetConnectedParts(true)) do
                if p.CanCollide then p.CanCollide = false end
            end
        end

        -- 3. Explicit Seat/Vehicle Noclip (Ensuring vehicles pass through walls)
        if hum and hum.SeatPart then
            local seat = hum.SeatPart
            if seat:IsA("BasePart") then seat.CanCollide = false end
            
            -- Find the model the seat belongs to (the car/vehicle)
            local vehicle = seat:FindFirstAncestorOfClass("Model")
            if vehicle then
                for _, p in pairs(vehicle:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end
    end)
end

local function disableNoclip()
    getgenv().noclipEnabled = false
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
        -- Note: We don't force collision back on vehicles as they manage their own physics,
        -- but the character will regain collision immediately.
    end
end

getgenv().NoclipButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noclipEnabled = not getgenv().noclipEnabled
    getgenv().NoclipButton.Text = "Noclip: " .. (getgenv().noclipEnabled and "ON" or "OFF")
    getgenv().NoclipButton.BackgroundColor3 = getgenv().noclipEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noclipEnabled then enableNoclip() else disableNoclip() end
end)

getgenv().disableNoclip = disableNoclip
