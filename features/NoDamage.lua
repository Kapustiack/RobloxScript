local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DEFAULT_FALL_SCRIPT_PATTERNS = {"fall", "land", "ragdoll", "impact", "damage", "velocity"}

-- User-editable via the No Fall settings panel (right-click the button).
-- Falls back to the built-in defaults if the list is ever emptied out.
local function getFallPatterns()
    local list = getgenv().noDamageFallPatterns
    if type(list) == "table" and #list > 0 then return list end
    return DEFAULT_FALL_SCRIPT_PATTERNS
end

local function shouldDisableScript(obj)
    if not obj or not (obj:IsA("LocalScript") or obj:IsA("Script")) then return false end
    local name = string.lower(obj.Name)
    for _, pattern in ipairs(getFallPatterns()) do
        if pattern ~= "" and string.find(name, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function disableAttachedFallScripts(char)
    if not char then return end
    getgenv().disabledFallScripts = getgenv().disabledFallScripts or {}
    for _, obj in ipairs(char:GetDescendants()) do
        if shouldDisableScript(obj) and obj.Enabled ~= false and getgenv().disabledFallScripts[obj] == nil then
            getgenv().disabledFallScripts[obj] = obj.Enabled
            obj.Enabled = false
        end
    end
end

local function restoreAttachedFallScripts()
    local disabled = getgenv().disabledFallScripts or {}
    for obj, wasEnabled in pairs(disabled) do
        pcall(function()
            if obj and obj.Parent then
                obj.Enabled = wasEnabled
            end
        end)
    end
    getgenv().disabledFallScripts = {}
end

local function disconnectFallDamageWatchers()
    local conns = {
        "fallDamageHealthConn",
        "fallDamageStateConn",
        "fallDamageCharConn",
        "fallDamageDescConn",
        "fallDamageLoop",
    }
    for _, key in ipairs(conns) do
        local conn = getgenv()[key]
        if conn then
            conn:Disconnect()
            getgenv()[key] = nil
        end
    end
end

local function attachFallDamageProtection(char)
    disconnectFallDamageWatchers()
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    getgenv().lastSafeHealth = hum.Health
    getgenv().preFallHealth = hum.Health
    getgenv().fallingNow = false
    getgenv().lastFallLandAt = 0

    disableAttachedFallScripts(char)
    getgenv().fallDamageDescConn = char.DescendantAdded:Connect(function(obj)
        if getgenv().noDamageEnabled and shouldDisableScript(obj) then
            task.defer(function()
                if obj and obj.Parent then
                    getgenv().disabledFallScripts = getgenv().disabledFallScripts or {}
                    if getgenv().disabledFallScripts[obj] == nil then
                        getgenv().disabledFallScripts[obj] = obj.Enabled
                    end
                    obj.Enabled = false
                end
            end)
        end
    end)

    getgenv().fallDamageStateConn = hum.StateChanged:Connect(function(_, newState)
        if not getgenv().noDamageEnabled then return end
        if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.FallingDown then
            getgenv().fallingNow = true
            getgenv().preFallHealth = hum.Health
        elseif getgenv().fallingNow and (
            newState == Enum.HumanoidStateType.Landed
            or newState == Enum.HumanoidStateType.Running
            or newState == Enum.HumanoidStateType.RunningNoPhysics
        ) then
            getgenv().fallingNow = false
            getgenv().lastFallLandAt = os.clock()
        end
    end)

    getgenv().fallDamageHealthConn = hum.HealthChanged:Connect(function(newHealth)
        if not getgenv().noDamageEnabled then return end
        local now = os.clock()
        local lastSafe = getgenv().lastSafeHealth or newHealth
        local tookDamage = newHealth < lastSafe
        local nearFallWindow = getgenv().fallingNow or (now - (getgenv().lastFallLandAt or 0) <= 1.25)
        if tookDamage and nearFallWindow and hum.Health > 0 then
            hum.Health = math.max(lastSafe, getgenv().preFallHealth or lastSafe)
            return
        end
        if not getgenv().fallingNow then
            getgenv().lastSafeHealth = newHealth
        end
    end)

    getgenv().fallDamageLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().noDamageEnabled then return end
        if not hum.Parent then return end
        disableAttachedFallScripts(char)
        local state = hum:GetState()
        if state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.FallingDown then
            getgenv().lastSafeHealth = hum.Health
        end
    end)
end

local function enableNoDamage()
    if not getgenv().scriptEnabled then return end
    getgenv().noDamageEnabled = true

    local char = LocalPlayer.Character
    if char then
        attachFallDamageProtection(char)
    end

    getgenv().fallDamageCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.25)
        if getgenv().noDamageEnabled then
            attachFallDamageProtection(newChar)
        end
    end)
end

local function disableNoDamage()
    getgenv().noDamageEnabled = false
    disconnectFallDamageWatchers()
    restoreAttachedFallScripts()
    getgenv().fallingNow = false
end

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noDamageEnabled = not getgenv().noDamageEnabled
    getgenv().NoDamageButton.Text = "No Fall: " .. (getgenv().noDamageEnabled and "ON" or "OFF")
    getgenv().NoDamageButton.BackgroundColor3 = getgenv().noDamageEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noDamageEnabled then enableNoDamage() else disableNoDamage() end
end)

if getgenv().BindPanelButton and getgenv().NoDamageSettingsFrame then
    getgenv().BindPanelButton(getgenv().NoDamageButton, getgenv().NoDamageSettingsFrame)
end

local function refreshNoDamagePatternsBox()
    if getgenv().NoDamagePatternsBox then
        getgenv().NoDamagePatternsBox.Text = table.concat(getFallPatterns(), ", ")
    end
end

local function applyPatternsFromBox()
    local box = getgenv().NoDamagePatternsBox
    if not box then return end
    local list = {}
    for piece in string.gmatch(box.Text, "([^,]+)") do
        local trimmed = piece:match("^%s*(.-)%s*$"):lower()
        if trimmed ~= "" then table.insert(list, trimmed) end
    end
    if #list > 0 then
        getgenv().noDamageFallPatterns = list
        if getgenv().Utils then getgenv().Utils:Notify("No Fall Damage", "Updated script-name filters.", Color3.fromRGB(80, 200, 120)) end
    end
end

if getgenv().NoDamagePatternsBox then
    getgenv().NoDamagePatternsBox.FocusLost:Connect(applyPatternsFromBox)
end
if getgenv().NoDamageApplyBtn then
    getgenv().NoDamageApplyBtn.MouseButton1Click:Connect(applyPatternsFromBox)
end

getgenv().refreshNoDamagePatternsBox = refreshNoDamagePatternsBox
getgenv().disableNoDamage = disableNoDamage
getgenv().enableNoDamage = enableNoDamage
