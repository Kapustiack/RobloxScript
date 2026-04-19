-- [[ RB MODULAR HUB - PREMIUM STARTUP LOADER ]]
-- Features: Real-time progress bar, activity logging, and fail-safe initialization.

-- 0. CLEAN BOOT
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local lastGUI = CoreGui:FindFirstChild("CheatGUI")
if lastGUI then lastGUI:Destroy() end
local lastLoader = CoreGui:FindFirstChild("HubLoader")
if lastLoader then lastLoader:Destroy() end
if getgenv().destroyScript then pcall(getgenv().destroyScript) end

-- [[ STARTUP LOADER UI ]]
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "HubLoader"; LoaderGui.Parent = CoreGui; LoaderGui.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Name = "Main"; Main.Parent = LoaderGui; Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.BorderSizePixel = 0; Main.Position = UDim2.new(0.5, -150, 0.5, -50); Main.Size = UDim2.new(0, 300, 0, 100); Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MStroke = Instance.new("UIStroke", Main); MStroke.Color = Color3.fromRGB(40, 40, 50); MStroke.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Name = "Title"; Title.Parent = Main; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 10, 0, 8); Title.Size = UDim2.new(1, -20, 0, 20); Title.Font = Enum.Font.GothamBold; Title.Text = "RB MODULAR HUB"; Title.TextColor3 = Color3.fromRGB(240, 240, 240); Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("TextLabel")
Status.Name = "Status"; Status.Parent = Main; Status.BackgroundTransparency = 1; Status.Position = UDim2.new(0, 10, 0, 32); Status.Size = UDim2.new(1, -20, 0, 18); Status.Font = Enum.Font.Gotham; Status.Text = "Initializing..."; Status.TextColor3 = Color3.fromRGB(180, 180, 190); Status.TextSize = 11; Status.TextXAlignment = Enum.TextXAlignment.Left

local ProgressBG = Instance.new("Frame")
ProgressBG.Name = "ProgressBG"; ProgressBG.Parent = Main; ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40); ProgressBG.BorderSizePixel = 0; ProgressBG.Position = UDim2.new(0, 10, 0, 60); ProgressBG.Size = UDim2.new(1, -20, 0, 6)
Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(1, 0)

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"; ProgressBar.Parent = ProgressBG; ProgressBar.BackgroundColor3 = Color3.fromRGB(13, 110, 253); ProgressBar.BorderSizePixel = 0; ProgressBar.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

local Percent = Instance.new("TextLabel")
Percent.Name = "Percent"; Percent.Parent = Main; Percent.BackgroundTransparency = 1; Percent.Position = UDim2.new(0, 10, 0, 72); Percent.Size = UDim2.new(1, -20, 0, 18); Percent.Font = Enum.Font.Gotham; Percent.Text = "0%"; Percent.TextColor3 = Color3.fromRGB(120, 120, 130); Percent.TextSize = 10; Percent.TextXAlignment = Enum.TextXAlignment.Right

-- [[ LOADER LOGIC ]]
local baseUrl = "https://raw.githubusercontent.com/Kapustiack/RobloxScript/main/"
local totalFiles = 21
local loadedCount = 0

local function updateLoader(path, count)
    loadedCount = count
    Status.Text = "Loading " .. path .. "..."
    local fraction = loadedCount / totalFiles
    Percent.Text = string.format("%d%% (%d/%d)", math.floor(fraction * 100), loadedCount, totalFiles)
    TweenService:Create(ProgressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(fraction, 0, 1, 0)}):Play()
end

local function loadRemote(path)
    local cacheBypass = "?t=" .. tostring(os.time()) .. tostring(math.random(1, 100000))
    local success, content = pcall(function() return game:HttpGet(baseUrl .. path .. cacheBypass) end)
    
    if not success or not content or content == "" then 
        warn("[RB Hub] Download Error: " .. path)
        Status.Text = "Error: " .. path
        Status.TextColor3 = Color3.fromRGB(220, 60, 60)
        return nil 
    end
    
    local func, err = loadstring(content)
    if not func then 
        warn("[RB Hub] Syntax Error: " .. path .. " | " .. tostring(err))
        return nil 
    end
    
    pcall(func)
end

-- [[ FILE ORCHESTRATION ]]
local files = {
    "modules/Utils.lua", "modules/Hooks.lua", "modules/State.lua", "modules/UI.lua",
    "modules/Save.lua", "modules/Input.lua", "features/Flight.lua", "features/Noclip.lua",
    "features/InfiniteJump.lua", "features/NoDamage.lua", "features/Hitbox.lua",
    "features/Reach.lua", "features/Follow.lua", "features/ESP.lua", "features/Speed.lua",
    "features/Misc.lua", "features/FreeCamera.lua", "features/LowGravity.lua",
    "features/FreezeSelf.lua", "features/TeleportToPlayer.lua", "features/Waypoints.lua"
}

for i, path in ipairs(files) do
    updateLoader(path, i)
    loadRemote(path)
    task.wait(0.02) -- Smoothness delay
end

-- Finalize
Status.Text = "Initialization Complete!"
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 300, 0, 0), Position = UDim2.new(0.5, -150, 0.5, 0)}):Play()
task.wait(0.6)
LoaderGui:Destroy()

-- [[ CORE LOGIC INITIALIZATION ]]
-- 3. DESTROY SCRIPT logic
getgenv().destroyScript = function()
    getgenv().scriptEnabled = false
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

    pcall(function()
        local cas = game:GetService("ContextActionService")
        cas:UnbindAction("DisableShiftLock")
        cas:UnbindAction("DisableCtrlSwitch")
    end)
    if getgenv().wallhackLoop         then getgenv().wallhackLoop:Disconnect();         getgenv().wallhackLoop = nil end
    if getgenv().fullbrightLoop       then getgenv().fullbrightLoop:Disconnect();       getgenv().fullbrightLoop = nil end
    if getgenv().noDamageLoop         then getgenv().noDamageLoop:Disconnect();         getgenv().noDamageLoop = nil end
    if getgenv().followConnection     then getgenv().followConnection:Disconnect();     getgenv().followConnection = nil end
    if getgenv().noclipConnection     then getgenv().noclipConnection:Disconnect();     getgenv().noclipConnection = nil end
    if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect(); getgenv().infiniteJumpConnection = nil end
    if getgenv().hitboxRestoreFunc    then pcall(getgenv().hitboxRestoreFunc);          getgenv().hitboxRestoreFunc = nil end
    if getgenv().noDamageRestoreFunc  then pcall(getgenv().noDamageRestoreFunc);        getgenv().noDamageRestoreFunc = nil end
    if getgenv().ESPContainer         then pcall(function() getgenv().ESPContainer:Destroy() end); getgenv().ESPContainer = nil end
    if getgenv().ScreenGui            then pcall(function() getgenv().ScreenGui:Destroy()    end); getgenv().ScreenGui    = nil end
end

-- Wire UI
if getgenv().HideButton then
    getgenv().HideButton.MouseButton1Down:Connect(function()
        if getgenv().ToggleUI then getgenv().ToggleUI() end
    end)
end
if getgenv().CloseButton then
    getgenv().CloseButton.MouseButton1Click:Connect(function()
        if getgenv().destroyScript then pcall(getgenv().destroyScript) end
    end)
end

-- Background Loops
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    if getgenv().updateFlight then getgenv().updateFlight() end

    if getgenv().deathCheckEnabled and getgenv().followEnabled and getgenv().followTarget then
        local targetDead = false
        if not getgenv().followTarget.Character then targetDead = true
        else local hum = getgenv().followTarget.Character:FindFirstChildOfClass("Humanoid")
             if not hum or hum.Health <= 0 then targetDead = true end end
        if targetDead then
            if getgenv().autoSwitchEnabled then
                local deadTarget = getgenv().followTarget; getgenv().pushHistory(deadTarget)
                local nextTarget = getgenv().Utils and getgenv().Utils:FindNearestAlivePlayer(deadTarget)
                if nextTarget then
                    getgenv().followTarget = nextTarget
                    pcall(function() StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[Follow] Target died - switching to " .. nextTarget.Name; Color = Color3.fromRGB(255, 160, 0); Font = Enum.Font.GothamBold;}) end)
                else
                    if getgenv().stopFollow then getgenv().stopFollow() end
                    pcall(function() StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[Follow] Target died - no other players found."; Color = Color3.fromRGB(255, 80, 80); Font = Enum.Font.GothamBold;}) end)
                end
            else
                if getgenv().stopFollow then getgenv().stopFollow() end
                pcall(function() StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[Follow] Target died - follow stopped."; Color = Color3.fromRGB(255, 80, 80); Font = Enum.Font.GothamBold;}) end)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.C then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            if getgenv().ToggleUI then getgenv().ToggleUI() end
        end
    end
end)

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
        getgenv().HudLabel.Text = string.format("<font color=\"#%02x%02x%02x\">FPS: %d</font>  <font color=\"#606070\">|</font>  <font color=\"#%02x%02x%02x\">%dms</font>", math.floor(fpsCol.R*255), math.floor(fpsCol.G*255), math.floor(fpsCol.B*255), fpsInt, math.floor(pingCol.R*255), math.floor(pingCol.G*255), math.floor(pingCol.B*255), getgenv().lastPingMs)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if not getgenv().scriptEnabled then return end
    if getgenv().speedhackEnabled then local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = getgenv().walkSpeed * getgenv().speedMultiplier; hum.JumpPower = getgenv().jumpPower * getgenv().speedMultiplier end
    end
    if getgenv().infiniteJumpEnabled then
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect() end
        getgenv().infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if getgenv().infiniteJumpEnabled and getgenv().scriptEnabled then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end)
    end
    if getgenv().reachEnabled and getgenv().enableReach then pcall(getgenv().enableReach) end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if getgenv().hitboxEnabled then task.wait(0.5); if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if getgenv().ScreenGui then local parts = {player.Name.."_Name", player.Name.."_Distance", player.Name.."_2DBox"}
        for _, n in pairs(parts) do local o = getgenv().ScreenGui:FindFirstChild(n); if o then o:Destroy() end end
    end
    if getgenv().ESPContainer then local b3 = getgenv().ESPContainer:FindFirstChild(player.Name .. "_Box"); if b3 then b3:Destroy() end end
end)

pcall(function()
    LocalPlayer.OnTeleport:Connect(function(teleportState)
        if teleportState == Enum.TeleportState.Started or teleportState == Enum.TeleportState.InProgress or teleportState == Enum.TeleportState.RequestedFromServer then pcall(getgenv().destroyScript) end
    end)
end)

pcall(function() if getgenv().loadSettings then getgenv().loadSettings() end end)
if getgenv().Utils and getgenv().Utils.Notify then getgenv().Utils:Notify("RB Hub", "Ready. Hotkey: Shift + C", Color3.fromRGB(13, 110, 253)) end
