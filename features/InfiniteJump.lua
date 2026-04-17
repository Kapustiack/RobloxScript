-- [[ INFINITE JUMP — With Hold Mode & Settings Panel ]]
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- ── Core enable/disable ────────────────────────────────────────────
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
        -- HOLD MODE: fires repeatedly while Space is physically held
        -- Uses InputBegan to detect press, then a loop fires jumps until released
        local holding = false
        getgenv().infJumpHoldConnection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode ~= Enum.KeyCode.Space then return end
            if not getgenv().infiniteJumpEnabled or not getgenv().scriptEnabled then return end
            holding = true
            -- Keep jumping while space held — fires every ~0.1s
            task.spawn(function()
                while holding and getgenv().infiniteJumpEnabled and getgenv().scriptEnabled do
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    task.wait(0.08)
                end
            end)
        end)
        -- Detect Space release → stop loop
        getgenv().infiniteJumpConnection = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then holding = false end
        end)
    else
        -- INSTANT MODE: fires on every JumpRequest (default, original behavior)
        getgenv().infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not getgenv().infiniteJumpEnabled or not getgenv().scriptEnabled then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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

-- ── InfiniteJumpButton: left click = toggle ────────────────────────
getgenv().InfiniteJumpButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().infiniteJumpEnabled = not getgenv().infiniteJumpEnabled
    getgenv().InfiniteJumpButton.Text = "Inf Jump: " .. (getgenv().infiniteJumpEnabled and "ON" or "OFF")
    getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().infiniteJumpEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().infiniteJumpEnabled then applyInfJump() else disableInfiniteJump() end
end)

-- ── InfiniteJumpButton: right click = open settings panel ──────────
getgenv().InfiniteJumpButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().InfiniteJumpSettingsFrame) end
end)

-- ── Settings panel: Mode toggle button ────────────────────────────
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
