local LocalPlayer = game:GetService("Players").LocalPlayer

-- UI Elements
local btn = getgenv().ScriptScannerButton
local panel = getgenv().ScriptScannerSettingsFrame
local scanBtn = getgenv().ScriptScannerScanBtn
local searchBox = getgenv().ScriptScannerSearchBox
local listFrame = getgenv().ScriptScannerList

if getgenv().BindPanelButton and panel then
    getgenv().BindPanelButton(btn, panel)
end

local function getScriptPath(scr)
    local p = scr
    local path = scr.Name
    for i=1, 4 do
        if p.Parent and p.Parent ~= game then
            p = p.Parent
            path = p.Name .. "." .. path
        else
            break
        end
    end
    return path
end

local function scanScripts()
    -- Clear old list
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local scriptsFound = {}
    local addedMap = {}

    local function checkAndAdd(obj)
        if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and not obj:IsDescendantOf(game:GetService("CoreGui")) then
            if not addedMap[obj] then
                addedMap[obj] = true
                table.insert(scriptsFound, obj)
            end
        end
    end

    -- Normal scan (Entire Game DataModel)
    local function scanGame()
        for _, desc in ipairs(game:GetDescendants()) do
            checkAndAdd(desc)
        end
    end
    pcall(scanGame)

    -- Advanced exploit scans if available
    pcall(function()
        if typeof(getscripts) == "function" then
            for _, scr in ipairs(getscripts()) do checkAndAdd(scr) end
        end
    end)
    pcall(function()
        if typeof(getnilinstances) == "function" then
            for _, inst in ipairs(getnilinstances()) do
                if (inst:IsA("LocalScript") or inst:IsA("ModuleScript")) then
                    checkAndAdd(inst)
                end
            end
        end
    end)
    pcall(function()
        if typeof(getloadedmodules) == "function" then
            for _, mod in ipairs(getloadedmodules()) do
                checkAndAdd(mod)
            end
        end
    end)

    -- Populate UI
    for i, scr in ipairs(scriptsFound) do
        local row = Instance.new("Frame")
        row.Name = "Row_" .. scr.Name
        row.Parent = listFrame
        row.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, 30)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 8, 0, 0)
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = getScriptPath(scr)
        label.TextColor3 = getgenv().COL_TXT
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd

        local toggle = Instance.new("TextButton")
        toggle.Parent = row
        toggle.BackgroundColor3 = scr.Disabled and getgenv().COL_OFF or getgenv().COL_ON
        toggle.BorderSizePixel = 0
        toggle.Position = UDim2.new(1, -58, 0.5, -10)
        toggle.Size = UDim2.new(0, 50, 0, 20)
        toggle.Font = Enum.Font.GothamBold
        toggle.Text = scr.Disabled and "OFF" or "ON"
        toggle.TextColor3 = Color3.new(1,1,1)
        toggle.TextSize = 10
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)

        toggle.MouseButton1Click:Connect(function()
            local success = pcall(function()
                scr.Disabled = not scr.Disabled
                toggle.Text = scr.Disabled and "OFF" or "ON"
                toggle.BackgroundColor3 = scr.Disabled and getgenv().COL_OFF or getgenv().COL_ON
            end)
            if not success then
                toggle.Text = "ERR"
                toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end)
    end

    -- Update scrolling frame size
    local layout = listFrame:FindFirstChildOfClass("UIListLayout")
    if layout then
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
end

scanBtn.MouseButton1Click:Connect(scanScripts)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(searchBox.Text)
    for _, row in ipairs(listFrame:GetChildren()) do
        if row:IsA("Frame") then
            local label = row:FindFirstChildOfClass("TextLabel")
            if label then
                if query == "" or string.find(string.lower(label.Text), query, 1, true) then
                    row.Visible = true
                else
                    row.Visible = false
                end
            end
        end
    end
    -- Re-adjust canvas size
    local layout = listFrame:FindFirstChildOfClass("UIListLayout")
    if layout then
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
end)
