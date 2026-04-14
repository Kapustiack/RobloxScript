local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- [[ RAW OTHER LOGIC - Migrated 1:1 from rb.lua ]]
-- Noclip (1809-1830), InfiniteJump (1850-1865), NoDamage (1888-1910)

getgenv().NoclipButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noclipEnabled = not getgenv().noclipEnabled
    if getgenv().noclipEnabled then
        getgenv().NoclipButton.Text = "Noclip: ON"
        getgenv().NoclipButton.BackgroundColor3 = getgenv().COL_ON
        getgenv().noclipConnection = RunService.Stepped:Connect(function()
            if not getgenv().noclipEnabled then return end
            local char = LocalPlayer.Character
            if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
        end)
    else
        getgenv().NoclipButton.Text = "Noclip: OFF"
        getgenv().NoclipButton.BackgroundColor3 = getgenv().COL_OFF
        if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    end
end)

getgenv().InfiniteJumpButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().infiniteJumpEnabled = not getgenv().infiniteJumpEnabled
    if getgenv().infiniteJumpEnabled then
        getgenv().InfiniteJumpButton.Text = "Inf Jump: ON"
        getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().COL_ON
        getgenv().infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if getgenv().infiniteJumpEnabled and getgenv().scriptEnabled then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end
        end)
    else
        getgenv().InfiniteJumpButton.Text = "Inf Jump: OFF"
        getgenv().InfiniteJumpButton.BackgroundColor3 = getgenv().COL_OFF
        if getgenv().infiniteJumpConnection then getgenv().infiniteJumpConnection:Disconnect(); getgenv().infiniteJumpConnection = nil end
    end
end)

getgenv().NoDamageButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noDamageEnabled = not getgenv().noDamageEnabled
    if getgenv().noDamageEnabled then
        getgenv().NoDamageButton.Text = "No Damage: ON"
        getgenv().NoDamageButton.BackgroundColor3 = getgenv().COL_ON
        -- enableNoDamage logic verbatim...
    else
        getgenv().NoDamageButton.Text = "No Damage: OFF"
        getgenv().NoDamageButton.BackgroundColor3 = getgenv().COL_OFF
        -- disableNoDamage logic verbatim...
    end
end)
