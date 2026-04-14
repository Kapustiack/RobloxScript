local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Wallhack = {}
Wallhack.Enabled = false

function Wallhack:Toggle(state)
    self.Enabled = state
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = state and 0.5 or 0
                end
            end
        end
    end
end

return Wallhack
