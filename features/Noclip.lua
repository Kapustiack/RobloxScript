-- [[ NOCLIP — Infinite Recursive + Unstuck + Perfect Restoration ]]
-- RIGHT-CLICK: opens Power panel (char + vehicle + touching parts density presets)
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

getgenv().noclipOriginalStates   = getgenv().noclipOriginalStates   or {}
getgenv().powerOriginalDensities = getgenv().powerOriginalDensities or {}

-- ─────────────────────────────────────────────
--  NOCLIP CORE
-- ─────────────────────────────────────────────
local function enableNoclip()
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect() end
    getgenv().noclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().noclipEnabled or not getgenv().scriptEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        local stack = {}
        local seen  = {}

        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(stack, p) end
        end
        if hum and hum.SeatPart then table.insert(stack, hum.SeatPart) end

        local count = 0
        while #stack > 0 and count < 1500 do
            count = count + 1
            local p = table.remove(stack)
            if p and not seen[p] then
                seen[p] = true
                if not getgenv().noclipOriginalStates[p] then
                    getgenv().noclipOriginalStates[p] = { CanCollide = p.CanCollide, Anchored = p.Anchored }
                end
                if p.CanCollide then p.CanCollide = false end
                if p.Anchored and p ~= hrp and not p:IsDescendantOf(char) then
                    p.Anchored = false
                    pcall(function() p.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0) end)
                end
                for _, conn in pairs(p:GetConnectedParts(true)) do
                    if not seen[conn] then table.insert(stack, conn) end
                end
                for _, child in pairs(p:GetChildren()) do
                    if child:IsA("Constraint") then
                        local a0 = child.Attachment0; local a1 = child.Attachment1
                        if a0 and a0.Parent and a0.Parent:IsA("BasePart") and not seen[a0.Parent] then table.insert(stack, a0.Parent) end
                        if a1 and a1.Parent and a1.Parent:IsA("BasePart") and not seen[a1.Parent] then table.insert(stack, a1.Parent) end
                    end
                end
            end
        end
    end)
end

local function disableNoclip()
    getgenv().noclipEnabled = false
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    for part, state in pairs(getgenv().noclipOriginalStates) do
        pcall(function()
            if part and part.Parent then
                part.CanCollide = state.CanCollide
                part.Anchored   = state.Anchored
            end
        end)
    end
    getgenv().noclipOriginalStates = {}
    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

-- ─────────────────────────────────────────────
--  POWER SYSTEM
-- ─────────────────────────────────────────────
local function collectPowerParts()
    local char = LocalPlayer.Character
    if not char then return {} end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local parts, seen = {}, {}
    local function add(p)
        if p and p:IsA("BasePart") and not seen[p] then seen[p] = true; table.insert(parts, p) end
    end
    for _, p in pairs(char:GetDescendants()) do add(p) end
    local seat = hum and hum.SeatPart
    if seat then
        local stk, s2 = {seat}, {}
        while #stk > 0 do
            local p = table.remove(stk)
            if p and not s2[p] then
                s2[p] = true; add(p)
                for _, cp in pairs(p:GetConnectedParts(true)) do
                    if not s2[cp] then table.insert(stk, cp) end
                end
            end
        end
    end
    if hrp then
        pcall(function() for _, p in pairs(workspace:GetPartsInPart(hrp)) do add(p) end end)
        for _, desc in pairs(char:GetDescendants()) do
            if desc:IsA("BasePart") then
                pcall(function() for _, p in pairs(workspace:GetPartsInPart(desc)) do add(p) end end)
            end
        end
    end
    return parts
end

local function applyPower(density)
    for _, p in pairs(collectPowerParts()) do
        pcall(function()
            if not getgenv().powerOriginalDensities[p] then
                local cur = p.CustomPhysicalProperties
                getgenv().powerOriginalDensities[p] = cur and cur.Density or 0.7
            end
            local cur = p.CustomPhysicalProperties
            p.CustomPhysicalProperties = PhysicalProperties.new(
                density,
                cur and cur.Friction         or 0.3,
                cur and cur.Elasticity       or 0.5,
                cur and cur.FrictionWeight   or 1,
                cur and cur.ElasticityWeight or 1
            )
        end)
    end
end

local function resetPower()
    for part, orig in pairs(getgenv().powerOriginalDensities) do
        pcall(function()
            if part and part.Parent then
                local cur = part.CustomPhysicalProperties
                part.CustomPhysicalProperties = PhysicalProperties.new(
                    orig,
                    cur and cur.Friction         or 0.3,
                    cur and cur.Elasticity       or 0.5,
                    cur and cur.FrictionWeight   or 1,
                    cur and cur.ElasticityWeight or 1
                )
            end
        end)
    end
    getgenv().powerOriginalDensities = {}
end

-- ─────────────────────────────────────────────
--  POWER PANEL — built once, uses getgenv().ScreenGui
--  Follows the exact makePanel/pBtn style from UI.lua.
--  TogglePanel is defined in UI.lua and handles hide-others logic.
-- ─────────────────────────────────────────────
local function buildPowerPanel()
    local gui = getgenv().ScreenGui
    if not gui then return end
    if getgenv().PowerPanel and getgenv().PowerPanel.Parent then return end

    local W, H = 220, 234
    local f = Instance.new("Frame")
    f.Name = "PowerPanel"; f.Parent = gui
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 23); f.BorderSizePixel = 0
    f.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    f.Size = UDim2.new(0, W, 0, H)
    f.Visible = false; f.Active = true; f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(38, 38, 54); s.Thickness = 1

    -- Title bar (identical style to makePanel in UI.lua)
    local tb = Instance.new("Frame"); tb.Parent = f
    tb.BackgroundColor3 = Color3.fromRGB(10, 10, 16); tb.BorderSizePixel = 0
    tb.Size = UDim2.new(1, 0, 0, 30)
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

    local tl = Instance.new("TextLabel"); tl.Parent = tb
    tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, -34, 1, 0)
    tl.Position = UDim2.new(0, 10, 0, 0); tl.Font = Enum.Font.GothamBold
    tl.Text = "⚡  Power / Weight"; tl.TextColor3 = getgenv().COL_TXT
    tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left

    local cb = Instance.new("TextButton"); cb.Parent = tb
    cb.BackgroundColor3 = getgenv().COL_CLO; cb.BorderSizePixel = 0
    cb.Position = UDim2.new(1, -24, 0.5, -8); cb.Size = UDim2.new(0, 16, 0, 16)
    cb.Font = Enum.Font.GothamBold; cb.Text = "X"; cb.TextColor3 = Color3.new(1,1,1); cb.TextSize = 11
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
    cb.MouseButton1Click:Connect(function() f.Visible = false end)

    -- Subtitle
    local sub = Instance.new("TextLabel"); sub.Parent = f
    sub.BackgroundTransparency = 1; sub.Position = UDim2.new(0, 10, 0, 33)
    sub.Size = UDim2.new(1, -20, 0, 16); sub.Font = Enum.Font.Gotham
    sub.Text = "char · vehicle · touching parts"
    sub.TextColor3 = getgenv().COL_MUTE; sub.TextSize = 10; sub.TextWrapped = true

    -- Preset buttons
    local presets = {
        { label = "🪶  Feather",  density = 0.01, col = Color3.fromRGB(60, 140, 200)  },
        { label = "⚖️  Normal",   density = 0.7,  col = getgenv().COL_OFF              },
        { label = "🏋️  Heavy",    density = 5,    col = Color3.fromRGB(160, 90, 30)   },
        { label = "💥  Extreme",  density = 22,   col = Color3.fromRGB(160, 30, 30)   },
    }
    local yOff = 52
    for _, preset in ipairs(presets) do
        local btn = Instance.new("TextButton"); btn.Parent = f
        btn.BackgroundColor3 = preset.col; btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0, 10, 0, yOff); btn.Size = UDim2.new(0, W-20, 0, 26)
        btn.Font = Enum.Font.GothamBold; btn.Text = preset.label
        btn.TextColor3 = getgenv().COL_TXT; btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local cap = preset.density
        btn.MouseButton1Click:Connect(function() applyPower(cap) end)
        yOff = yOff + 32
    end

    -- Reset
    local resetBtn = Instance.new("TextButton"); resetBtn.Parent = f
    resetBtn.BackgroundColor3 = getgenv().COL_OFF; resetBtn.BorderSizePixel = 0
    resetBtn.Position = UDim2.new(0, 10, 0, yOff); resetBtn.Size = UDim2.new(0, W-20, 0, 26)
    resetBtn.Font = Enum.Font.GothamBold; resetBtn.Text = "↩  Reset All"
    resetBtn.TextColor3 = getgenv().COL_TXT; resetBtn.TextSize = 11
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 5)
    resetBtn.MouseButton1Click:Connect(function() resetPower() end)

    getgenv().PowerPanel = f
end

-- ─────────────────────────────────────────────
--  BUTTON WIRING
-- ─────────────────────────────────────────────
getgenv().NoclipButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noclipEnabled = not getgenv().noclipEnabled
    getgenv().NoclipButton.Text = "Noclip: " .. (getgenv().noclipEnabled and "ON" or "OFF")
    getgenv().NoclipButton.BackgroundColor3 = getgenv().noclipEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noclipEnabled then enableNoclip() else disableNoclip() end
end)

-- RIGHT-CLICK: build panel once, then use TogglePanel (same as all other right-click settings)
getgenv().NoclipButton.MouseButton2Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    buildPowerPanel()
    if getgenv().TogglePanel and getgenv().PowerPanel then
        getgenv().TogglePanel(getgenv().PowerPanel)
    end
end)

getgenv().disableNoclip = disableNoclip
getgenv().applyPower    = applyPower
getgenv().resetPower    = resetPower