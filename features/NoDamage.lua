-- [[ NO FALL DAMAGE — SCRIPT DISABLING EDITION ]]
-- This version removes physics manipulation and instead kills the local scripts.
-- Layer 1: Script Killing (Disables LocalScripts in Character/Backpack)
-- Layer 2: Signal Blinding (getconnections)
-- Layer 3: Remote Interceptor (via Hooks.lua)

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local disabledScripts = {}

local function blindCharacter(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not getconnections then return end
    local events = {"StateChanged", "Climbing", "FallingDown", "Ragdoll", "Jumping", "Seated"}
    for _, evtName in ipairs(events) do
        pcall(function()
            local evt = hum[evtName]
            if evt then for _, conn in pairs(getconnections(evt)) do conn:Disable() end end
        end)
    end
end

local function killAggressiveScripts()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    local function process(container)
        if not container then return end
        for _, s in pairs(container:GetDescendants()) do
            if s:IsA("LocalScript") and not disabledScripts[s] then
                local name = string.lower(s.Name)
                -- Avoid disabling essential movement/animation scripts
                if name ~= "animate" and name ~= "health" and name ~= "playermodule" then
                    disabledScripts[s] = s.Disabled
                    s.Disabled = true
                    -- warn("[RB Hub] Killed Script: " .. s.Name)
                end
            end
        end
    end
    
    process(char)
    process(backpack)
end

local function restoreScripts()
    for s, state in pairs(disabledScripts) do
        pcall(function()
            if s and s.Parent then
                s.Disabled = state
            end
        end)
    end
    disabledScripts = {}
end

local function enableNoFallDamage()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = true
    
    -- Layer 1: Kill Scripts
    killAggressiveScripts()
    
    -- Layer 2: Blind Signals
    local char = LocalPlayer.Character
    if char then blindCharacter(char) end

    -- Layer 3: Hooks (Interception)
    if getgenv().Hooks and getgenv().Hooks.InstallMainHook then
        getgenv().Hooks:InstallMainHook(getgenv().HitboxConfig)
    end

    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect() end
    
    -- Maintainance Loop (Keeps scripts dead if new ones are added)
    getgenv().noFallDamageLoop = RunService.Heartbeat:Connect(function()
        if not (getgenv().noFallDamageEnabled and getgenv().scriptEnabled) then return end
        
        local mchar = LocalPlayer.Character
        local mhum = mchar and mchar:FindFirstChildOfClass("Humanoid")
        
        if mhum then
            -- Force Stiffening (Prevents flailing without slowing fall)
            mhum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            mhum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            mhum.PlatformStand = false
            
            -- State Reset
            if mhum:GetState() == Enum.HumanoidStateType.Freefall then
                mhum:ChangeState(Enum.HumanoidStateType.Running)
            end
            
            -- Re-check for any new scripts spawning
            killAggressiveScripts()
        end
    end)
end

local function disableNoFallDamage()
    getgenv().noFallDamageEnabled = false
    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect(); getgenv().noFallDamageLoop = nil end
    
    restoreScripts()
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = not getgenv().noFallDamageEnabled
    getgenv().NoDamageButton.Text = "No Fall Damage: " .. (getgenv().noFallDamageEnabled and "ON" or "OFF")
    getgenv().NoDamageButton.BackgroundColor3 = getgenv().noFallDamageEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noFallDamageEnabled then enableNoFallDamage() else disableNoFallDamage() end
end)

getgenv().disableNoFallDamage = disableNoFallDamage
