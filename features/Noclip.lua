-- [[ NOCLIP — Infinite Recursive Assembly Update ]]
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function enableNoclip()
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect() end
    getgenv().noclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().noclipEnabled or not getgenv().scriptEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end

        local pList = {} -- To avoid redundant lookups
        local stack = {}
        
        -- Start discovery with Character components
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(stack, p) end
        end
        
        -- Include Seats and everything the character is sitting on
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then table.insert(stack, hum.SeatPart) end

        -- Recursive discovery through rigid and dynamic connections
        local seen = {}
        local count = 0
        while #stack > 0 and count < 1000 do -- Safety cap to prevent freezes
            count = count + 1
            local p = table.remove(stack)
            if p and not seen[p] then
                seen[p] = true
                if p.CanCollide then p.CanCollide = false end
                
                -- Rigid connections (Welds, Motor6Ds, Snap joints)
                for _, conn in pairs(p:GetConnectedParts(true)) do
                    if not seen[conn] then table.insert(stack, conn) end
                end
                
                -- Dynamic connections (Constraints like Ropes, Hinges, BallSockets for Trailers)
                -- We check descendants of parts for attachments/constraints to hop to the next part
                for _, child in pairs(p:GetChildren()) do
                    if child:IsA("Constraint") then
                        local a0 = child.Attachment0
                        local a1 = child.Attachment1
                        if a0 and a0.Parent and a0.Parent:IsA("BasePart") and not seen[a0.Parent] then
                            table.insert(stack, a0.Parent)
                        end
                        if a1 and a1.Parent and a1.Parent:IsA("BasePart") and not seen[a1.Parent] then
                            table.insert(stack, a1.Parent)
                        end
                    elseif child:IsA("Attachment") then
                        -- Sometimes constraints are child of Attachment or parent, we check both directions
                    end
                end
            end
        end
    end)
end

local function disableNoclip()
    getgenv().noclipEnabled = false
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    local char = LocalPlayer.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

getgenv().NoclipButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().noclipEnabled = not getgenv().noclipEnabled
    getgenv().NoclipButton.Text = "Noclip: " .. (getgenv().noclipEnabled and "ON" or "OFF")
    getgenv().NoclipButton.BackgroundColor3 = getgenv().noclipEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().noclipEnabled then enableNoclip() else disableNoclip() end
end)

getgenv().disableNoclip = disableNoclip
