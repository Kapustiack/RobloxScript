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

    local textGui = getgenv().ScreenGui:FindFirstChild(player.Name .. "_ESPText") or Instance.new("BillboardGui")
    textGui.Name = player.Name .. "_ESPText"; textGui.AlwaysOnTop = true; textGui.Size = UDim2.new(0, 200, 0, 50); textGui.Adornee = char.HumanoidRootPart; textGui.Parent = getgenv().ScreenGui; textGui.ClipsDescendants = false
    local label = textGui:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Size = UDim2.new(1, 0, 1, 0); label.Font = Enum.Font.GothamBold; label.TextColor3 = Color3.new(1, 1, 1); label.TextSize = 13; label.Parent = textGui; label.TextStrokeTransparency = 0.4
end

local function updateESP()
    if not getgenv().espEnabled or not getgenv().scriptEnabled then 
        for _, v in pairs(getgenv().ESPContainer:GetChildren()) do v:Destroy() end
        for _, player in pairs(Players:GetPlayers()) do local g = getgenv().ScreenGui:FindFirstChild(player.Name .. "_ESPText"); if g then g:Destroy() end end
        return 
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist <= getgenv().espDrawDistance then
                    createESP(player)
                    local gui = getgenv().ScreenGui:FindFirstChild(player.Name .. "_ESPText")
                    if gui then
                        local l = gui:FindFirstChildOfClass("TextLabel")
                        if l then
                            local str = ""
                            if getgenv().espShowNames then str = player.DisplayName or player.Name end
                            if getgenv().espShowDistance then str = str .. (str=="" and "" or " ") .. "[" .. math.floor(dist) .. "m]" end
                            l.Text = str
                        end
                    end
                else
                    local b = getgenv().ESPContainer:FindFirstChild(player.Name .. "_Box"); if b then b:Destroy() end
                    local g = getgenv().ScreenGui:FindFirstChild(player.Name .. "_ESPText"); if g then g:Destroy() end
                end
            end
        else
            local b = getgenv().ESPContainer:FindFirstChild(player.Name .. "_Box"); if b then b:Destroy() end
            local g = getgenv().ScreenGui:FindFirstChild(player.Name .. "_ESPText"); if g then g:Destroy() end
        end
    end
end

getgenv().ESPButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().espEnabled = not getgenv().espEnabled
    getgenv().ESPButton.Text = "ESP: " .. (getgenv().espEnabled and "ON" or "OFF")
    getgenv().ESPButton.BackgroundColor3 = getgenv().espEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().espEnabled then 
        for _, v in pairs(getgenv().ESPContainer:GetChildren()) do v:Destroy() end 
        for _, player in pairs(Players:GetPlayers()) do local g = getgenv().ScreenGui:FindFirstChild(player.Name .. "_ESPText"); if g then g:Destroy() end end
    end
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

getgenv().updateESP = updateESP
getgenv().createESP = createESP
