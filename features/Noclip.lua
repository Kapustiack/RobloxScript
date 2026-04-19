-- [[ NOCLIP — Infinite Recursive + Unstuck + Perfect Restoration ]]
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

getgenv().noclipOriginalStates = getgenv().noclipOriginalStates or {}

local function enableNoclip()
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect() end
    getgenv().noclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().noclipEnabled or not getgenv().scriptEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        local stack = {}
        local seen = {}
        
        -- 1. Initialize discovery with Character and Seats
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(stack, p) end
        end
        if hum and hum.SeatPart then table.insert(stack, hum.SeatPart) end
        
        -- 2. Recursive Discovery (Traverses Welds + Constraints)
        local count = 0
        while #stack > 0 and count < 1500 do
            count = count + 1
            local p = table.remove(stack)
            if p and not seen[p] then
                seen[p] = true
                
                -- MEMORY: Store original state before modification
                if not getgenv().noclipOriginalStates[p] then
                    getgenv().noclipOriginalStates[p] = {
                        CanCollide = p.CanCollide,
                        Anchored = p.Anchored
                    }
                end

                -- NOCLIP: Set collision to false
                if p.CanCollide then p.CanCollide = false end
                
                -- UNSTUCK: Unanchor connected objects (Replicates better if user owns the assembly)
                if p.Anchored and p ~= hrp and not p:IsDescendantOf(char) then 
                    p.Anchored = false 
                    -- Wake up physics for replication
                    pcall(function() p.AssemblyLinearVelocity = Vector3.new(0,0.01,0) end)
                end
                
                -- Expand search to Rigidly Connected Parts
                for _, conn in pairs(p:GetConnectedParts(true)) do
                    if not seen[conn] then table.insert(stack, conn) end
                end
                
                -- Expand search to Dynamic Constraints
                for _, child in pairs(p:GetChildren()) do
                    if child:IsA("Constraint") then
                        local a0 = child.Attachment0; local a1 = child.Attachment1
                        if a0 and a0.Parent and a0.Parent:IsA("BasePart") and not seen[a0.Parent] then table.insert(stack, a0.Parent) end
                        if a1 and a1.Parent and a1.Parent:IsA("BasePart") and not seen[a1.Parent] then table.insert(stack, a1.Parent) end
                    end
                end
            end
        end
    end)
end

local function disableNoclip()
    getgenv().noclipEnabled = false
    if getgenv().noclipConnection then getgenv().noclipConnection:Disconnect(); getgenv().noclipConnection = nil end
    
    -- PERFECT RESTORATION: Use the memory table to restore EVERY affected part
    for part, state in pairs(getgenv().noclipOriginalStates) do
        pcall(function()
            if part and part.Parent then
                part.CanCollide = state.CanCollide
                part.Anchored = state.Anchored
            end
        end)
    end
    
    -- Clear memory for next use
    getgenv().noclipOriginalStates = {}
    
    -- Double-check character specifically (fail-safe)
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
