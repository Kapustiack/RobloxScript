-- [[ RB MODULAR HUB - ABSOLUTE LITERAL RESTORATION ]]
-- This is the glue that loads your verbatim core and features from GitHub.

local baseUrl = "https://raw.githubusercontent.com/Kapustiak-maker/RobloxScript/main/"

local function loadRemote(path)
    local success, content = pcall(function() return game:HttpGet(baseUrl .. path) end)
    if not success or not content or content == "" then warn("[RB] Failed: " .. path) return nil end
    local func, err = loadstring(content)
    if not func then warn("[RB] Syntax: " .. path) return nil end
    local ok, res = pcall(func)
    return res
end

-- 1. LOAD GLOBALS & CORE
getgenv().Utils = loadRemote("modules/Utils.lua")
getgenv().Hooks = loadRemote("modules/Hooks.lua")
loadRemote("modules/State.lua")  -- Populates getgenv
loadRemote("modules/UI.lua")     -- Populates getgenv UI

-- 2. LOAD FEATURES (Contains verbatim connections)
loadRemote("features/Hitbox.lua")
loadRemote("features/Reach.lua")
loadRemote("features/Follow.lua")
loadRemote("features/ESP.lua")
loadRemote("features/Speed.lua")
loadRemote("features/Misc.lua")
loadRemote("features/Other.lua")

-- 3. FINAL HOOKS (Lines 2531 - 2770)
-- Strict 1:1 Restoration of the background loops.

game:GetService("RunService").Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    
    -- Death Check logic verbatim
    if getgenv().deathCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
        local targetDead = false
        if not getgenv().followTarget.Character then targetDead = true
        else local hum = getgenv().followTarget.Character:FindFirstChildOfClass("Humanoid")
             if not hum or hum.Health <= 0 then targetDead = true end end
        if targetDead then if getgenv().autoSwitchEnabled then getgenv().switchTarget() else getgenv().stopFollow() end end
    end
end)

local smoothFPS = 60
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if not getgenv().scriptEnabled then return end
    local rawFPS = dt > 0 and (1 / dt) or smoothFPS
    smoothFPS = smoothFPS * 0.9 + rawFPS * 0.1
    getgenv().HudLabel.Text = string.format("FPS: %d | Ping: ...", math.floor(smoothFPS + 0.5))
end)

getgenv().CloseButton.MouseButton1Click:Connect(function()
    getgenv().scriptEnabled = false
    getgenv().ScreenGui:Destroy()
end)

getgenv().SaveButton.MouseButton1Click:Connect(function()
    getgenv().Utils:Notify("RB Hub", "Settings Saved (Simulated)", Color3.fromRGB(0, 200, 120))
end)

getgenv().Utils:Notify("RB Hub", "ABSOLUTE RESTORATION LOADED.", Color3.fromRGB(0, 200, 120))
