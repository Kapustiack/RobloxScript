-- [[ NO FALL DAMAGE — ULTIMATE BYPASS + STIFFENING ]]
-- Layer 1: Script Blinding (getconnections)
-- Layer 2: Remote Interceptor (Hooks.lua)
-- Layer 3: Physics Spoofing & Hard Anchor (PreSimulation)
-- Layer 4: State Forcing & Stiffening (Prevents "Flailing")

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

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

local function enableNoFallDamage()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = true
    
    local char = LocalPlayer.Character
    if char then blindCharacter(char) end

    if getgenv().Hooks and getgenv().Hooks.InstallMainHook then
        getgenv().Hooks:InstallMainHook(getgenv().HitboxConfig)
    end

    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect() end
    
    getgenv().noFallDamageLoop = RunService.PreSimulation:Connect(function()
        if not (getgenv().noFallDamageEnabled and getgenv().scriptEnabled) then return end
        local mchar = LocalPlayer.Character
        local mhum = mchar and mchar:FindFirstChildOfClass("Humanoid")
        local mhrp = mchar and mchar:FindFirstChild("HumanoidRootPart")
        
        if mhum and mhrp then
            -- 1. STIFFENING (Prevents Flailing/Limp movement)
            mhum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            mhum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            mhum.PlatformStand = false -- Force character to stand upright
            
            local state = mhum:GetState()
            
            -- 2. STATE FORCING (Reset Fall Timers)
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.FallingDown then
                mhum:ChangeState(Enum.HumanoidStateType.Running)
            end

            -- 3. PHYSICS ZEROING & ANCHOR (Hard STOP on impact)
            if mhrp.AssemblyLinearVelocity.Y < -5 then
                local floorRay = workspace:Raycast(mhrp.Position, Vector3.new(0, -10, 0))
                if floorRay then
                    -- Detect impact imminent: Reset velocity AND briefly anchor to kill momentum
                    mhrp.AssemblyLinearVelocity = Vector3.new(mhrp.AssemblyLinearVelocity.X, 0, mhrp.AssemblyLinearVelocity.Z)
                    
                    if not mhrp.Anchored then
                        mhrp.Anchored = true
                        task.delay(0.1, function() 
                            if mhrp and getgenv().noFallDamageEnabled then mhrp.Anchored = false end 
                        end)
                    end
                end
            end
            
            -- 4. HEALTH GUARD (Backup)
            if mhum.Health > 0 and mhum.Health < mhum.MaxHealth then
                mhum.Health = mhum.MaxHealth
            end
        end
    end)
end

local function disableNoFallDamage()
    getgenv().noFallDamageEnabled = false
    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect(); getgenv().noFallDamageLoop = nil end
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
