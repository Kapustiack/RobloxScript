-- [[ RB MODULAR HUB - ABSOLUTE RESTORATION v2 ]]
-- This is a pure loadstring orchestrator that matches rb.lua 1:1.

local baseUrl = "https://raw.githubusercontent.com/Kapustiak-maker/RobloxScript/main/"
local function loadRemote(path)
    local success, content = pcall(function() return game:HttpGet(baseUrl .. path) end)
    if not success or not content or content == "" then return nil end
    local func, err = loadstring(content)
    if not func then return nil end
    pcall(func)
end

-- 1. Initialize Globals & UI
loadRemote("modules/Utils.lua")
loadRemote("modules/Hooks.lua")
loadRemote("modules/State.lua")
loadRemote("modules/UI.lua")

-- 2. Load Features (Verbatim connections)
loadRemote("features/Hitbox.lua")
loadRemote("features/Reach.lua")
loadRemote("features/Follow.lua")
loadRemote("features/ESP.lua")
loadRemote("features/Speed.lua")
loadRemote("features/Misc.lua")
loadRemote("features/Other.lua")

-- 3. 1:1 RE-HOOKS (CharacterAdded / PlayerAdded)
-- Lines 2671 - 2723

local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not getgenv().scriptEnabled then return end
    if getgenv().speedhackEnabled and getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().infiniteJumpEnabled then
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect() end
        getgenv().infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if getgenv().infiniteJumpEnabled and getgenv().scriptEnabled then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end
        end)
    end
    if getgenv().reachEnabled and getgenv().enableReach then pcall(getgenv().enableReach) end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if getgenv().espEnabled and getgenv().scriptEnabled and getgenv().createESP then getgenv().createESP(player) end
        if getgenv().hitboxEnabled then task.wait(0.5); if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end end
    end)
end)

-- 4. 1:1 HUD DISPLAY (Rich Text Version)
-- Lines 2613 - 2666

local RunService = game:GetService("RunService")
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

    getgenv().HudLabel.RichText = true
    getgenv().HudLabel.Text = string.format(
        "<font color=\"#%02x%02x%02x\">FPS: %d</font> <font color=\"#606070\">|</font> <font color=\"#%02x%02x%02x\">%dms</font>",
        math.floor(fpsCol.R*255), math.floor(fpsCol.G*255), math.floor(fpsCol.B*255), fpsInt,
        math.floor(pingCol.R*255), math.floor(pingCol.G*255), math.floor(pingCol.B*255), getgenv().lastPingMs
    )
end)

-- Background loop for speed/hitbox/deathcheck
RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    
    if getgenv().deathCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
        local targetDead = false
        if not getgenv().followTarget.Character then targetDead = true
        else local hum = getgenv().followTarget.Character:FindFirstChildOfClass("Humanoid")
             if not hum or hum.Health <= 0 then targetDead = true end end
        if targetDead then if getgenv().autoSwitchEnabled then getgenv().switchTarget() else getgenv().stopFollow() end end
    end
end)

getgenv().Utils:Notify("RB Hub", "RESTORED v2 - Live Fix Applied", Color3.fromRGB(0, 200, 120))
