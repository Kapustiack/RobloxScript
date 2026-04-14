local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ RAW ESP LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1226 - 1570

getgenv().ESPContainer = Instance.new("Folder")
getgenv().ESPContainer.Name = "ESPContainer"; getgenv().ESPContainer.Parent = getgenv().ScreenGui

local function createESP(player)
    if not getgenv().espEnabled or not getgenv().scriptEnabled then return end
    local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local box = getgenv().ESPContainer:FindFirstChild(player.Name .. "_Box") or Instance.new("BoxHandleAdornment")
    box.Name = player.Name .. "_Box"; box.Parent = getgenv().ESPContainer; box.Size = Vector3.new(4, 5, 2); box.Color3 = Color3.fromRGB(220, 60, 60); box.Transparency = 0.65; box.AlwaysOnTop = true; box.ZIndex = 10; box.Adornee = char.HumanoidRootPart; box.Visible = getgenv().espShowBoxes and not getgenv().espUse2DBoxes

    local box2D = getgenv().ScreenGui:FindFirstChild(player.Name .. "_2DBox") or Instance.new("Frame")
    box2D.Name = player.Name .. "_2DBox"; box2D.Parent = getgenv().ScreenGui; box2D.BackgroundTransparency = 1; box2D.BorderSizePixel = 0; box2D.Visible = false
    local function makeL(n, p, s) local l = box2D:FindFirstChild(n) or Instance.new("Frame"); l.Name = n; l.Parent = box2D; l.BackgroundColor3 = Color3.fromRGB(255, 0, 0); l.BorderSizePixel = 0; l.Position = p; l.Size = s; return l end
    makeL("T", UDim2.new(0,0,0,0), UDim2.new(1,0,0,2)); makeL("B", UDim2.new(0,0,1,-2), UDim2.new(1,0,0,2)); makeL("L", UDim2.new(0,0,0,0), UDim2.new(0,2,1,0)); makeL("R", UDim2.new(1,-2,0,0), UDim2.new(0,2,1,0))

    local nameL = getgenv().ScreenGui:FindFirstChild(player.Name .. "_Name") or Instance.new("TextLabel")
    nameL.Name = player.Name .. "_Name"; nameL.Parent = getgenv().ScreenGui; nameL.BackgroundTransparency = 0.5; nameL.BackgroundColor3 = Color3.new(0,0,0); nameL.TextColor3 = Color3.new(1,1,1); nameL.Font = Enum.Font.GothamBold; nameL.TextSize = 14; nameL.Size = UDim2.new(0, 100, 0, 20); nameL.AnchorPoint = Vector2.new(0.5, 1); nameL.Visible = false; Instance.new("UICorner", nameL).CornerRadius = UDim.new(0, 4)

    local distL = getgenv().ScreenGui:FindFirstChild(player.Name .. "_Distance") or Instance.new("TextLabel")
    distL.Name = player.Name .. "_Distance"; distL.Parent = getgenv().ScreenGui; distL.BackgroundTransparency = 0.5; distL.BackgroundColor3 = Color3.new(0,0,0); distL.TextColor3 = Color3.fromRGB(255, 255, 0); distL.Font = Enum.Font.Gotham; distL.TextSize = 12; distL.Size = UDim2.new(0, 80, 0, 16); distL.AnchorPoint = Vector2.new(0.5, 0); distL.Visible = false; Instance.new("UICorner", distL).CornerRadius = UDim.new(0, 4)
end

local function clearESPForPlayer(p)
    local parts = {p.Name.."_Name", p.Name.."_Distance", p.Name.."_2DBox"}
    for _, n in pairs(parts) do local o = getgenv().ScreenGui:FindFirstChild(n); if o then o:Destroy() end end
    local b3 = getgenv().ESPContainer:FindFirstChild(p.Name .. "_Box"); if b3 then b3:Destroy() end
end

local function updateESP()
    if not getgenv().espEnabled or not getgenv().scriptEnabled then 
        for _, v in pairs(getgenv().ESPContainer:GetChildren()) do v:Destroy() end
        for _, p in pairs(Players:GetPlayers()) do clearESPForPlayer(p) end
        return 
    end
    local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart; local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist <= getgenv().espDrawDistance then
                local nameL = getgenv().ScreenGui:FindFirstChild(p.Name .. "_Name")
                if not nameL then createESP(p); nameL = getgenv().ScreenGui:FindFirstChild(p.Name .. "_Name") end
                local distL, b2d, b3d = getgenv().ScreenGui:FindFirstChild(p.Name .. "_Distance"), getgenv().ScreenGui:FindFirstChild(p.Name .. "_2DBox"), getgenv().ESPContainer:FindFirstChild(p.Name .. "_Box")
                local screenCenter, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local screenHead, onHead = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local screenFeet, onFeet = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                if onScreen and screenCenter.Z > 0 and onHead and onFeet then
                    local boxH = math.abs(screenHead.Y - screenFeet.Y); local boxW = math.max(boxH * 0.5, 20)
                    local cX, tY = screenCenter.X, math.min(screenHead.Y, screenFeet.Y)
                    if nameL then nameL.Position = UDim2.new(0, cX, 0, tY - 2); nameL.Visible = getgenv().espShowNames; nameL.Text = p.Name end
                    if distL then distL.Position = UDim2.new(0, cX, 0, tY + boxH + 2); distL.Visible = getgenv().espShowDistance; distL.Text = math.floor(dist) .. " studs" end
                    if b2d then b2d.Position = UDim2.new(0, cX - boxW/2, 0, tY); b2d.Size = UDim2.new(0, boxW, 0, boxH); b2d.Visible = getgenv().espUse2DBoxes end
                else if nameL then nameL.Visible=false end; if distL then distL.Visible=false end; if b2d then b2d.Visible=false end end
                if b3d then b3d.Visible = getgenv().espShowBoxes and not getgenv().espUse2DBoxes end
            else clearESPForPlayer(p) end
        elseif p ~= LocalPlayer then clearESPForPlayer(p) end
    end
end

-- Toggles
getgenv().ESPButton.MouseButton1Click:Connect(function()
    getgenv().espEnabled = not getgenv().espEnabled
    getgenv().ESPButton.Text = "ESP: " .. (getgenv().espEnabled and "ON" or "OFF")
    getgenv().ESPButton.BackgroundColor3 = getgenv().espEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().espEnabled then for _, v in pairs(getgenv().ESPContainer:GetChildren()) do v:Destroy() end; for _, p in pairs(Players:GetPlayers()) do clearESPForPlayer(p) end end
end)
getgenv().ESPButton.MouseButton2Click:Connect(function() getgenv().TogglePanel(getgenv().ESPSettingsFrame) end)

getgenv().ESPShowNamesBtn.MouseButton1Click:Connect(function()
    getgenv().espShowNames = not getgenv().espShowNames; getgenv().ESPShowNamesBtn.Text = "Names: " .. (getgenv().espShowNames and "ON" or "OFF"); getgenv().ESPShowNamesBtn.BackgroundColor3 = getgenv().espShowNames and getgenv().COL_ON or getgenv().COL_OFF
end)
getgenv().ESPShowDistBtn.MouseButton1Click:Connect(function()
    getgenv().espShowDistance = not getgenv().espShowDistance; getgenv().ESPShowDistBtn.Text = "Distance: " .. (getgenv().espShowDistance and "ON" or "OFF"); getgenv().ESPShowDistBtn.BackgroundColor3 = getgenv().espShowDistance and getgenv().COL_ON or getgenv().COL_OFF
end)
getgenv().ESPShowBoxesBtn.MouseButton1Click:Connect(function()
    getgenv().espShowBoxes = not getgenv().espShowBoxes; getgenv().ESPShowBoxesBtn.Text = "3D Boxes: " .. (getgenv().espShowBoxes and "ON" or "OFF"); getgenv().ESPShowBoxesBtn.BackgroundColor3 = getgenv().espShowBoxes and getgenv().COL_ON or getgenv().COL_OFF
end)
getgenv().ESP2DBoxesBtn.MouseButton1Click:Connect(function()
    getgenv().espUse2DBoxes = not getgenv().espUse2DBoxes; getgenv().ESP2DBoxesBtn.Text = "2D Boxes: " .. (getgenv().espUse2DBoxes and "ON" or "OFF"); getgenv().ESP2DBoxesBtn.BackgroundColor3 = getgenv().espUse2DBoxes and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().updateESP = updateESP
