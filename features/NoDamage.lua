-- [[ NO FALL DAMAGE — Advanced Multi-Layer Protection ]]
-- Method 1: State Disabling (Prevents StateChanged triggers)
-- Method 2: Velocity Zeroing (Detects impact and stops downward force)
-- Method 3: Health Locker (Backup guard)

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function installNoFallDamageHook()
    -- Hooking to prevent death logic in some games
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return nil end
    pcall(setreadonly, mt, false)
    local old_ni = rawget(mt, "__newindex")
    if not old_ni then pcall(setreadonly, mt, true); return nil end
    
    local function hookedNewindex(self, key, value)
        if getgenv().noFallDamageEnabled and getgenv().scriptEnabled and key == "Health"
                and typeof(self) == "Instance" and self:IsA("Humanoid") then
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum and self == myHum and typeof(value) == "number" and value < myHum.Health then
                -- Check if we are in a falling state or just landed
                local state = myHum:GetState()
                if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.FallingDown then
                    return old_ni(self, key, myHum.Health) -- Block the damage
                end
            end
        end
        return old_ni(self, key, value)
    end
    
    rawset(mt, "__newindex", (newcclosure and newcclosure(hookedNewindex)) or hookedNewindex)
    pcall(setreadonly, mt, true)
    return function()
        local ok2, mt2 = pcall(getrawmetatable, game)
        if ok2 and mt2 then pcall(setreadonly, mt2, false); rawset(mt2, "__newindex", old_ni); pcall(setreadonly, mt2, true) end
    end
end

local function enableNoFallDamage()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = true
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Layer 1: State Disabling
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
    
    -- Layer 2: Velocity & State Monitoring
    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect() end
    getgenv().noFallDamageLoop = RunService.Heartbeat:Connect(function()
        if not (getgenv().noFallDamageEnabled and getgenv().scriptEnabled) then return end
        local mchar = LocalPlayer.Character
        local mhum = mchar and mchar:FindFirstChildOfClass("Humanoid")
        local mhrp = mchar and mchar:FindFirstChild("HumanoidRootPart")
        
        if mhum and mhrp then
            local state = mhum:GetState()
            -- If landing with high velocity, zero it out instantly
            if (state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running) and mhrp.AssemblyLinearVelocity.Y < -10 then
                mhrp.AssemblyLinearVelocity = Vector3.new(mhrp.AssemblyLinearVelocity.X, 0, mhrp.AssemblyLinearVelocity.Z)
            end
            
            -- Backup: Health Guard
            if mhum.Health > 0 and mhum.Health < mhum.MaxHealth then
                mhum.Health = mhum.MaxHealth
            end
        end
    end)

    if not getgenv().noFallDamageRestoreFunc then
        getgenv().noFallDamageRestoreFunc = installNoFallDamageHook()
    end
end

local function disableNoFallDamage()
    getgenv().noFallDamageEnabled = false
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect(); getgenv().noFallDamageLoop = nil end
    if getgenv().noFallDamageRestoreFunc then pcall(getgenv().noFallDamageRestoreFunc); getgenv().noFallDamageRestoreFunc = nil end
end

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = not getgenv().noFallDamageEnabled
    getgenv().NoDamageButton.Text = "No Fall Damage: " .. (getgenv().noFallDamageEnabled and "ON" or "OFF")
    getgenv().NoDamageButton.BackgroundColor3 = getgenv().noFallDamageEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noFallDamageEnabled then enableNoFallDamage() else disableNoFallDamage() end
end)

getgenv().disableNoFallDamage = disableNoFallDamage
