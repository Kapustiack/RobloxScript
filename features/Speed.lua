local LocalPlayer = game:GetService("Players").LocalPlayer

local Speed = {}

-- [[ RAW SPEED LOGIC - Migrated 1:1 from rb.lua ]]
-- Lines 1269 - 1301, 1984 - 2011, 2231 - 2244, 2536 - 2550

function Speed:Update(state)
    if not state.scriptEnabled then return end
    if state.speedhackEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed ~= state.walkSpeed * state.speedMultiplier then
                    hum.WalkSpeed = state.walkSpeed * state.speedMultiplier
                end
                if hum.JumpPower ~= state.jumpPower * state.speedMultiplier then
                    hum.JumpPower = state.jumpPower * state.speedMultiplier
                end
            end
        end
    end
end

return Speed
