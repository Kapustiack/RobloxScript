-- [[ RB MODULAR HUB - ABSOLUTE LITERAL RESTORATION ]]
-- FIXED V4: UI RELIABILITY (CLEAN BOOT) + FOLLOW FEEDBACK

-- 0. CLEAN BOOT (Destroy old instances before starting)
local lastGUI = game:GetService("CoreGui"):FindFirstChild("CheatGUI")
if lastGUI then lastGUI:Destroy() end
if getgenv().destroyScript then pcall(getgenv().destroyScript) end

local baseUrl = "https://raw.githubusercontent.com/Kapustiak-maker/RobloxScript/main/"
local function loadRemote(path)
    local success, content = pcall(function() return game:HttpGet(baseUrl .. path) end)
    if not success or not content or content == "" then return nil end
    local func, err = loadstring(content)
    if not func then return nil end
    pcall(func)
end

-- 3. VERBATIM DESTROY SCRIPT logic (Define early so UI can bind to it)
getgenv().destroyScript = function()
    getgenv().scriptEnabled = false
    if getgenv().stopFollow then getgenv().stopFollow() end
    if getgenv().disableReach then getgenv().disableReach() end
    if getgenv().removeHitboxExpansion then getgenv().removeHitboxExpansion() end
    if getgenv().disableFlight then getgenv().disableFlight() end
    if getgenv().disableWallhack then getgenv().disableWallhack() end
    if getgenv().disableSpeedhack then getgenv().disableSpeedhack() end
    if getgenv().disableNoclip then getgenv().disableNoclip() end
    if getgenv().disableInfiniteJump then getgenv().disableInfiniteJump() end
    if getgenv().disableFullbright then getgenv().disableFullbright() end
    if getgenv().disableFOVChanger then getgenv().disableFOVChanger() end
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect(); getgenv().fullbrightLoop = nil end
    if getgenv().noDamageLoop then getgenv().noDamageLoop:Disconnect(); getgenv().noDamageLoop = nil end
    if getgenv().hitboxRestoreFunc then pcall(getgenv().hitboxRestoreFunc); getgenv().hitboxRestoreFunc = nil end
    if getgenv().noDamageRestoreFunc then pcall(getgenv().noDamageRestoreFunc); getgenv().noDamageRestoreFunc = nil end
    if getgenv().ESPContainer then getgenv().ESPContainer:Destroy(); getgenv().ESPContainer = nil end
    if getgenv().ScreenGui then getgenv().ScreenGui:Destroy(); getgenv().ScreenGui = nil end
end

-- 1. LOAD CORE COMPONENETS
loadRemote("modules/Utils.lua")
loadRemote("modules/Hooks.lua")
loadRemote("modules/State.lua")  -- Populates getgenv
loadRemote("modules/UI.lua")     -- Creates GUI
loadRemote("modules/Input.lua")  -- Handles Sliders & Teleport

-- 2. LOAD FEATURES (Contains verbatim connections)
loadRemote("features/Hitbox.lua")
loadRemote("features/Reach.lua")
loadRemote("features/Follow.lua")
loadRemote("features/ESP.lua")
loadRemote("features/Speed.lua")
loadRemote("features/Misc.lua")
loadRemote("features/Other.lua") -- Contains Flight

-- 4. SWITCH TARGET LOGIC
getgenv().pushHistory = function(p)
    if not p then return end
    for i = #getgenv().targetHistory, 1, -1 do if getgenv().targetHistory[i] == p then table.remove(getgenv().targetHistory, i) end end
    table.insert(getgenv().targetHistory, p)
    while #getgenv().targetHistory > 2 do table.remove(getgenv().targetHistory, 1) end
end

getgenv().switchTarget = function()
    if not getgenv().followEnabled then return end
    local candidates = {}
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= game:GetService("Players").LocalPlayer and p ~= getgenv().followTarget and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then table.insert(candidates, p) end
        end
    end
    if #candidates == 0 then return end
    local inHistory = {}
    for _, p in ipairs(getgenv().targetHistory) do inHistory[p] = true end
    local chosen = nil
    for _, p in ipairs(candidates) do if not inHistory[p] then chosen = p; break end end
    if not chosen then chosen = candidates[1] end
    getgenv().pushHistory(getgenv().followTarget)
    if getgenv().stopFollow and getgenv().startFollow then
        getgenv().startFollow(chosen)
        if getgenv().Utils then getgenv().Utils:Notify("Follow", "Switched to " .. chosen.Name, Color3.fromRGB(80, 200, 255)) end
    end
end

-- 5. VERBATIM BACKGROUND LOOPS
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    if getgenv().updateFlight then getgenv().updateFlight() end
    
    -- CLICK CHECK LINGER LOGIC
    local now = os.clock()
    if getgenv().leftMouseClicked then
        getgenv().clickLingerUntil = 0
    end
    
    if getgenv().deathCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
        local targetDead = false
        if not getgenv().followTarget.Character then targetDead = true
        else local hum = getgenv().followTarget.Character:FindFirstChildOfClass("Humanoid")
             if not hum or hum.Health <= 0 then targetDead = true end end
        if targetDead then if getgenv().autoSwitchEnabled then getgenv().switchTarget() else getgenv().stopFollow() end end
    end
end)

-- 6. GUI TOGGLE (Shift + C)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        if getgenv().MainFrame then
            getgenv().MainFrame.Visible = not getgenv().MainFrame.Visible
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not getgenv().scriptEnabled then return end
    local rawFPS = dt > 0 and (1 / dt) or getgenv().smoothFPS
    getgenv().smoothFPS = getgenv().smoothFPS * 0.9 + rawFPS * 0.1
    local fpsInt = math.floor(getgenv().smoothFPS + 0.5)
    local now = os.clock()
    if now >= getgenv().nextPingTime then
        getgenv().nextPingTime = now + 0.5
        pcall(function() getgenv().lastPingMs = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) end)
    end
    local pingCol = getgenv().lastPingMs < 80 and Color3.fromRGB(60, 220, 100) or (getgenv().lastPingMs < 150 and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(220, 60, 60))
    local fpsCol = fpsInt >= 50 and Color3.fromRGB(60, 220, 100) or (fpsInt >= 30 and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(220, 60, 60))
    if getgenv().HudLabel then
        getgenv().HudLabel.Text = string.format(
            "<font color=\"#%02x%02x%02x\">FPS: %d</font> <font color=\"#606070\">|</font> <font color=\"#%02x%02x%02x\">%dms</font>",
            math.floor(fpsCol.R*255), math.floor(fpsCol.G*255), math.floor(fpsCol.B*255), fpsInt,
            math.floor(pingCol.R*255), math.floor(pingCol.G*255), math.floor(pingCol.B*255), getgenv().lastPingMs
        )
    end
end)

if getgenv().Utils and getgenv().Utils.Notify then
    getgenv().Utils:Notify("RB Hub", "Ready. Hotkey: Shift + C", Color3.fromRGB(13, 110, 253))
end
