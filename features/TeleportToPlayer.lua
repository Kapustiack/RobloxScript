-- [[ TELEPORT TO PLAYER ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Scrollable list of players in TeleportSettingsFrame
local function refreshTeleportList()
    local lf = getgenv().TeleportPlayerList; if not lf then return end
    for _, c in pairs(lf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local ord = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            ord = ord + 1
            local b = Instance.new("TextButton", lf)
            b.LayoutOrder = ord
            b.Size = UDim2.new(1, -6, 0, 26)
            b.BorderSizePixel = 0; b.Font = Enum.Font.Gotham; b.TextSize = 11
            b.TextColor3 = getgenv().COL_TXT
            b.BackgroundColor3 = getgenv().COL_OFF
            -- Show health if available
            local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            local hp  = hum and math.floor(hum.Health) or "?"
            b.Text = p.Name .. "  [" .. hp .. " HP]"
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function()
                -- Teleport using Utils raycast if available, else direct CFrame
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
                local targetPos = p.Character.HumanoidRootPart.Position
                -- Offset slightly behind the target
                local offset = p.Character.HumanoidRootPart.CFrame.LookVector * -4 + Vector3.new(0, 0.5, 0)
                char.HumanoidRootPart.CFrame = CFrame.new(targetPos + offset)
                if getgenv().Utils then getgenv().Utils:Notify("Teleport", "Teleported to " .. p.Name, Color3.fromRGB(80,200,255)) end
            end)
        end
    end
    local ll = lf:FindFirstChildOfClass("UIListLayout")
    if ll then lf.CanvasSize = UDim2.new(0,0,0, ll.AbsoluteContentSize.Y + 4) end
end

-- Main button: opens settings panel (the list IS the feature)
getgenv().TeleportButton.MouseButton1Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().TeleportSettingsFrame) end
    refreshTeleportList()
end)
if getgenv().BindPanelButton and getgenv().TeleportSettingsFrame then
    getgenv().BindPanelButton(getgenv().TeleportButton, getgenv().TeleportSettingsFrame)
    getgenv().TeleportButton.MouseButton2Click:Connect(refreshTeleportList)
    getgenv().TeleportButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            task.defer(refreshTeleportList)
        end
    end)
end

-- Refresh button inside panel
if getgenv().TeleportRefreshBtn then
    getgenv().TeleportRefreshBtn.MouseButton1Click:Connect(refreshTeleportList)
end
