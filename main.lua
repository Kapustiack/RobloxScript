-- [[ RB MODULAR HUB - ABSOLUTE LITERAL RESTORATION ]]
-- FIXED V2: Restored Sliders, Flight, and UI buttons.

local baseUrl = "https://raw.githubusercontent.com/Kapustiak-maker/RobloxScript/main/"
local function loadRemote(path)
    local success, content = pcall(function() return game:HttpGet(baseUrl .. path) end)
    if not success or not content or content == "" then return nil end
    local func, err = loadstring(content)
    if not func then return nil end
    pcall(func)
end

-- 1. LOAD CORE COMPONENETS
loadRemote("modules/Utils.lua")
loadRemote("modules/Hooks.lua")
loadRemote("modules/State.lua")  -- Populates getgenv
loadRemote("modules/UI.lua")     -- Creates GUI
loadRemote("modules/Input.lua")  -- Handles Sliders & Teleport (NEW)

-- 2. LOAD FEATURES (Contains verbatim connections)
loadRemote("features/Hitbox.lua")
loadRemote("features/Reach.lua")
loadRemote("features/Follow.lua")
loadRemote("features/ESP.lua")
loadRemote("features/Speed.lua")
loadRemote("features/Misc.lua")
loadRemote("features/Other.lua") -- Contains Flight

-- 3. VERBATIM DESTROY SCRIPT logic
-- Lines 1809 - 1843 in rb.lua

getgenv().destroyScript = function()
    getgenv().scriptEnabled = false
    if getgenv().stopFollow then getgenv().stopFollow() end
    if getgenv().disableReach then getgenv().disableReach() end
    if getgenv().removeHitboxExpansion then getgenv().removeHitboxExpansion() end
    
    -- Feature Cleanups
    if getgenv().disableFlight then getgenv().disableFlight() end
    if getgenv().disableWallhack then getgenv().disableWallhack() end
    if getgenv().disableSpeedhack then getgenv().disableSpeedhack() end
    if getgenv().disableNoclip then getgenv().disableNoclip() end
    if getgenv().disableInfiniteJump then getgenv().disableInfiniteJump() end
    if getgenv().disableFullbright then getgenv().disableFullbright() end
    if getgenv().disableFOVChanger then getgenv().disableFOVChanger() end
    
    -- Stop background loops
    if getgenv().fullbrightLoop then getgenv().fullbrightLoop:Disconnect(); getgenv().fullbrightLoop = nil end
    if getgenv().noDamageLoop then getgenv().noDamageLoop:Disconnect(); getgenv().noDamageLoop = nil end
    
    -- Metatable restoration
    if getgenv().hitboxRestoreFunc then pcall(getgenv().hitboxRestoreFunc); getgenv().hitboxRestoreFunc = nil end
    if getgenv().noDamageRestoreFunc then pcall(getgenv().noDamageRestoreFunc); getgenv().noDamageRestoreFunc = nil end
    
    -- Clear ESP
    if getgenv().ESPContainer then getgenv().ESPContainer:Destroy(); getgenv().ESPContainer = nil end
    
    -- Destroy GUI
    if getgenv().ScreenGui then getgenv().ScreenGui:Destroy(); getgenv().ScreenGui = nil end
end

-- 4. VERBATIM BACKGROUND LOOPS
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    if getgenv().updateFlight then getgenv().updateFlight() end -- ADDED FLIGHT LOOP
    
    -- Death Check logic
    if getgenv().deathCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
        local targetDead = false
        if not getgenv().followTarget.Character then targetDead = true
        else local hum = getgenv().followTarget.Character:FindFirstChildOfClass("Humanoid")
             if not hum or hum.Health <= 0 then targetDead = true end end
        if targetDead then if getgenv().autoSwitchEnabled then getgenv().switchTarget() else getgenv().stopFollow() end end
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

-- Finish
if getgenv().Utils and getgenv().Utils.Notify then
    getgenv().Utils:Notify("RB Hub", "V2 RESTORED - SLIDERS/FLIGHT FIXED.", Color3.fromRGB(155, 89, 182))
end
