local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

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
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not ok then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
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
                local moved = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
                end)
                if not moved then
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end
            else
                self:Notify("RB Cheat", "No public server found, using normal rejoin.", Color3.fromRGB(255, 160, 0))
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        else
            self:Notify("RB Cheat", "Server list decode failed, using normal rejoin.", Color3.fromRGB(255, 160, 0))
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    else
        self:Notify("RB Cheat", "Failed to fetch server list, using normal rejoin.", Color3.fromRGB(255, 160, 0))
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end

function Utils:TeleportToMouse()
    if not getgenv().scriptEnabled then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not Camera then return end

    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, params)

    local safePos
    if result then
        safePos = result.Position + Vector3.new(0, 3, 0)
    else
        safePos = unitRay.Origin + unitRay.Direction * 60 + Vector3.new(0, 3, 0)
    end
    hrp.CFrame = CFrame.new(safePos)
end

-- Expose to the shared global environment. The loader runs each module with
-- pcall() and discards the return value, so modules MUST publish themselves via
-- getgenv(); a bare `return Utils` alone leaves getgenv().Utils nil.
getgenv().Utils = Utils

return Utils
