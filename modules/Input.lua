local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ RAW INPUT & SLIDER LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1910 - 2133

local function updateSlider(slider, label, labelText, min, max, valKey, isFloat)
    local mousePos = UserInputService:GetMouseLocation()
    local sliderPos = slider.AbsolutePosition
    local sliderSize = slider.AbsoluteSize
    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
    
    local val = min + (relativeX * (max - min))
    if not isFloat then val = math.floor(val) end
    getgenv()[valKey] = val
    
    label.Text = labelText .. (isFloat and string.format("%.1f", val) or tostring(val)) .. (valKey == "currentFOV" and "°" or (valKey == "speedMultiplier" and "x" or ""))
    
    local fill = slider:FindFirstChild("Fill")
    if not fill then
        fill = Instance.new("Frame"); fill.Name = "Fill"; fill.Parent = slider; fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0); fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)
    end
    fill.Size = UDim2.new(relativeX, 0, 1, 0)
    
    -- Feature specific updates
    if valKey == "speedMultiplier" and getgenv().speedhackEnabled and getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if valKey == "currentFOV" and getgenv().fovChangerEnabled then workspace.CurrentCamera.FieldOfView = val end
    if valKey == "reachDistance" and getgenv().reachIndicator then getgenv().reachIndicator.CFrame = CFrame.new(0, 0, -val) end
    if valKey == "hitboxSize" and getgenv().hitboxEnabled and getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
end

-- Mouse Down Connections
getgenv().ESPDistanceSlider.MouseButton1Down:Connect(function() getgenv().draggingESPDistance = true end)
getgenv().SpeedSlider.MouseButton1Down:Connect(function() getgenv().draggingSpeed = true end)
getgenv().FOVSlider.MouseButton1Down:Connect(function() getgenv().draggingFOV = true end)
getgenv().FollowDistanceSlider.MouseButton1Down:Connect(function() getgenv().draggingFollowDistance = true end)
getgenv().FollowHeightSlider.MouseButton1Down:Connect(function() getgenv().draggingFollowHeight = true end)
getgenv().ReachDistSlider.MouseButton1Down:Connect(function() getgenv().draggingReachDist = true end)
getgenv().HitboxSizeSlider.MouseButton1Down:Connect(function() getgenv().draggingHitboxSize = true end)
getgenv().FlightSpeedSlider.MouseButton1Down:Connect(function() getgenv().draggingFlightSpeed = true end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        getgenv().draggingESPDistance = false; getgenv().draggingSpeed = false; getgenv().draggingFOV = false
        getgenv().draggingFollowDistance = false; getgenv().draggingFollowHeight = false; getgenv().draggingReachDist = false
        getgenv().draggingHitboxSize = false; getgenv().draggingFlightSpeed = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if getgenv().draggingESPDistance then updateSlider(getgenv().ESPDistanceSlider, getgenv().ESPDistanceLabel, "Distance: ", 100, 2100, "espDrawDistance") end
        if getgenv().draggingSpeed then updateSlider(getgenv().SpeedSlider, getgenv().SpeedLabel, "Speed Multiplier: ", 0.5, 4.5, "speedMultiplier", true) end
        if getgenv().draggingFOV then updateSlider(getgenv().FOVSlider, getgenv().FOVLabel, "FOV: ", 20, 120, "currentFOV") end
        if getgenv().draggingFollowDistance then updateSlider(getgenv().FollowDistanceSlider, getgenv().FollowDistanceLabel, "Distance: ", 1, 21, "followDistance") end
        if getgenv().draggingFollowHeight then updateSlider(getgenv().FollowHeightSlider, getgenv().FollowHeightLabel, "Height: ", -5, 5, "followHeight") end
        if getgenv().draggingReachDist then updateSlider(getgenv().ReachDistSlider, getgenv().ReachDistLabel, "Reach Distance: ", 5, 50, "reachDistance") end
        if getgenv().draggingHitboxSize then updateSlider(getgenv().HitboxSizeSlider, getgenv().HitboxSizeLabel, "Hitbox Size: ", 4, 30, "hitboxSize") end
        if getgenv().draggingFlightSpeed then updateSlider(getgenv().FlightSpeedSlider, getgenv().FlightSpeedLabel, "Flight Speed: ", 10, 300, "flightSpeed") end
    end
end)

-- Teleport functionality (Ctrl+Click)
Mouse.Button1Down:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and getgenv().Utils and getgenv().Utils.TeleportToMouse then
        getgenv().Utils.TeleportToMouse()
    end
end)
