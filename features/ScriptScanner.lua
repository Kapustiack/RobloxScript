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

local function buildDynamicSettings(scr)
    local scroll = getgenv().DynamicSettingsScroll
    if not scroll then return end
    
    -- clear old settings
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local found = false
    local order = 0

    local function addLabel(txt)
        local l = Instance.new("TextLabel")
        l.Parent = scroll; l.Size = UDim2.new(1, 0, 0, 24); l.BackgroundTransparency = 1
        l.Text = txt; l.Font = Enum.Font.GothamBold; l.TextSize = 11; l.TextColor3 = Color3.fromRGB(150, 150, 180)
        l.TextXAlignment = Enum.TextXAlignment.Left; l.LayoutOrder = order
        order = order + 1
        found = true
    end

    local function addToggle(name, val, callback)
        local f = Instance.new("Frame"); f.Parent = scroll; f.Size = UDim2.new(1, 0, 0, 28)
        f.BackgroundTransparency = 1; f.LayoutOrder = order
        local l = Instance.new("TextLabel"); l.Parent = f; l.Size = UDim2.new(1, -60, 1, 0)
        l.BackgroundTransparency = 1; l.Text = name; l.Font = Enum.Font.Gotham; l.TextSize = 11
        l.TextColor3 = getgenv().COL_TXT; l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd
        
        local b = Instance.new("TextButton"); b.Parent = f; b.Size = UDim2.new(0, 50, 0, 20)
        b.Position = UDim2.new(1, -50, 0.5, -10); b.BackgroundColor3 = val and getgenv().COL_ON or getgenv().COL_OFF
        b.BorderSizePixel = 0; b.Text = val and "ON" or "OFF"; b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        
        local currentVal = val
        b.MouseButton1Click:Connect(function()
            currentVal = not currentVal
            b.Text = currentVal and "ON" or "OFF"
            b.BackgroundColor3 = currentVal and getgenv().COL_ON or getgenv().COL_OFF
            callback(currentVal)
        end)
        order = order + 1
        found = true
    end

    local function addNumber(name, val, callback)
        local f = Instance.new("Frame"); f.Parent = scroll; f.Size = UDim2.new(1, 0, 0, 28)
        f.BackgroundTransparency = 1; f.LayoutOrder = order
        local l = Instance.new("TextLabel"); l.Parent = f; l.Size = UDim2.new(1, -80, 1, 0)
        l.BackgroundTransparency = 1; l.Text = name; l.Font = Enum.Font.Gotham; l.TextSize = 11
        l.TextColor3 = getgenv().COL_TXT; l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd
        
        local tb = Instance.new("TextBox"); tb.Parent = f; tb.Size = UDim2.new(0, 70, 0, 20)
        tb.Position = UDim2.new(1, -70, 0.5, -10); tb.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        tb.BorderSizePixel = 0; tb.Text = tostring(val); tb.Font = Enum.Font.Gotham
        tb.TextColor3 = Color3.new(1,1,1); tb.TextSize = 11; tb.ClearTextOnFocus = false
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
        
        tb.FocusLost:Connect(function()
            local n = tonumber(tb.Text)
            if n then callback(n) else tb.Text = tostring(val) end
        end)
        order = order + 1
        found = true
    end
    
    local function addString(name, val, callback)
        local f = Instance.new("Frame"); f.Parent = scroll; f.Size = UDim2.new(1, 0, 0, 28)
        f.BackgroundTransparency = 1; f.LayoutOrder = order
        local l = Instance.new("TextLabel"); l.Parent = f; l.Size = UDim2.new(1, -110, 1, 0)
        l.BackgroundTransparency = 1; l.Text = name; l.Font = Enum.Font.Gotham; l.TextSize = 11
        l.TextColor3 = getgenv().COL_TXT; l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd
        
        local tb = Instance.new("TextBox"); tb.Parent = f; tb.Size = UDim2.new(0, 100, 0, 20)
        tb.Position = UDim2.new(1, -100, 0.5, -10); tb.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        tb.BorderSizePixel = 0; tb.Text = tostring(val); tb.Font = Enum.Font.Gotham
        tb.TextColor3 = Color3.new(1,1,1); tb.TextSize = 11; tb.ClearTextOnFocus = false
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
        
        tb.FocusLost:Connect(function() callback(tb.Text) end)
        order = order + 1
        found = true
    end

    -- 1. Scan for ValueBase children
    local hasValues = false
    for _, child in ipairs(scr:GetDescendants()) do
        if child:IsA("ValueBase") then
            if not hasValues then addLabel("-- Child Values --"); hasValues = true end
            if child:IsA("BoolValue") then
                addToggle(child.Name, child.Value, function(v) child.Value = v end)
            elseif child:IsA("NumberValue") or child:IsA("IntValue") then
                addNumber(child.Name, child.Value, function(v) child.Value = v end)
            elseif child:IsA("StringValue") then
                addString(child.Name, child.Value, function(v) child.Value = v end)
            end
        end
    end

    -- 2. Try to require if ModuleScript
    if scr:IsA("ModuleScript") then
        local success, data = pcall(require, scr)
        if success and type(data) == "table" then
            addLabel("-- Module Settings --")
            for k, v in pairs(data) do
                if type(v) == "boolean" then
                    addToggle(tostring(k), v, function(nv) data[k] = nv end)
                elseif type(v) == "number" then
                    addNumber(tostring(k), v, function(nv) data[k] = nv end)
                elseif type(v) == "string" then
                    addString(tostring(k), v, function(nv) data[k] = nv end)
                end
            end
        end
    end

    if not found then
        addLabel("No configurable settings found.")
    end

    local layout = scroll:FindFirstChildOfClass("UIListLayout")
    if layout then scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end
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

            local hasSettings = false
            if scr:IsA("ModuleScript") then hasSettings = true end
            for _, c in ipairs(scr:GetDescendants()) do if c:IsA("ValueBase") then hasSettings = true; break end end

            if hasSettings then
                local settingsBtn = Instance.new("TextButton")
                settingsBtn.Parent = row
                settingsBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 54)
                settingsBtn.BorderSizePixel = 0
                settingsBtn.Position = UDim2.new(1, -120, 0.5, -10)
                settingsBtn.Size = UDim2.new(0, 58, 0, 20)
                settingsBtn.Font = Enum.Font.GothamBold
                settingsBtn.Text = "Settings"
                settingsBtn.TextColor3 = Color3.new(1,1,1)
                settingsBtn.TextSize = 10
                Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 4)

                settingsBtn.MouseButton1Click:Connect(function()
                    buildDynamicSettings(scr)
                    if getgenv().TogglePanel and getgenv().DynamicSettingsPanel then
                        getgenv().HideAllPanels()
                        getgenv().DynamicSettingsPanel.Visible = true
                    end
                end)
            end
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
