local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function applyInfJump()
    -- Disconnect any existing connections first
    if getgenv().infiniteJumpConnection then
        getgenv().infiniteJumpConnection:Disconnect()
        getgenv().infiniteJumpConnection = nil
    end
    if getgenv().infJumpHoldConnection then
        getgenv().infJumpHoldConnection:Disconnect()
        getgenv().infJumpHoldConnection = nil
    end

    if not getgenv().infiniteJumpEnabled then return end

    if getgenv().infJumpHoldMode then
        local holding = false
        getgenv().infJumpHoldConnection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode ~= Enum.KeyCode.Space then return end
            if not getgenv().infiniteJumpEnabled or not getgenv().scriptEnabled then return end
            holding = true
            task.spawn(function()
                while holding and getgenv().infiniteJumpEnabled and getgenv().scriptEnabled do
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    task.wait(0.08)
                end
            end)
        end)
        getgenv().infiniteJumpConnection = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then holding = false end
        end)
    else
        getgenv().infiniteJumpConnection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
                if not getgenv().infiniteJumpEnabled or not getgenv().scriptEnabled then return end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end

local function disableInfiniteJump()
    getgenv().infiniteJumpEnabled = false
    if getgenv().infiniteJumpConnection then
        getgenv().infiniteJumpConnection:Disconnect()
        getgenv().infiniteJumpConnection = nil
    end
    if getgenv().infJumpHoldConnection then
        getgenv().infJumpHoldConnection:Disconnect()
        getgenv().infJumpHoldConnection = nil
    end
end

getgenv().InfiniteJumpButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().infiniteJumpEnabled = not getgenv().infiniteJumpEnabled
    getgenv().InfiniteJumpButton.Text = "Inf Jump: " .. (getgenv().infiniteJumpEnabled and "ON" or "OFF")
    getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().infiniteJumpEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().infiniteJumpEnabled then applyInfJump() else disableInfiniteJump() end
end)

if getgenv().BindPanelButton and getgenv().InfiniteJumpSettingsFrame then
    getgenv().BindPanelButton(getgenv().InfiniteJumpButton, getgenv().InfiniteJumpSettingsFrame)
end

getgenv().InfJumpModeBtn.MouseButton1Click:Connect(function()
    getgenv().infJumpHoldMode = not getgenv().infJumpHoldMode
    local modeText = getgenv().infJumpHoldMode and "Hold" or "Instant"
    getgenv().InfJumpModeBtn.Text = "Mode: " .. modeText
    getgenv().InfJumpModeBtn.BackgroundColor3 = getgenv().infJumpHoldMode and getgenv().COL_ON or getgenv().COL_OFF
    -- If currently active, restart with new mode immediately
    if getgenv().infiniteJumpEnabled then
        applyInfJump()
    end
end)

getgenv().disableInfiniteJump = disableInfiniteJump
getgenv().applyInfiniteJump = applyInfJump
