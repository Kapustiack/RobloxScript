-- [[ NOCLIP — Infinite Recursive + Unstuck + Perfect Restoration ]]
-- ADDED: Right-click on NoclipButton opens a "Power" panel.
--        Power applies CustomPhysicalProperties density to:
--          • Your character
--          • Your current vehicle / seat assembly
--          • All parts currently touching your character or vehicle
--        Presets: Feather | Normal | Heavy | Extreme
--        A Reset button restores all original densities.
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

getgenv().noclipOriginalStates   = getgenv().noclipOriginalStates   or {}
getgenv().powerOriginalDensities = getgenv().powerOriginalDensities or {}

-- ─────────────────────────────────────────────
--  NOCLIP CORE (unchanged logic)
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
                    getgenv().noclipOriginalStates[p] = {
                        CanCollide = p.CanCollide,
                        Anchored   = p.Anchored
                    }
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

-- Collect all parts relevant to the player right now:
--   character parts + seated vehicle assembly + touching parts
local function collectPowerParts()
    local char = LocalPlayer.Character
    if not char then return {} end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local hrp  = char:FindFirstChild("HumanoidRootPart")

    local parts = {}
    local seen  = {}

    local function add(p)
        if p and p:IsA("BasePart") and not seen[p] then
            seen[p] = true
            table.insert(parts, p)
        end
    end

    -- 1. Character parts
    for _, p in pairs(char:GetDescendants()) do add(p) end

    -- 2. Vehicle / seat assembly (everything rigidly connected to the seat)
    local seat = hum and hum.SeatPart
    if seat then
        local stack2 = {seat}
        local seen2  = {}
        while #stack2 > 0 do
            local p = table.remove(stack2)
            if p and not seen2[p] then
                seen2[p] = true
                add(p)
                for _, cp in pairs(p:GetConnectedParts(true)) do
                    if not seen2[cp] then table.insert(stack2, cp) end
                end
            end
        end
    end

    -- 3. Parts currently touching the character (HRP touch sphere)
    if hrp then
        pcall(function()
            for _, p in pairs(workspace:GetPartsInPart(hrp)) do add(p) end
        end)
        -- Also parts touching any character limb
        for _, desc in pairs(char:GetDescendants()) do
            if desc:IsA("BasePart") then
                pcall(function()
                    for _, p in pairs(workspace:GetPartsInPart(desc)) do add(p) end
                end)
            end
        end
    end

    return parts
end

-- Apply a density multiplier to all collected parts
-- density: number (e.g. 0.01 = feather, 1 = normal, 5 = heavy, 20 = extreme)
local function applyPower(density)
    local parts = collectPowerParts()
    for _, p in pairs(parts) do
        pcall(function()
            -- Save original only once
            if not getgenv().powerOriginalDensities[p] then
                local cur = p.CustomPhysicalProperties
                if cur then
                    getgenv().powerOriginalDensities[p] = cur.Density
                else
                    -- Use material default density (approximate 0.7 for most Roblox materials)
                    getgenv().powerOriginalDensities[p] = 0.7
                end
            end
            local cur = p.CustomPhysicalProperties
            local friction, elasticity, fw, ew
            if cur then
                friction    = cur.Friction
                elasticity  = cur.Elasticity
                fw          = cur.FrictionWeight
                ew          = cur.ElasticityWeight
            else
                friction    = 0.3
                elasticity  = 0.5
                fw          = 1
                ew          = 1
            end
            p.CustomPhysicalProperties = PhysicalProperties.new(density, friction, elasticity, fw, ew)
        end)
    end
end

-- Reset all parts back to their original densities
local function resetPower()
    for part, originalDensity in pairs(getgenv().powerOriginalDensities) do
        pcall(function()
            if part and part.Parent then
                local cur = part.CustomPhysicalProperties
                local friction   = cur and cur.Friction    or 0.3
                local elasticity = cur and cur.Elasticity  or 0.5
                local fw         = cur and cur.FrictionWeight  or 1
                local ew         = cur and cur.ElasticityWeight or 1
                part.CustomPhysicalProperties = PhysicalProperties.new(originalDensity, friction, elasticity, fw, ew)
            end
        end)
    end
    getgenv().powerOriginalDensities = {}
end

-- ─────────────────────────────────────────────
--  POWER PANEL UI
--  Built once and toggled via right-click.
--  Sits inside the same ScreenGui as the other panels
--  (expects getgenv().MainGui to be the ScreenGui).
-- ─────────────────────────────────────────────

local function buildPowerPanel()
    local gui = getgenv().MainGui  -- your main ScreenGui reference from main.lua
    if not gui then return end
    if gui:FindFirstChild("PowerPanel") then return end  -- already built

    local panel = Instance.new("Frame")
    panel.Name            = "PowerPanel"
    panel.Size            = UDim2.new(0, 220, 0, 220)
    panel.Position        = UDim2.new(0, 10, 0, 300)  -- adjust to taste / draggable in main.lua
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    panel.BorderSizePixel = 0
    panel.Visible         = false
    panel.ZIndex          = 10
    panel.Parent          = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size              = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3  = Color3.fromRGB(40, 40, 60)
    title.Text              = "⚡  Power / Weight"
    title.TextColor3        = Color3.fromRGB(220, 220, 255)
    title.Font              = Enum.Font.GothamBold
    title.TextSize          = 14
    title.BorderSizePixel   = 0
    title.ZIndex            = 11
    title.Parent            = panel
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

    -- Subtitle
    local sub = Instance.new("TextLabel")
    sub.Size            = UDim2.new(1, -10, 0, 18)
    sub.Position        = UDim2.new(0, 5, 0, 34)
    sub.BackgroundTransparency = 1
    sub.Text            = "Applies to: char + vehicle + touching parts"
    sub.TextColor3      = Color3.fromRGB(150, 150, 180)
    sub.Font            = Enum.Font.Gotham
    sub.TextSize        = 10
    sub.TextWrapped     = true
    sub.ZIndex          = 11
    sub.Parent          = panel

    -- Preset buttons
    local presets = {
        { label = "🪶  Feather",  density = 0.01,  col = Color3.fromRGB(100, 200, 255) },
        { label = "⚖️  Normal",   density = 0.7,   col = Color3.fromRGB(180, 180, 180) },
        { label = "🏋️  Heavy",    density = 5,     col = Color3.fromRGB(255, 160, 60)  },
        { label = "💥  Extreme",  density = 22,    col = Color3.fromRGB(255, 80, 80)   },
    }

    local yOff = 58
    for _, preset in pairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.new(1, -16, 0, 28)
        btn.Position          = UDim2.new(0, 8, 0, yOff)
        btn.BackgroundColor3  = preset.col
        btn.Text              = preset.label
        btn.TextColor3        = Color3.fromRGB(15, 15, 15)
        btn.Font              = Enum.Font.GothamBold
        btn.TextSize          = 13
        btn.BorderSizePixel   = 0
        btn.ZIndex            = 11
        btn.Parent            = panel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local cap = preset.density  -- closure capture
        btn.MouseButton1Click:Connect(function()
            applyPower(cap)
        end)

        yOff = yOff + 34
    end

    -- Reset button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size             = UDim2.new(1, -16, 0, 28)
    resetBtn.Position         = UDim2.new(0, 8, 0, yOff)
    resetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    resetBtn.Text             = "↩  Reset All"
    resetBtn.TextColor3       = Color3.fromRGB(220, 220, 255)
    resetBtn.Font             = Enum.Font.GothamBold
    resetBtn.TextSize         = 13
    resetBtn.BorderSizePixel  = 0
    resetBtn.ZIndex           = 11
    resetBtn.Parent           = panel
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)

    resetBtn.MouseButton1Click:Connect(function()
        resetPower()
    end)

    getgenv().PowerPanel = panel
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

-- RIGHT-CLICK → toggle Power panel
getgenv().NoclipButton.MouseButton2Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    buildPowerPanel()  -- no-op if already built
    if getgenv().PowerPanel then
        getgenv().PowerPanel.Visible = not getgenv().PowerPanel.Visible
    end
end)

-- ─────────────────────────────────────────────
--  EXPORTS
-- ─────────────────────────────────────────────
getgenv().disableNoclip  = disableNoclip
getgenv().applyPower     = applyPower
getgenv().resetPower     = resetPower