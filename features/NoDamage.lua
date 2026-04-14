local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local NoDamage = {}
NoDamage.Enabled = false
NoDamage.Connection = nil

function NoDamage:Toggle(state)
    self.Enabled = state
    
    if state then
        if self.Connection then self.Connection:Disconnect() end
        self.Connection = RunService.Heartbeat:Connect(function()
            if not self.Enabled then return end
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
    end
end

return NoDamage
