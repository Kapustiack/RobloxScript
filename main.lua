-- [[ RB MODULAR HUB - FULL BUG-FIX EDITION ]]
-- Fixes: BUG 4 (CharacterAdded), BUG 5 (PlayerAdded/Removing),
--        BUG 7 (Death Check notifications), BUG 11 (saveSettings),
--        BUG 12 (OnTeleport cleanup), + all existing V6 fixes

-- 0. CLEAN BOOT
local lastGUI = game:GetService("CoreGui"):FindFirstChild("CheatGUI")
if lastGUI then lastGUI:Destroy() end
if getgenv().destroyScript then pcall(getgenv().destroyScript) end

local baseUrl = "https://raw.githubusercontent.com/Kapustiack/RobloxScript/main/"
local function loadRemote(path)
    local cacheBypass = "?t=" .. tostring(os.time()) .. tostring(math.random(1, 100000))
    local success, content = pcall(function() return game:HttpGet(baseUrl .. path .. cacheBypass) end)

    if not success or not content or content == "" then
        warn("[RB Hub] Download Error: " .. path)
        return nil
    end

    local func, err = loadstring(content)
    if not func then
        warn("[RB Hub] Syntax Error: " .. path .. " | " .. tostring(err))
        return nil
    end

    local runSuccess, runErr = pcall(func)
    if not runSuccess then
        warn("[RB Hub] Execution Error: " .. path .. " | " .. tostring(runErr))
    end
end

-- 1. LOAD COMPONENTS
loadRemote("modules/Utils.lua")
loadRemote("modules/Hooks.lua")
loadRemote("modules/State.lua")
loadRemote("modules/UI.lua")
loadRemote("modules/Save.lua")           -- save/load system (after UI, before features)
loadRemote("modules/Input.lua")

-- 2. LOAD FEATURES (full list — every file is now directly wired)
loadRemote("features/Flight.lua")        -- FlightButton toggle + right-click settings
loadRemote("features/Noclip.lua")        -- NoclipButton toggle
loadRemote("features/InfiniteJump.lua")  -- InfiniteJumpButton toggle
loadRemote("features/NoDamage.lua")      -- NoDamageButton toggle (dual-layer)
loadRemote("features/Hitbox.lua")        -- HitboxButton + namecall hook
loadRemote("features/Reach.lua")         -- ReachButton + RenderStepped indicator
loadRemote("features/Follow.lua")        -- FollowButton + settings panel
loadRemote("features/ESP.lua")           -- ESPButton + settings panel
loadRemote("features/Speed.lua")         -- SpeedButton + right-click settings
loadRemote("features/Misc.lua")          -- Fullbright, Locks, FOV, Wallhack, Server utils
loadRemote("features/Wallhack.lua")      -- stub (implementation in Misc.lua)
loadRemote("features/Fullbright.lua")    -- stub (implementation in Misc.lua)
loadRemote("features/FOVChanger.lua")    -- stub (implementation in Misc.lua)
loadRemote("features/FreeCamera.lua")    -- FreeCam: Free Fly / Spectate / Minimap
loadRemote("features/LowGravity.lua")    -- Low Gravity + slider
loadRemote("features/FreezeSelf.lua")    -- Freeze Self (anchor HRP)
loadRemote("features/TeleportToPlayer.lua") -- Teleport to player from list
loadRemote("features/Waypoints.lua")     -- Custom waypoints
loadRemote("features/Other.lua")         -- empty (was causing duplicate button binds)



-- 3. DESTROY SCRIPT — cleans up everything
getgenv().destroyScript = function()
    getgenv().scriptEnabled = false
    -- Stop all features
    if getgenv().stopFollow        then pcall(getgenv().stopFollow)           end
    if getgenv().disableReach      then pcall(getgenv().disableReach)         end
    if getgenv().disableFlight     then pcall(getgenv().disableFlight)        end
    if getgenv().disableWallhack   then pcall(getgenv().disableWallhack)      end
    if getgenv().disableSpeedhack  then pcall(getgenv().disableSpeedhack)     end
    if getgenv().disableNoclip     then pcall(getgenv().disableNoclip)        end
    if getgenv().disableInfiniteJump then pcall(getgenv().disableInfiniteJump) end
    if getgenv().disableFullbright then pcall(getgenv().disableFullbright)    end
    if getgenv().disableFOVChanger  then pcall(getgenv().disableFOVChanger)   end
    if getgenv().removeHitboxExpansion then pcall(getgenv().removeHitboxExpansion) end
    if getgenv().disableFreeCamera  then pcall(getgenv().disableFreeCamera)   end
    if getgenv().disableLowGravity  then pcall(getgenv().disableLowGravity)   end
    if getgenv().disableFreeze      then pcall(getgenv().disableFreeze)        end


    -- Restore camera locks
    pcall(function()
        local cas = game:GetService("ContextActionService")
        cas:UnbindAction("DisableShiftLock")
        cas:UnbindAction("DisableCtrlSwitch")
    end)
    -- Stop all loops
    if getgenv().wallhackLoop         then getgenv().wallhackLoop:Disconnect();         getgenv().wallhackLoop = nil end
    if getgenv().fullbrightLoop       then getgenv().fullbrightLoop:Disconnect();       getgenv().fullbrightLoop = nil end
    if getgenv().noDamageLoop         then getgenv().noDamageLoop:Disconnect();         getgenv().noDamageLoop = nil end
    if getgenv().followConnection     then getgenv().followConnection:Disconnect();     getgenv().followConnection = nil end
    if getgenv().noclipConnection     then getgenv().noclipConnection:Disconnect();     getgenv().noclipConnection = nil end
    if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect(); getgenv().infiniteJumpConnection = nil end
    -- Restore hooks
    if getgenv().hitboxRestoreFunc    then pcall(getgenv().hitboxRestoreFunc);          getgenv().hitboxRestoreFunc = nil end
    if getgenv().noDamageRestoreFunc  then pcall(getgenv().noDamageRestoreFunc);        getgenv().noDamageRestoreFunc = nil end
    -- Destroy UI
    if getgenv().ESPContainer         then pcall(function() getgenv().ESPContainer:Destroy() end); getgenv().ESPContainer = nil end
    if getgenv().ScreenGui            then pcall(function() getgenv().ScreenGui:Destroy()    end); getgenv().ScreenGui    = nil end
end

-- 4. SAVE / LOAD SETTINGS — BUG 11 FIX: completely missing from modular version
local HttpService = game:GetService("HttpService")
local settingsFileName = "rb_settings.json"

getgenv().saveSettings = function()
    local s = {
        flightEnabled       = getgenv().flightEnabled,
        wallhackEnabled     = getgenv().wallhackEnabled,
        espEnabled          = getgenv().espEnabled,
        speedhackEnabled    = getgenv().speedhackEnabled,
        noclipEnabled       = getgenv().noclipEnabled,
        infiniteJumpEnabled = getgenv().infiniteJumpEnabled,
        fullbrightEnabled   = getgenv().fullbrightEnabled,
        fovChangerEnabled   = getgenv().fovChangerEnabled,
        shiftLockDisabled   = getgenv().shiftLockDisabled,
        ctrlLockDisabled    = getgenv().ctrlLockDisabled,
        espDrawDistance     = getgenv().espDrawDistance,
        espShowNames        = getgenv().espShowNames,
        espShowDistance     = getgenv().espShowDistance,
        espShowBoxes        = getgenv().espShowBoxes,
        espUse2DBoxes       = getgenv().espUse2DBoxes,
        speedMultiplier     = getgenv().speedMultiplier,
        currentFOV          = getgenv().currentFOV,
        followEnabled       = getgenv().followEnabled,
        followDistance      = getgenv().followDistance,
        followHeight        = getgenv().followHeight,
        clickCheckEnabled   = getgenv().clickCheckEnabled,
        deathCheckEnabled   = getgenv().deathCheckEnabled,
        autoSwitchEnabled   = getgenv().autoSwitchEnabled,
        reachEnabled        = getgenv().reachEnabled,
        reachDistance       = getgenv().reachDistance,
        reachVisual         = getgenv().reachVisual,
        hitboxEnabled       = getgenv().hitboxEnabled,
        hitboxSize          = getgenv().hitboxSize,
        hitboxVisual        = getgenv().hitboxVisual,
        noDamageEnabled     = getgenv().noDamageEnabled,
    }
    pcall(writefile, settingsFileName, HttpService:JSONEncode(s))
end

local function loadSettings()
    local ok, found = pcall(isfile, settingsFileName)
    if not (ok and found) then return end
    local ok2, s = pcall(function()
        return HttpService:JSONDecode(readfile(settingsFileName))
    end)
    if not ok2 or type(s) ~= "table" then return end

    -- Simple value restore (no toggle functions — features self-initialize from getgenv state)
    local function rv(key) if s[key] ~= nil then getgenv()[key] = s[key] end end
    rv("espDrawDistance"); rv("espShowNames"); rv("espShowDistance"); rv("espShowBoxes"); rv("espUse2DBoxes")
    rv("speedMultiplier"); rv("currentFOV")
    rv("followDistance"); rv("followHeight"); rv("clickCheckEnabled"); rv("deathCheckEnabled"); rv("autoSwitchEnabled")
    rv("reachDistance"); rv("reachVisual"); rv("hitboxSize"); rv("hitboxVisual")

    -- UI label sync after restore
    if s.espDrawDistance and getgenv().ESPDistanceLabel then getgenv().ESPDistanceLabel.Text = "Distance: " .. s.espDrawDistance end
    if s.speedMultiplier and getgenv().SpeedLabel then getgenv().SpeedLabel.Text = "Speed Multiplier: " .. string.format("%.1f", s.speedMultiplier) .. "x" end
    if s.currentFOV and getgenv().FOVLabel then getgenv().FOVLabel.Text = "FOV: " .. s.currentFOV .. "°" end
    if s.followDistance and getgenv().FollowDistanceLabel then getgenv().FollowDistanceLabel.Text = "Distance: " .. s.followDistance end
    if s.followHeight and getgenv().FollowHeightLabel then getgenv().FollowHeightLabel.Text = "Height: " .. s.followHeight end
    if s.reachDistance and getgenv().ReachDistLabel then getgenv().ReachDistLabel.Text = "Reach Distance: " .. s.reachDistance end
    if s.hitboxSize and getgenv().HitboxSizeLabel then getgenv().HitboxSizeLabel.Text = "Hitbox Size: " .. s.hitboxSize end
end

-- 5. LOGIC COORDINATION — SwitchTarget (distance-aware, history-based)
getgenv().pushHistory = function(p)
    if not p then return end
    for i = #getgenv().targetHistory, 1, -1 do if getgenv().targetHistory[i] == p then table.remove(getgenv().targetHistory, i) end end
    table.insert(getgenv().targetHistory, p)
    while #getgenv().targetHistory > 2 do table.remove(getgenv().targetHistory, 1) end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().switchTarget = function()
    if not getgenv().followEnabled then return end
    local candidates = {}
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p ~= getgenv().followTarget and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local d = (hrp.Position - myChar.HumanoidRootPart.Position).Magnitude
                table.insert(candidates, {player = p, dist = d})
            end
        end
    end
    if #candidates == 0 then return end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local inHistory = {}
    for _, p in ipairs(getgenv().targetHistory) do inHistory[p] = true end
    local chosen = nil
    for _, c in ipairs(candidates) do if not inHistory[c.player] then chosen = c.player; break end end
    if not chosen then chosen = candidates[1].player end
    getgenv().pushHistory(getgenv().followTarget)
    if getgenv().stopFollow and getgenv().startFollow then
        getgenv().startFollow(chosen)
        if getgenv().Utils then getgenv().Utils:Notify("Follow", "Switched to " .. chosen.Name, Color3.fromRGB(80, 200, 255)) end
    end
end

-- 6. WIRE HIDE / CLOSE BUTTONS (UI already loaded above — direct connection is safe)
if getgenv().HideButton then
    getgenv().HideButton.MouseButton1Click:Connect(function()
        if getgenv().ToggleUI then getgenv().ToggleUI() end
    end)
end

if getgenv().CloseButton then
    getgenv().CloseButton.MouseButton1Click:Connect(function()
        if getgenv().destroyScript then pcall(getgenv().destroyScript) end
    end)
end

-- 7. BACKGROUND LOOPS
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    if getgenv().updateFlight then getgenv().updateFlight() end

    -- BUG 7 FIX: Death Check with proper chat notifications (1:1 from rb.lua)
    if getgenv().deathCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
        local targetDead = false
        if not getgenv().followTarget.Character then
            targetDead = true
        else
            local hum = getgenv().followTarget.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then targetDead = true end
        end

        if targetDead then
            if getgenv().autoSwitchEnabled then
                local deadTarget = getgenv().followTarget
                getgenv().pushHistory(deadTarget)
                local nextTarget = getgenv().Utils and getgenv().Utils:FindNearestAlivePlayer(deadTarget)
                if nextTarget then
                    getgenv().followTarget = nextTarget
                    pcall(function()
                        StarterGui:SetCore("ChatMakeSystemMessage", {
                            Text = "[Follow] Target died - switching to " .. nextTarget.Name;
                            Color = Color3.fromRGB(255, 160, 0);
                            Font = Enum.Font.GothamBold;
                        })
                    end)
                else
                    if getgenv().stopFollow then getgenv().stopFollow() end
                    pcall(function()
                        StarterGui:SetCore("ChatMakeSystemMessage", {
                            Text = "[Follow] Target died - no other players found.";
                            Color = Color3.fromRGB(255, 80, 80);
                            Font = Enum.Font.GothamBold;
                        })
                    end)
                end
            else
                if getgenv().stopFollow then getgenv().stopFollow() end
                pcall(function()
                    StarterGui:SetCore("ChatMakeSystemMessage", {
                        Text = "[Follow] Target died - follow stopped.";
                        Color = Color3.fromRGB(255, 80, 80);
                        Font = Enum.Font.GothamBold;
                    })
                end)
            end
        end
    end
end)

-- Shift+C to toggle GUI
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        if getgenv().ToggleUI then getgenv().ToggleUI() end
    end
end)

-- FPS / Ping HUD
RunService.RenderStepped:Connect(function(dt)
    if not getgenv().scriptEnabled then return end
    local rawFPS = dt > 0 and (1 / dt) or 1
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
            "<font color=\"#%02x%02x%02x\">FPS: %d</font>  <font color=\"#606070\">|</font>  <font color=\"#%02x%02x%02x\">%dms</font>",
            math.floor(fpsCol.R*255), math.floor(fpsCol.G*255), math.floor(fpsCol.B*255), fpsInt,
            math.floor(pingCol.R*255), math.floor(pingCol.G*255), math.floor(pingCol.B*255), getgenv().lastPingMs
        )
    end
end)

-- NOTE: Reach indicator RenderStepped loop is handled inside features/Reach.lua
-- which has direct access to the local reachIndicator variable (BUG 3 fix)

-- BUG 4 FIX: CharacterAdded re-hooks (was completely missing — Speed/InfJump broke on respawn)
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not getgenv().scriptEnabled then return end
    -- Re-apply speed
    if getgenv().speedhackEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = getgenv().walkSpeed * getgenv().speedMultiplier
            hum.JumpPower = getgenv().jumpPower * getgenv().speedMultiplier
        end
    end
    -- Re-connect infinite jump
    if getgenv().infiniteJumpEnabled then
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect() end
        getgenv().infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if getgenv().infiniteJumpEnabled and getgenv().scriptEnabled then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
    -- Re-enable reach tool watcher
    if getgenv().reachEnabled and getgenv().enableReach then
        pcall(getgenv().enableReach)
    end
end)

-- BUG 5 FIX: PlayerAdded/Removing events (was completely missing — ESP/Hitbox didn't work for late joiners)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if getgenv().espEnabled and getgenv().scriptEnabled then
            -- updateESP will pick them up on the next Heartbeat tick automatically
        end
        if getgenv().hitboxEnabled then
            task.wait(0.5)
            if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    -- Clean up ESP for the leaving player
    if getgenv().ScreenGui then
        local parts = {player.Name.."_Name", player.Name.."_Distance", player.Name.."_2DBox"}
        for _, n in pairs(parts) do
            local o = getgenv().ScreenGui:FindFirstChild(n); if o then o:Destroy() end
        end
    end
    if getgenv().ESPContainer then
        local b3 = getgenv().ESPContainer:FindFirstChild(player.Name .. "_Box"); if b3 then b3:Destroy() end
    end
end)

-- BUG 12 FIX: OnTeleport cleanup (was completely missing — caused memory leaks on teleport)
pcall(function()
    LocalPlayer.OnTeleport:Connect(function(teleportState)
        if teleportState == Enum.TeleportState.Started
            or teleportState == Enum.TeleportState.InProgress
            or teleportState == Enum.TeleportState.RequestedFromServer
        then
            pcall(getgenv().destroyScript)
        end
    end)
end)

-- Load saved settings
pcall(loadSettings)

-- Startup notification
if getgenv().Utils and getgenv().Utils.Notify then
    getgenv().Utils:Notify("RB Hub", "Loaded. All bugs fixed. Shift+C = hide.", Color3.fromRGB(13, 110, 253))
end
