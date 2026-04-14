local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Noclip = {}
Noclip.Enabled = false
Noclip.Connection = nil

function Noclip:Toggle(state)
    self.Enabled = state
    if state then
        self.Connection = RunService.Stepped:Connect(function()
            if not self.Enabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
    end
end

return Noclip
