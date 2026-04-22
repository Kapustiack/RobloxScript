-- [[ NOCLIP — Infinite Recursive + Unstuck + Perfect Restoration ]]
-- RIGHT-CLICK: opens Power panel (char + vehicle + touching parts density presets)
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

getgenv().noclipOriginalStates   = getgenv().noclipOriginalStates   or {}
getgenv().powerOriginalDensities = getgenv().powerOriginalDensities or {}
getgenv().noclipTrackedParts     = getgenv().noclipTrackedParts     or {}
getgenv().noclipLastRefresh      = getgenv().noclipLastRefresh      or 0

local REFRESH_INTERVAL = 0.12
local TRACK_LIMIT = 250

local function rememberState(part)
    if getgenv().noclipOriginalStates[part] then return end
    getgenv().noclipOriginalStates[part] = {
        CanCollide = part.CanCollide,
        Anchored = part.Anchored,
        Massless = part.Massless,
    }
end

local function canTrackPart(part, char, hrp)
    if not part or not part:IsA("BasePart") then return false end
    if part == workspace.Terrain then return false end
    if part:IsDescendantOf(char) then return true end
    local root = part.AssemblyRootPart
    return root and (root == hrp or root:IsDescendantOf(char))
end

local function refreshTrackedParts(char, hrp, hum)
    local tracked, seen = {}, {}
    local function add(part, force)
        if seen[part] then return end
        if not force and not canTrackPart(part, char, hrp) then return end
        seen[part] = true
        tracked[#tracked + 1] = part
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then add(part) end
    end

    local seat = hum and hum.SeatPart
    if seat then
        add(seat, true)
        for _, part in ipairs(seat:GetConnectedParts(true)) do
            add(part, true)
            if #tracked >= TRACK_LIMIT then break end
        end
    end

    if hrp then
        pcall(function()
            for _, part in ipairs(workspace:GetPartsInPart(hrp)) do
                add(part, true)
                if #tracked >= TRACK_LIMIT then break end
            end
        end)
    end

    getgenv().noclipTrackedParts = tracked
    getgenv().noclipLastRefresh = os.clock()
end

local function applyNoclipToTrackedParts(char, hrp, hum)
    local tracked = getgenv().noclipTrackedParts
    local density = tonumber(getgenv().noclipDensity) or 0.7
    local shouldAdjustDensity = density > 0.1
    local seat = hum and hum.SeatPart
    local seatRoot = seat and seat.AssemblyRootPart

    for i = #tracked, 1, -1 do
        local part = tracked[i]
        if not part or not part.Parent then
            table.remove(tracked, i)
        else
            rememberState(part)
            local isCharacterPart = part:IsDescendantOf(char)
            local isSeatAssemblyPart = seatRoot and part.AssemblyRootPart == seatRoot
            if part.CanCollide then part.CanCollide = false end
            if isCharacterPart then
                if part.Massless ~= true then part.Massless = true end
            elseif isSeatAssemblyPart then
                if part.Massless ~= false then part.Massless = false end
            end
            if part.Anchored and part ~= hrp then part.Anchored = false end
            if shouldAdjustDensity and not isCharacterPart then
                pcall(function()
                    if not getgenv().powerOriginalDensities[part] then
                        local cur = part.CustomPhysicalProperties
                        getgenv().powerOriginalDensities[part] = cur and cur.Density or 0.7
                    end
                    local cur = part.CustomPhysicalProperties
                    part.CustomPhysicalProperties = PhysicalProperties.new(
                        density,
                        cur and cur.Friction or 0.3,
                        cur and cur.Elasticity or 0.5,
                        cur and cur.FrictionWeight or 1,
                        cur and cur.ElasticityWeight or 1
                    )
                end)
            end
        end
    end
end

-- ─────────────────────────────────────────────
--  NOCLIP CORE
-- ─────────────────────────────────────────────
local function enableNoclip()
    getgenv().noclipEnabled = true
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect() end
    if getgenv().noclipTrackerConnection then getgenv().noclipTrackerConnection:Disconnect() end
    getgenv().noclipTrackedParts = {}
    getgenv().noclipLastRefresh = 0

    getgenv().noclipTrackerConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().noclipEnabled or not getgenv().scriptEnabled then return end
        local now = os.clock()
        if now - (getgenv().noclipLastRefresh or 0) < REFRESH_INTERVAL then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end

        refreshTrackedParts(char, hrp, hum)
    end)

    getgenv().noclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().noclipEnabled or not getgenv().scriptEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end
        if not getgenv().noclipTrackedParts or #getgenv().noclipTrackedParts == 0 then
            refreshTrackedParts(char, hrp, hum)
        end
        applyNoclipToTrackedParts(char, hrp, hum)
        pcall(function()
            if getgenv().flying and getgenv().flyVelocity then
                hrp.AssemblyLinearVelocity = getgenv().flyVelocity.Velocity
            end
        end)
    end)
end

local function disableNoclip()
    getgenv().noclipEnabled = false
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    if getgenv().noclipTrackerConnection then getgenv().noclipTrackerConnection:Disconnect(); getgenv().noclipTrackerConnection = nil end
    for part, state in pairs(getgenv().noclipOriginalStates) do
        pcall(function()
            if part and part.Parent then
                part.CanCollide = state.CanCollide
                part.Anchored   = state.Anchored
                part.Massless   = state.Massless
            end
        end)
    end
    getgenv().noclipOriginalStates = {}
    getgenv().noclipTrackedParts = {}
    getgenv().noclipLastRefresh = 0
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
--  POWER PANEL SLIDER LOGIC — panel is pre-created in UI.lua
-- ─────────────────────────────────────────────
local dragging = false
local minDensity, maxDensity = 0, 50

local function updateSlider(x)
    local sliderBg = getgenv().PowerSliderBg
    local sliderFill = getgenv().PowerSliderFill
    local sliderBtn = getgenv().PowerSliderBtn
    local valLabel = getgenv().PowerValLabel
    if not (sliderBg and sliderFill and sliderBtn and valLabel) then return end

    local relX = math.clamp(x, 0, sliderBg.AbsoluteSize.X)
    local ratio = relX / sliderBg.AbsoluteSize.X
    local density = ratio * maxDensity
    density = math.clamp(density, minDensity, maxDensity)
    getgenv().noclipDensity = density

    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderBtn.Position = UDim2.new(ratio, -7, 0.5, -9)

    if density <= 0.1 then
        resetPower()
        valLabel.Text = "Density: 0 (Reset)"
    else
        applyPower(density)
        local label = density < 1 and string.format("%.2f", density) or math.floor(density)
        valLabel.Text = "Density: " .. label
    end
end

if getgenv().PowerSliderBtn then
    getgenv().PowerSliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
end

if getgenv().PowerSliderBg then
    getgenv().PowerSliderBg.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = true
        local sliderBg = getgenv().PowerSliderBg
        local mouseX = UserInputService:GetMouseLocation().X
        if sliderBg then updateSlider(mouseX - sliderBg.AbsolutePosition.X) end
    end)
end

if getgenv().PowerResetBtn then
    getgenv().PowerResetBtn.MouseButton1Click:Connect(function()
        resetPower()
        if getgenv().UpdatePowerPanelVisual then
            getgenv().UpdatePowerPanelVisual(0.7)
        end
    end)
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderBg = getgenv().PowerSliderBg
        if sliderBg then
            local x = input.Position.X - sliderBg.AbsolutePosition.X
            updateSlider(x)
        end
    end
end)

-- ─────────────────────────────────────────────
--  BUTTON WIRING
-- ─────────────────────────────────────────────

-- Ensure we don't have multiple connections if script is re-run
local function refreshNoclipButton()
    getgenv().NoclipButton.Text = "Noclip: " .. (getgenv().noclipEnabled and "ON" or "OFF")
    getgenv().NoclipButton.BackgroundColor3 = getgenv().noclipEnabled and getgenv().COL_ON or getgenv().COL_OFF
end

local function setNoclipEnabled(enabled)
    if not getgenv().scriptEnabled then return end
    if enabled then
        enableNoclip()
        local density = tonumber(getgenv().noclipDensity) or 0.7
        if density > 0.1 then
            applyPower(density)
        else
            resetPower()
        end
    else
        disableNoclip()
        resetPower()
    end
    refreshNoclipButton()
    if getgenv().UpdatePowerPanelVisual then
        getgenv().UpdatePowerPanelVisual(getgenv().noclipDensity or 0.7)
    end
end

if getgenv().NoclipBtnConn then getgenv().NoclipBtnConn:Disconnect() end
getgenv().NoclipBtnConn = getgenv().NoclipButton.MouseButton1Down:Connect(function()
    if not getgenv().scriptEnabled then return end
    setNoclipEnabled(not getgenv().noclipEnabled)
end)

-- RIGHT-CLICK: toggle power panel
if getgenv().BindPanelButton and getgenv().PowerPanel then
    getgenv().BindPanelButton(getgenv().NoclipButton, getgenv().PowerPanel)
end

getgenv().disableNoclip = disableNoclip
getgenv().enableNoclip  = enableNoclip
getgenv().setNoclipEnabled = setNoclipEnabled
getgenv().applyPower    = applyPower
getgenv().resetPower    = resetPower
