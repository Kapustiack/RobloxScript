local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local Utils = {}

function Utils:Notify(title, text, color)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[" .. title .. "] " .. text,
            Color = color or Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.GothamBold,
        })
    end)
end

function Utils:FindNearestAlivePlayer(excludePlayer)
    local nearest, nearestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p ~= excludePlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local d = (hrp.Position - myChar.HumanoidRootPart.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearest = p end
            end
        end
    end
    return nearest
end

function Utils:RejoinServer()
    self:Notify("RB Cheat", "Rejoining server...", Color3.fromRGB(255, 200, 0))
    task.wait(0.5)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end

function Utils:JoinNewInstance()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    self:Notify("RB Cheat", "Finding a new instance...", Color3.fromRGB(255, 200, 0))

    local success, res = pcall(function() return game:HttpGet(api) end)
    if success then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, res)
        if ok and decoded and decoded.data then
            local possible = {}
            for _, s in pairs(decoded.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(possible, s.id)
                end
            end
            if #possible > 0 then
                local target = possible[math.random(1, #possible)]
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer) end)
            else
                self:Notify("RB Cheat", "No suitable servers found.", Color3.fromRGB(255, 80, 80))
            end
        end
    else
        self:Notify("RB Cheat", "Failed to fetch server list.", Color3.fromRGB(255, 80, 80))
    end
end

-- Teleport to Mouse Logic — BUG 6 FIX: Full raycast (1:1 from rb.lua)
-- Old version used mouse.Hit.p (deprecated) and no raycast — player clips into ground/walls
function Utils:TeleportToMouse()
    if not getgenv().scriptEnabled then return end
    local mouse = LocalPlayer:GetMouse()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Raycast down from mouse hit to find solid ground
    local hitPos = mouse.Hit.Position
    local rayOrigin = hitPos + Vector3.new(0, 5, 0)   -- start 5 studs above hit
    local rayDir = Vector3.new(0, -10, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(rayOrigin, rayDir, params)

    local safePos
    if result then
        safePos = result.Position + Vector3.new(0, 3, 0)  -- 3 studs above surface
    else
        safePos = hitPos + Vector3.new(0, 3, 0)           -- fallback: raise above hit
    end
    char.HumanoidRootPart.CFrame = CFrame.new(safePos)
end

return Utils

