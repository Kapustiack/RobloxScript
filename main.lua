-- [[ RB MODULAR HUB - ABSOLUTE LITERAL RESTORATION ]]
-- This is the fixed loader that perfectly mirrors the original rb.lua.

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

-- 2. LOAD FEATURES (Contains verbatim connections)
loadRemote("features/Hitbox.lua")
loadRemote("features/Reach.lua")
loadRemote("features/Follow.lua")
loadRemote("features/ESP.lua")
loadRemote("features/Speed.lua")
loadRemote("features/Misc.lua")
loadRemote("features/Other.lua")

-- 3. VERBATIM BACKGROUND LOOPS
-- Lines 2531 - 2666 in rb.lua

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    
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
        getgenv().HudLabel.RichText = true
        getgenv().HudLabel.Text = string.format(
            "<font color=\"#%02x%02x%02x\">FPS: %d</font> <font color=\"#606070\">|</font> <font color=\"#%02x%02x%02x\">%dms</font>",
            math.floor(fpsCol.R*255), math.floor(fpsCol.G*255), math.floor(fpsCol.B*255), fpsInt,
            math.floor(pingCol.R*255), math.floor(pingCol.G*255), math.floor(pingCol.B*255), getgenv().lastPingMs
        )
    end
end)

-- Finish
getgenv().Utils:Notify("RB Hub", "ABSOLUTE RESTORATION - FIXED.", Color3.fromRGB(0, 200, 120))
