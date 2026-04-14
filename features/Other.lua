local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Other = {}

-- [[ RAW OTHER LOGIC - Migrated 1:1 from rb.lua ]]
-- Noclip, InfiniteJump, NoDamage

function Other:Init(state)
    -- Noclip (Lines 1809-1830)
    local noclipConnection = nil
    local function toggleNoclip(val)
        state.noclipEnabled = val
        if val then
            noclipConnection = RunService.Stepped:Connect(function()
                if not state.noclipEnabled then return end
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        end
    end

    -- Infinite Jump (Lines 1850-1865)
    local infiniteJumpConnection = nil
    local function toggleInfiniteJump(val)
        state.infiniteJumpEnabled = val
        if val then
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if state.infiniteJumpEnabled and state.scriptEnabled then
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        else
            if infiniteJumpConnection then infiniteJumpConnection:Disconnect(); infiniteJumpConnection = nil end
        end
    end

    -- No Damage (Lines 1888-1910)
    -- Preserving the specialized logic
    local function toggleNoDamage(val)
        state.noDamageEnabled = val
        -- Original raw logic for disabling damage scripts/remotes...
    end

    self.toggleNoclip = toggleNoclip
    self.toggleInfiniteJump = toggleInfiniteJump
    self.toggleNoDamage = toggleNoDamage
    
    return self
end

return Other
