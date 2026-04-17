-- [[ INFINITE JUMP — Fully wired, 1:1 from rb.lua ]]
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function enableInfiniteJump()
    if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect() end
    getgenv().infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not getgenv().infiniteJumpEnabled or not getgenv().scriptEnabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function disableInfiniteJump()
    getgenv().infiniteJumpEnabled = false
    if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect(); getgenv().infiniteJumpConnection = nil end
end

getgenv().InfiniteJumpButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().infiniteJumpEnabled = not getgenv().infiniteJumpEnabled
    getgenv().InfiniteJumpButton.Text = "Inf Jump: " .. (getgenv().infiniteJumpEnabled and "ON" or "OFF")
    getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().infiniteJumpEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().infiniteJumpEnabled then enableInfiniteJump() else disableInfiniteJump() end
end)

getgenv().disableInfiniteJump = disableInfiniteJump
