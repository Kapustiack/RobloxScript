local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local InfiniteJump = {}
InfiniteJump.Enabled = false
InfiniteJump.Connection = nil

function InfiniteJump:Toggle(state)
    self.Enabled = state
    
    if state then
        if self.Connection then self.Connection:Disconnect() end
        self.Connection = UserInputService.JumpRequest:Connect(function()
            if not self.Enabled then return end
            local character = LocalPlayer.Character
            if character and character:FindFirstChildOfClass("Humanoid") then
                character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
    end
end

return InfiniteJump
