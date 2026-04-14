local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ RAW ESP LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1403 - 1570, 2310 - 2338, 2699 - 2723

getgenv().ESPContainer = Instance.new("Folder")
getgenv().ESPContainer.Name = "ESPContainer"; getgenv().ESPContainer.Parent = getgenv().ScreenGui

local function clearESP()
    for _, item in pairs(getgenv().ESPContainer:GetChildren()) do item:Destroy() end
end

local function createESP(player)
    if not getgenv().espEnabled or not getgenv().scriptEnabled or player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if getgenv().espShowBoxes and not getgenv().espUse2DBoxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_Box_" .. player.Name
        box.Size = char:GetExtentsSize()
        box.AlwaysOnTop = true; box.ZIndex = 5; box.Transparency = 0.6; box.Color3 = Color3.fromRGB(255, 255, 255); box.Adornee = hrp; box.Parent = getgenv().ESPContainer
    end

    local textGui = Instance.new("BillboardGui")
    textGui.Name = "ESP_Text_" .. player.Name
    textGui.AlwaysOnTop = true; textGui.Size = UDim2.new(0, 200, 0, 50); textGui.Adornee = hrp; textGui.Parent = getgenv().ESPContainer
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Size = UDim2.new(1, 0, 1, 0); label.Font = Enum.Font.GothamBold; label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 14; label.Parent = textGui
end

local function updateESP()
    if not getgenv().espEnabled or not getgenv().scriptEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myChar.HumanoidRootPart.Position).Magnitude
                if d <= getgenv().espDrawDistance then
                    local gui = getgenv().ESPContainer:FindFirstChild("ESP_Text_" .. player.Name)
                    if not gui then createESP(player); gui = getgenv().ESPContainer:FindFirstChild("ESP_Text_" .. player.Name) end
                    if gui then
                        local l = gui:FindFirstChildOfClass("TextLabel")
                        if l then
                            local s = ""
                            if getgenv().espShowNames then s = player.Name end
                            if getgenv().espShowDistance then s = s .. (s == "" and "" or " ") .. "[" .. math.floor(d) .. "m]" end
                            l.Text = s
                        end
                    end
                else
                    local gui = getgenv().ESPContainer:FindFirstChild("ESP_Text_" .. player.Name)
                    if gui then gui:Destroy() end
                    local box = getgenv().ESPContainer:FindFirstChild("ESP_Box_" .. player.Name)
                    if box then box:Destroy() end
                end
            end
        end
    end
end

getgenv().ESPButton.MouseButton1Click:Connect(function()
    getgenv().espEnabled = not getgenv().espEnabled
    getgenv().ESPButton.Text = "ESP: " .. (getgenv().espEnabled and "ON" or "OFF")
    getgenv().ESPButton.BackgroundColor3 = getgenv().espEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().espEnabled then clearESP() end
end)

getgenv().ESPButton.MouseButton2Click:Connect(function()
    getgenv().ESPSettingsFrame.Visible = not getgenv().ESPSettingsFrame.Visible
end)

getgenv().ESPShowNamesBtn.MouseButton1Click:Connect(function()
    getgenv().espShowNames = not getgenv().espShowNames
    getgenv().ESPShowNamesBtn.Text = "Names: " .. (getgenv().espShowNames and "ON" or "OFF")
    getgenv().ESPShowNamesBtn.BackgroundColor3 = getgenv().espShowNames and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().ESPShowDistBtn.MouseButton1Click:Connect(function()
    getgenv().espShowDistance = not getgenv().espShowDistance
    getgenv().ESPShowDistBtn.Text = "Distance: " .. (getgenv().espShowDistance and "ON" or "OFF")
    getgenv().ESPShowDistBtn.BackgroundColor3 = getgenv().espShowDistance and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().ESPShowBoxesBtn.MouseButton1Click:Connect(function()
    getgenv().espShowBoxes = not getgenv().espShowBoxes
    getgenv().ESPShowBoxesBtn.Text = "3D Boxes: " .. (getgenv().espShowBoxes and "ON" or "OFF")
    getgenv().ESPShowBoxesBtn.BackgroundColor3 = getgenv().espShowBoxes and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().ESP2DBoxesBtn.MouseButton1Click:Connect(function()
    getgenv().espUse2DBoxes = not getgenv().espUse2DBoxes
    getgenv().ESP2DBoxesBtn.Text = "2D Boxes: " .. (getgenv().espUse2DBoxes and "ON" or "OFF")
    getgenv().ESP2DBoxesBtn.BackgroundColor3 = getgenv().espUse2DBoxes and getgenv().COL_ON or getgenv().COL_OFF
end)

getgenv().clearESP = clearESP
getgenv().createESP = createESP
getgenv().updateESP = updateESP
