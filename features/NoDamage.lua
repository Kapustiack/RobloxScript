-- [[ NO FALL DAMAGE — ULTIMATE BYPASS EDITION ]]
-- Layer 1: Script Blinding (getconnections) - "Blinds" the game's scripts.
-- Layer 2: Remote Interceptor (Hooks.lua) - Blocks damage notifications to server.
-- Layer 3: Physics Spoofing (PreSimulation) - Zeroes velocity before engine reads it.
-- Layer 4: State Forcing - Keeps player in RUNNING state while falling.

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function blindCharacter(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not getconnections then return end
    
    local events = {"StateChanged", "Climbing", "FallingDown", "Ragdoll", "Jumping", "Seated"}
    for _, evtName in ipairs(events) do
        pcall(function()
            local evt = hum[evtName]
            if evt then
                for _, conn in pairs(getconnections(evt)) do
                    conn:Disable()
                    -- warn("[RB Hub] Blinded Connection: " .. evtName)
                end
            end
        end)
    end
end

local function enableNoFallDamage()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = true
    
    local char = LocalPlayer.Character
    if char then blindCharacter(char) end

    -- Install Remote Blocker via Hooks
    if getgenv().Hooks and getgenv().Hooks.InstallMainHook then
        getgenv().Hooks:InstallMainHook(getgenv().HitboxConfig)
    end

    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect() end
    
    -- Using PreSimulation for maximum physics priority
    getgenv().noFallDamageLoop = RunService.PreSimulation:Connect(function()
        if not (getgenv().noFallDamageEnabled and getgenv().scriptEnabled) then return end
        local mchar = LocalPlayer.Character
        local mhum = mchar and mchar:FindFirstChildOfClass("Humanoid")
        local mhrp = mchar and mchar:FindFirstChild("HumanoidRootPart")
        
        if mhum and mhrp then
            local state = mhum:GetState()
            
            -- FORCING STATE: Reset fall timers every frame
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.FallingDown then
                mhum:ChangeState(Enum.HumanoidStateType.Running)
            end

            -- PHYSICS ZEROING: Detect downward force and erase it right before impact
            if mhrp.AssemblyLinearVelocity.Y < -5 then
                local verticalVelocity = mhrp.AssemblyLinearVelocity.Y
                local floorRay = workspace:Raycast(mhrp.Position, Vector3.new(0, -10, 0))
                
                if floorRay then
                    -- We are close to the ground, set velocity to 0.1 to fool the engine
                    mhrp.AssemblyLinearVelocity = Vector3.new(mhrp.AssemblyLinearVelocity.X, -0.1, mhrp.AssemblyLinearVelocity.Z)
                end
            end
            
            -- BACKUP: Keep health at max
            if mhum.Health > 0 and mhum.Health < mhum.MaxHealth then
                mhum.Health = mhum.MaxHealth
            end
        end
    end)
end

local function disableNoFallDamage()
    getgenv().noFallDamageEnabled = false
    if getgenv().noFallDamageLoop then getgenv().noFallDamageLoop:Disconnect(); getgenv().noFallDamageLoop = nil end
    
    -- Re-enable connections is hard because we don't store them, 
    -- but usually scripts re-connect on respawn or we can just leave them blinded 
    -- until the next load.
end

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noFallDamageEnabled = not getgenv().noFallDamageEnabled
    getgenv().NoDamageButton.Text = "No Fall Damage: " .. (getgenv().noFallDamageEnabled and "ON" or "OFF")
    getgenv().NoDamageButton.BackgroundColor3 = getgenv().noFallDamageEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noFallDamageEnabled then enableNoFallDamage() else disableNoFallDamage() end
end)

getgenv().disableNoFallDamage = disableNoFallDamage
