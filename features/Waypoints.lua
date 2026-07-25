local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().savedWaypoints = getgenv().savedWaypoints or {}

local function renderWaypoints()
    local list = getgenv().WaypointsList
    if not list then return end

    for _, c in pairs(list:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    local ord = 0
    for i, wp in ipairs(getgenv().savedWaypoints) do
        ord = ord + 1
        local row = Instance.new("Frame", list)
        row.Name = "WaypointRow"
        row.LayoutOrder = ord
        row.Size = UDim2.new(1, -6, 0, 26)
        row.BackgroundColor3 = getgenv().COL_OFF
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        local goBtn = Instance.new("TextButton", row)
        goBtn.Name = "GoBtn"
        goBtn.BackgroundTransparency = 1
        goBtn.Size = UDim2.new(1, -50, 1, 0)
        goBtn.Font = Enum.Font.Gotham; goBtn.TextSize = 11; goBtn.TextColor3 = getgenv().COL_TXT
        goBtn.TextXAlignment = Enum.TextXAlignment.Left
        goBtn.Text = "  Go to: " .. wp.name

        local renameBtn = Instance.new("TextButton", row)
        renameBtn.Size = UDim2.new(0, 22, 0, 20)
        renameBtn.Position = UDim2.new(1, -50, 0.5, -10)
        renameBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        renameBtn.Text = "R"; renameBtn.TextColor3 = Color3.new(1, 1, 1)
        renameBtn.Font = Enum.Font.GothamBold; renameBtn.TextSize = 12
        renameBtn.BorderSizePixel = 0
        Instance.new("UICorner", renameBtn).CornerRadius = UDim.new(0, 4)

        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0, 22, 0, 20)
        delBtn.Position = UDim2.new(1, -24, 0.5, -10)
        delBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        delBtn.Text = "X"; delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 12
        delBtn.BorderSizePixel = 0
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

        goBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            char.HumanoidRootPart.CFrame = wp.cf
            if getgenv().Utils then getgenv().Utils:Notify("Waypoints", "Teleported to " .. wp.name, Color3.fromRGB(80, 200, 255)) end
        end)

        renameBtn.MouseButton1Click:Connect(function()
            local editBox = Instance.new("TextBox", row)
            editBox.Size = UDim2.new(1, -50, 1, 0)
            editBox.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
            editBox.BorderSizePixel = 0
            editBox.Font = Enum.Font.Gotham; editBox.TextSize = 11; editBox.TextColor3 = getgenv().COL_TXT
            editBox.Text = wp.name
            editBox.ClearTextOnFocus = false
            Instance.new("UICorner", editBox).CornerRadius = UDim.new(0, 4)
            goBtn.Visible = false
            editBox:CaptureFocus()
            editBox.FocusLost:Connect(function()
                local newName = editBox.Text:match("^%s*(.-)%s*$")
                if newName ~= "" then
                    wp.name = newName
                    if getgenv().saveSettings then getgenv().saveSettings() end
                end
                renderWaypoints()
            end)
        end)

        delBtn.MouseButton1Click:Connect(function()
            -- Compare by identity (not name/cf equality) so duplicate-named
            -- waypoints or renamed ones can't cause the wrong row to delete.
            for idx, wp2 in ipairs(getgenv().savedWaypoints) do
                if wp2 == wp then
                    getgenv().lastDeletedWaypoint = {data = wp2, index = idx}
                    table.remove(getgenv().savedWaypoints, idx)
                    if getgenv().saveSettings then getgenv().saveSettings() end
                    if getgenv().Utils then getgenv().Utils:Notify("Waypoints", "Deleted " .. wp2.name .. " (Undo available)", Color3.fromRGB(255, 160, 0)) end
                    break
                end
            end
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

if getgenv().BindPanelButton and getgenv().WaypointsSettingsFrame then
    getgenv().BindPanelButton(getgenv().WaypointsButton, getgenv().WaypointsSettingsFrame)
    getgenv().WaypointsButton.MouseButton2Click:Connect(renderWaypoints)
    getgenv().WaypointsButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            task.defer(renderWaypoints)
        end
    end)
end

getgenv().renderWaypoints = renderWaypoints

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
        getgenv().Utils:Notify("Waypoints", "Saved " .. wpName, Color3.fromRGB(80, 200, 120))
    end
    if getgenv().saveSettings then getgenv().saveSettings() end
    renderWaypoints()
end)

if getgenv().WaypointUndoBtn then
    getgenv().WaypointUndoBtn.MouseButton1Click:Connect(function()
        local last = getgenv().lastDeletedWaypoint
        if not last then
            if getgenv().Utils then getgenv().Utils:Notify("Waypoints", "Nothing to undo.", Color3.fromRGB(220, 60, 60)) end
            return
        end
        local insertAt = math.min(last.index, #getgenv().savedWaypoints + 1)
        table.insert(getgenv().savedWaypoints, insertAt, last.data)
        getgenv().lastDeletedWaypoint = nil
        if getgenv().saveSettings then getgenv().saveSettings() end
        if getgenv().Utils then getgenv().Utils:Notify("Waypoints", "Restored " .. last.data.name, Color3.fromRGB(80, 200, 120)) end
        renderWaypoints()
    end)
end
