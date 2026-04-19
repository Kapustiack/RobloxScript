-- [[ INPUT — Sliders + Mouse. 1:1 from rb.lua with robust Teleport ]]
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function updateSlider(slider, label, labelText, min, max, valKey, isFloat)
    local mousePos = UserInputService:GetMouseLocation()
    local sliderPos = slider.AbsolutePosition
    local sliderSize = slider.AbsoluteSize
    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)

    local val = min + (relativeX * (max - min))
    if not isFloat then val = math.floor(val + 0.5) end
    getgenv()[valKey] = val

    local suffix = ""
    if valKey == "currentFOV" then suffix = "°"
    elseif valKey == "speedMultiplier" then suffix = "x"
    end
    label.Text = labelText .. (isFloat and string.format("%.1f", val) or tostring(val)) .. suffix

    local fill = slider:FindFirstChild("Fill")
    if not fill then
        fill = Instance.new("Frame"); fill.Name = "Fill"; fill.Parent = slider
        fill.BackgroundColor3 = Color3.fromRGB(80, 200, 120); fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)
    end
    fill.Size = UDim2.new(relativeX, 0, 1, 0)

    if valKey == "speedMultiplier" and getgenv().speedhackEnabled and getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if valKey == "currentFOV" and getgenv().fovChangerEnabled then workspace.CurrentCamera.FieldOfView = val end
    if valKey == "hitboxSize" and getgenv().hitboxEnabled and getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
end

-- ── Slider drag start ─────────────────────────────────────────────
getgenv().ESPDistanceSlider.MouseButton1Down:Connect(function()    getgenv().draggingESPDistance    = true end)
getgenv().SpeedSlider.MouseButton1Down:Connect(function()          getgenv().draggingSpeed          = true end)
getgenv().FOVSlider.MouseButton1Down:Connect(function()            getgenv().draggingFOV            = true end)
getgenv().FollowDistanceSlider.MouseButton1Down:Connect(function()  getgenv().draggingFollowDistance = true end)
getgenv().FollowHeightSlider.MouseButton1Down:Connect(function()   getgenv().draggingFollowHeight   = true end)
getgenv().ReachDistSlider.MouseButton1Down:Connect(function()      getgenv().draggingReachDist      = true end)
getgenv().HitboxSizeSlider.MouseButton1Down:Connect(function()     getgenv().draggingHitboxSize     = true end)
getgenv().FlightSpeedSlider.MouseButton1Down:Connect(function()    getgenv().draggingFlightSpeed    = true end)
getgenv().WallhackTranspSlider.MouseButton1Down:Connect(function() getgenv().draggingWallhackTransp = true end)
getgenv().FreeCamSpeedSlider.MouseButton1Down:Connect(function()   getgenv().draggingFreeCamSpeed   = true end)
getgenv().FreeCamFOVSlider.MouseButton1Down:Connect(function()     getgenv().draggingFreeCamFOV     = true end)
getgenv().LowGravitySlider.MouseButton1Down:Connect(function()     getgenv().draggingLowGravity     = true end)

-- ── Slider drag end ───────────────────────────────────────────────
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        getgenv().draggingESPDistance    = false; getgenv().draggingSpeed          = false; getgenv().draggingFOV            = false; getgenv().draggingFollowDistance = false; getgenv().draggingFollowHeight   = false; getgenv().draggingReachDist      = false; getgenv().draggingHitboxSize     = false; getgenv().draggingFlightSpeed    = false; getgenv().draggingWallhackTransp = false; getgenv().draggingFreeCamSpeed   = false; getgenv().draggingFreeCamFOV     = false; getgenv().draggingLowGravity     = false
    end
end)

-- ── Slider update ────────────────────────────────────────────────
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if getgenv().draggingESPDistance then updateSlider(getgenv().ESPDistanceSlider, getgenv().ESPDistanceLabel, "Distance: ", 100, 30000, "espDrawDistance") end
    if getgenv().draggingSpeed then updateSlider(getgenv().SpeedSlider, getgenv().SpeedLabel, "Speed Multiplier: ", 0.5, 10, "speedMultiplier", true) end
    if getgenv().draggingFOV then updateSlider(getgenv().FOVSlider, getgenv().FOVLabel, "FOV: ", 20, 120, "currentFOV") end
    if getgenv().draggingFollowDistance then updateSlider(getgenv().FollowDistanceSlider, getgenv().FollowDistanceLabel, "Distance: ", 1, 21, "followDistance") end
    if getgenv().draggingFollowHeight then updateSlider(getgenv().FollowHeightSlider, getgenv().FollowHeightLabel, "Height: ", -5, 5, "followHeight", true) end
    if getgenv().draggingReachDist then updateSlider(getgenv().ReachDistSlider, getgenv().ReachDistLabel, "Reach Distance: ", 5, 50, "reachDistance") end
    if getgenv().draggingHitboxSize then updateSlider(getgenv().HitboxSizeSlider, getgenv().HitboxSizeLabel, "Hitbox Size: ", 4, 30, "hitboxSize") end
    if getgenv().draggingFlightSpeed then updateSlider(getgenv().FlightSpeedSlider, getgenv().FlightSpeedLabel, "Flight Speed: ", 10, 1500, "flightSpeed") end
    if getgenv().draggingFreeCamSpeed then updateSlider(getgenv().FreeCamSpeedSlider, getgenv().FreeCamSpeedLabel, "Fly Speed: ", 5, 300, "freeCamSpeed") end
    if getgenv().draggingFreeCamFOV then
        updateSlider(getgenv().FreeCamFOVSlider, getgenv().FreeCamFOVLabel, "FreeCam FOV: ", 20, 120, "freeCamFOV")
        if getgenv().freeCamEnabled and getgenv().freeCamMode ~= "minimap" then workspace.CurrentCamera.FieldOfView = getgenv().freeCamFOV end
    end
    if getgenv().draggingLowGravity then
        updateSlider(getgenv().LowGravitySlider, getgenv().LowGravityLabel, "Gravity: ", 5, 200, "lowGravityValue")
        if getgenv().lowGravityEnabled then workspace.Gravity = getgenv().lowGravityValue end
    end
    if getgenv().draggingWallhackTransp then
        local sl = getgenv().WallhackTranspSlider; local mPos = UserInputService:GetMouseLocation()
        local relX = math.clamp((mPos.X - sl.AbsolutePosition.X) / sl.AbsoluteSize.X, 0, 1)
        local transp = math.floor((0.1 + relX * 0.8) * 100 + 0.5) / 100
        getgenv().wallhackTransparency = transp; getgenv().WallhackTranspLabel.Text = "Transparency: " .. math.floor(transp * 100) .. "%"
        local fill = sl:FindFirstChild("Fill") or Instance.new("Frame", sl)
        fill.Name = "Fill"; fill.BackgroundColor3 = Color3.fromRGB(80, 200, 120); fill.BorderSizePixel = 0; fill.Size = UDim2.new(relX, 0, 1, 0)
    end
end)

-- ── ROBUST INPUT SYSTEM (Ctrl+Click & Click Check) ────────────────
UserInputService.InputBegan:Connect(function(input, gp)
    -- CTR+CLICK TELEPORT (Highest reliability via UserInputService)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if ctrlDown and getgenv().Utils and getgenv().Utils.TeleportToMouse then
            getgenv().Utils:TeleportToMouse()
            return
        end
    end

    -- CLICK CHECK (For Follow)
    if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if getgenv().clickCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
            getgenv().leftMouseClicked = true; getgenv().clickLingerUntil = 0
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if getgenv().clickCheckEnabled and getgenv().leftMouseClicked then
            getgenv().leftMouseClicked = false; getgenv().clickLingerUntil = os.clock() + 0.45
        else
            getgenv().leftMouseClicked = false
        end
    end
end)
