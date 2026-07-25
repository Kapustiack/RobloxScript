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

local function guessCategory(name)
    local n = string.lower(name)
    if string.find(n, "walk") or string.find(n, "run") or string.find(n, "dash") or string.find(n, "speed") or string.find(n, "move") or string.find(n, "stamina") then return "Movement" end
    if string.find(n, "combat") or string.find(n, "hit") or string.find(n, "punch") or string.find(n, "sword") or string.find(n, "gun") or string.find(n, "shoot") or string.find(n, "damage") then return "Combat" end
    if string.find(n, "camera") or string.find(n, "cam") or string.find(n, "view") then return "Camera" end
    if string.find(n, "ui") or string.find(n, "gui") or string.find(n, "hud") or string.find(n, "menu") then return "Interface" end
    if string.find(n, "anti") or string.find(n, "cheat") or string.find(n, "kick") or string.find(n, "ban") then return "Security / Anti-Cheat" end
    if string.find(n, "fall") or string.find(n, "ragdoll") or string.find(n, "physics") then return "Physics" end
    if string.find(n, "health") or string.find(n, "hp") or string.find(n, "heal") or string.find(n, "regen") then return "Health" end
    return "Unknown Utility"
end

local function scanScripts()
    if scanBtn.Text:find("Scanning") then return end
    scanBtn.Text = "Scanning... (0%)"
    
    task.spawn(function()
        -- Clear old list
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local scriptsFound = {}
        local addedMap = {}
        local checks = 0

        local function checkAndAdd(obj)
            checks = checks + 1
            if checks % 100 == 0 then task.wait() end -- Yield to prevent freezing
            
            if (obj:IsA("LocalScript") or obj:IsA("ModuleScript")) and not obj:IsDescendantOf(game:GetService("CoreGui")) then
                if not addedMap[obj] then
                    addedMap[obj] = true
                    table.insert(scriptsFound, obj)
                end
            end
        end

        -- Normal scan (LocalPlayer Roots only as requested)
        local roots = {LocalPlayer:FindFirstChild("PlayerScripts"), LocalPlayer:FindFirstChild("PlayerGui"), LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
        for _, root in ipairs(roots) do
            if root then
                for _, desc in ipairs(root:GetDescendants()) do
                    checkAndAdd(desc)
                end
            end
        end
        scanBtn.Text = "Scanning... (40%)"

        -- Advanced exploit scans if available
        pcall(function()
            if typeof(getscripts) == "function" then
                for _, scr in ipairs(getscripts()) do checkAndAdd(scr) end
            end
        end)
        scanBtn.Text = "Scanning... (70%)"
        
        pcall(function()
            if typeof(getnilinstances) == "function" then
                for _, inst in ipairs(getnilinstances()) do
                    if (inst:IsA("LocalScript") or inst:IsA("ModuleScript")) then
                        checkAndAdd(inst)
                    end
                end
            end
        end)
        scanBtn.Text = "Scanning... (90%)"

        -- Populate UI
        for i, scr in ipairs(scriptsFound) do
            if i % 15 == 0 then task.wait() end -- Yield during UI creation
            
            local row = Instance.new("Frame")
            row.Name = "Row_" .. scr.Name
            row.Parent = listFrame
            row.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, 42)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

            local label = Instance.new("TextLabel")
            label.Parent = row
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 8, 0, 4)
            label.Size = UDim2.new(1, -70, 0, 16)
            label.Font = Enum.Font.Gotham
            label.Text = getScriptPath(scr)
            label.TextColor3 = getgenv().COL_TXT
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            
            local catLabel = Instance.new("TextLabel")
            catLabel.Parent = row
            catLabel.BackgroundTransparency = 1
            catLabel.Position = UDim2.new(0, 8, 0, 22)
            catLabel.Size = UDim2.new(1, -70, 0, 14)
            catLabel.Font = Enum.Font.Gotham
            catLabel.Text = "Category: " .. guessCategory(scr.Name)
            catLabel.TextColor3 = Color3.fromRGB(130, 130, 170)
            catLabel.TextSize = 10
            catLabel.TextXAlignment = Enum.TextXAlignment.Left

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
        
        scanBtn.Text = "Scan Scripts"
    end)
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
