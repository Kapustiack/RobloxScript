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
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

function Utils:JoinNewInstance()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    self:Notify("RB Cheat", "Finding a new instance...", Color3.fromRGB(255, 200, 0))

    local success, res = pcall(function() return game:HttpGet(api) end)
    if success then
        local decoded = HttpService:JSONDecode(res)
        if decoded and decoded.data then
            local possible = {}
            for _, s in pairs(decoded.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(possible, s.id)
                end
            end
            if #possible > 0 then
                local target = possible[math.random(1, #possible)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
            else
                self:Notify("RB Cheat", "No suitable servers found.", Color3.fromRGB(255, 80, 80))
            end
        end
    else
        self:Notify("RB Cheat", "Failed to fetch server list.", Color3.fromRGB(255, 80, 80))
    end
end

-- Teleport to Mouse Logic (1:1 from rb.lua)
function Utils:TeleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local targetPos = mouse.Hit.p + Vector3.new(0, 3, 0)
        char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
    end
end

return Utils
