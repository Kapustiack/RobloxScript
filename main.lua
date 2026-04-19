-- [[ RB MODULAR HUB - EMERGENCEY REPAIR V2 ]]
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
Main.Name = "Main"; Main.Parent = LoaderGui; Main.BackgroundColor3 = Color3.fromRGB(13, 13, 20); Main.BorderSizePixel = 0; Main.Position = UDim2.new(0.5, -150, 0.5, -50); Main.Size = UDim2.new(0, 300, 0, 100); Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MStroke = Instance.new("UIStroke", Main); MStroke.Color = Color3.fromRGB(40, 40, 50); MStroke.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Name = "Title"; Title.Parent = Main; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 10, 0, 8); Title.Size = UDim2.new(1, -20, 0, 20); Title.Font = Enum.Font.GothamBold; Title.Text = "RB MODULAR HUB"; Title.TextColor3 = Color3.fromRGB(205, 205, 222); Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("Status"); Status.Name = "Status"; Status.Parent = Main; Status.BackgroundTransparency = 1; Status.Position = UDim2.new(0, 10, 0, 32); Status.Size = UDim2.new(1, -20, 0, 18); Status.Font = Enum.Font.Gotham; Status.Text = "Initializing..."; Status.TextColor3 = Color3.fromRGB(80, 80, 100); Status.TextSize = 11; Status.TextXAlignment = Enum.TextXAlignment.Left

local ProgressBG = Instance.new("Frame")
ProgressBG.Name = "ProgressBG"; ProgressBG.Parent = Main; ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 30, 44); ProgressBG.BorderSizePixel = 0; ProgressBG.Position = UDim2.new(0, 10, 0, 60); ProgressBG.Size = UDim2.new(1, -20, 0, 6)
Instance.new("UICorner", ProgressBG).CornerRadius = UDim.new(1, 0)

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"; ProgressBar.Parent = ProgressBG; ProgressBar.BackgroundColor3 = Color3.fromRGB(25, 145, 80); ProgressBar.BorderSizePixel = 0; ProgressBar.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

local Percent = Instance.new("TextLabel")
Percent.Name = "Percent"; Percent.Parent = Main; Percent.BackgroundTransparency = 1; Percent.Position = UDim2.new(0, 10, 0, 72); Percent.Size = UDim2.new(1, -20, 0, 18); Percent.Font = Enum.Font.Gotham; Percent.Text = "0%"; Percent.TextColor3 = Color3.fromRGB(120, 120, 130); Percent.TextSize = 10; Percent.TextXAlignment = Enum.TextXAlignment.Right

-- [[ CORE RECOVERY LOGIC (DEFINED BEFORE LOADER) ]]
getgenv().destroyScript = function()
    getgenv().scriptEnabled = false
    pcall(function()
        if getgenv().stopFollow        then getgenv().stopFollow()           end
        if getgenv().disableReach      then getgenv().disableReach()         end
        if getgenv().disableFlight     then getgenv().disableFlight()        end
        if getgenv().disableNoclip     then getgenv().disableNoclip()        end
        if getgenv().disableInfiniteJump then getgenv().disableInfiniteJump() end
        if getgenv().disableNoFallDamage then getgenv().disableNoFallDamage() end
        if getgenv().disableFreeCamera  then getgenv().disableFreeCamera()    end
        if getgenv().Hooks and getgenv().Hooks.UninstallMainHook then getgenv().Hooks:UninstallMainHook() end
        
        if getgenv().ESPContainer then getgenv().ESPContainer:Destroy() end
        if getgenv().ScreenGui    then getgenv().ScreenGui:Destroy()    end
    end)
end

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
    if not success or not content or content == "" then return nil end
    
    local func, err = loadstring(content)
    if not func then warn("[RB Hub] Syntax Error: " .. path .. " | " .. tostring(err)); return nil end
    
    local ok, res = pcall(func)
    return res -- Returns the module (e.g. Hooks table)
end

-- [[ FILE ORCHESTRATION (Corrected Order) ]]
local files = {
    "modules/Utils.lua", "modules/Hooks.lua", "modules/State.lua", "modules/UI.lua",
    "modules/Save.lua", "modules/Input.lua", "features/Hitbox.lua", -- Hitbox before NoDamage
    "features/Flight.lua", "features/Noclip.lua", "features/InfiniteJump.lua", 
    "features/NoDamage.lua", "features/Reach.lua", "features/Follow.lua", 
    "features/ESP.lua", "features/Speed.lua", "features/Misc.lua", 
    "features/FreeCamera.lua", "features/LowGravity.lua", "features/FreezeSelf.lua", 
    "features/TeleportToPlayer.lua", "features/Waypoints.lua"
}

-- 1. Wire UI Toggles BEFORE Loadingfeatures
task.spawn(function()
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.C and (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) then
            if getgenv().ToggleUI then getgenv().ToggleUI() end
        end
    end)
end)

-- 2. RUN LOADER
for i, path in ipairs(files) do
    updateLoader(path, i)
    local result = loadRemote(path)
    if path == "modules/Hooks.lua" then getgenv().Hooks = result end
    task.wait(0.02)
end

-- Finalize Loader
Status.Text = "Initialization Complete!"
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 300, 0, 0), Position = UDim2.new(0.5, -150, 0.5, 0)}):Play()
task.wait(0.6)
LoaderGui:Destroy()

-- Background Loops
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if not getgenv().scriptEnabled then return end
    if getgenv().updateSpeedLoop then getgenv().updateSpeedLoop() end
    if getgenv().updateESP then getgenv().updateESP() end
    if getgenv().applyHitboxExpansion then getgenv().applyHitboxExpansion() end
    if getgenv().updateFlight then getgenv().updateFlight() end
end)

pcall(function() if getgenv().loadSettings then getgenv().loadSettings() end end)
if getgenv().Utils and getgenv().Utils.Notify then getgenv().Utils:Notify("RB Hub", "Ready. Hotkey: Shift + C", Color3.fromRGB(13, 110, 253)) end
