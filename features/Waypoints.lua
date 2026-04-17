-- [[ WAYPOINTS ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Internal storage for waypoints. Format: { name = "Spot 1", cf = CFrame }
-- For now, just save them in memory.
getgenv().savedWaypoints = getgenv().savedWaypoints or {}

local function renderWaypoints()
    local list = getgenv().WaypointsList
    if not list then return end

    -- Clear old children
    for _, c in pairs(list:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local ord = 0
    for i, wp in ipairs(getgenv().savedWaypoints) do
        ord += 1
        local b = Instance.new("TextButton", list)
        b.LayoutOrder = ord
        b.Size = UDim2.new(1, -6, 0, 26)
        b.BorderSizePixel = 0; b.Font = Enum.Font.Gotham; b.TextSize = 11
        b.TextColor3 = getgenv().COL_TXT
        b.BackgroundColor3 = getgenv().COL_OFF
        b.Text = "Go to: " .. wp.name
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        
        -- Delete button
        local delBtn = Instance.new("TextButton", b)
        delBtn.Size = UDim2.new(0, 20, 0, 20)
        delBtn.Position = UDim2.new(1, -24, 0.5, -10)
        delBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        delBtn.Text = "X"; delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 12
        delBtn.BorderSizePixel = 0
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

        b.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            char.HumanoidRootPart.CFrame = wp.cf
            if getgenv().Utils then getgenv().Utils:Notify("Waypoints", "Teleported to " .. wp.name, Color3.fromRGB(80,200,255)) end
        end)

        delBtn.MouseButton1Click:Connect(function()
            table.remove(getgenv().savedWaypoints, i)
            renderWaypoints()
        end)
    end

    local ll = list:FindFirstChildOfClass("UIListLayout")
    if ll then list.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 4) end
end

getgenv().WaypointsButton.MouseButton1Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().WaypointsSettingsFrame) end
    renderWaypoints()
end)

getgenv().WaypointsButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().WaypointsSettingsFrame) end
    renderWaypoints()
end)

getgenv().WaypointSaveBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local wpName = "Point " .. (#getgenv().savedWaypoints + 1)
    table.insert(getgenv().savedWaypoints, {
        name = wpName,
        cf = hrp.CFrame
    })
    
    if getgenv().Utils then 
        getgenv().Utils:Notify("Waypoints", "Saved " .. wpName, Color3.fromRGB(80,200,120)) 
    end
    renderWaypoints()
end)
