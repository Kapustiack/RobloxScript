-- [[ NO DAMAGE — Fully wired, dual-layer from rb.lua ]]
-- Layer 1: __newindex hook intercepts Health writes
-- Layer 2: Heartbeat backup for games that bypass __newindex
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function installNoDamageHook()
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return nil end
    pcall(setreadonly, mt, false)
    local old_ni = rawget(mt, "__newindex")
    if not old_ni then pcall(setreadonly, mt, true); return nil end
    local function hookedNewindex(self, key, value)
        if getgenv().noDamageEnabled and getgenv().scriptEnabled and key == "Health"
                and typeof(self) == "Instance" and self:IsA("Humanoid") then
            local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum and self == myHum and typeof(value) == "number" and value < myHum.MaxHealth and value >= 0 then
                return old_ni(self, key, myHum.MaxHealth)
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

local function enableNoDamage()
    if not getgenv().scriptEnabled then return end
    getgenv().noDamageEnabled = true
    if not getgenv().noDamageRestoreFunc then
        getgenv().noDamageRestoreFunc = installNoDamageHook()
    end
    if getgenv().noDamageLoop then getgenv().noDamageLoop:Disconnect() end
    getgenv().noDamageLoop = RunService.Heartbeat:Connect(function()
        if not (getgenv().noDamageEnabled and getgenv().scriptEnabled) then return end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
    end)
end

local function disableNoDamage()
    getgenv().noDamageEnabled = false
    if getgenv().noDamageLoop then getgenv().noDamageLoop:Disconnect(); getgenv().noDamageLoop = nil end
    if getgenv().noDamageRestoreFunc then pcall(getgenv().noDamageRestoreFunc); getgenv().noDamageRestoreFunc = nil end
end

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noDamageEnabled = not getgenv().noDamageEnabled
    getgenv().NoDamageButton.Text = "No Damage: " .. (getgenv().noDamageEnabled and "ON" or "OFF")
    getgenv().NoDamageButton.BackgroundColor3 = getgenv().noDamageEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noDamageEnabled then enableNoDamage() else disableNoDamage() end
end)

getgenv().disableNoDamage = disableNoDamage
