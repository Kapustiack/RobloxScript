-- [[ ESP — Full: Names, Distance, 3D Boxes, 2D Boxes, Tracers, Skeleton, Health Bars ]]
-- Uses Drawing library if available (Synapse/KRNL/Fluxus), else falls back to Frames
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- Drawing API availability check
local hasDrawing = (typeof(Drawing) == "table") and (typeof(Drawing.new) == "function")

-- ── Drawing object pool per player ───────────────────────────────
-- drawObjects[playerName] = { tracer=Line, skeleton={lines}, hpBg=Line, hpFill=Line }
local drawObjects = {}

local function newLine(color, thickness, transparency)
    if not hasDrawing then return nil end
    local l = Drawing.new("Line")
    l.Visible     = false
    l.Color       = color or Color3.new(1,0,0)
    l.Thickness   = thickness or 1
    l.Transparency = transparency or 1
    l.ZIndex      = 5
    return l
end

local function removeDraw(name)
    local d = drawObjects[name]; if not d then return end
    if d.tracer  then pcall(function() d.tracer:Remove()  end) end
    if d.hpBg    then pcall(function() d.hpBg:Remove()    end) end
    if d.hpFill  then pcall(function() d.hpFill:Remove()  end) end
    if d.skeleton then
        for _, ln in pairs(d.skeleton) do pcall(function() ln:Remove() end) end
    end
    drawObjects[name] = nil
end

local SKELETON_BONES = {
    {"Head", "UpperTorso"},   {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},  {"LeftUpperArm", "LeftLowerArm"},  {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},{"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},  {"LeftUpperLeg", "LeftLowerLeg"},  {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},{"RightLowerLeg", "RightFoot"},
}

local function getDrawObj(name)
    if not drawObjects[name] then
        local skeletonLines = {}
        for _ = 1, #SKELETON_BONES do
            table.insert(skeletonLines, newLine(Color3.fromRGB(60,220,120), 1))
        end
        drawObjects[name] = {
            tracer  = newLine(Color3.fromRGB(220,60,60), 1),
            hpBg    = newLine(Color3.fromRGB(30,30,30), 4),
            hpFill  = newLine(Color3.fromRGB(60,220,60), 3),
            skeleton= skeletonLines,
        }
    end
    return drawObjects[name]
end

-- ── ESP Container (for BoxHandleAdornments) ─────────────────────
getgenv().ESPContainer = Instance.new("Folder")
getgenv().ESPContainer.Name = "ESPContainer"
getgenv().ESPContainer.Parent = getgenv().ScreenGui

-- ── Create per-player UI elements ─────────────────────────────────
local function createESP(player)
    if not getgenv().espEnabled or not getgenv().scriptEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- 3D Box
    local box = getgenv().ESPContainer:FindFirstChild(player.Name.."_Box")
            or Instance.new("BoxHandleAdornment")
    box.Name = player.Name.."_Box"; box.Parent = getgenv().ESPContainer
    box.Size = Vector3.new(4,5,2); box.Color3 = Color3.fromRGB(220,60,60)
    box.Transparency = 0.65; box.AlwaysOnTop = true; box.ZIndex = 10
    box.Adornee = char.HumanoidRootPart
    box.Visible = getgenv().espShowBoxes and not getgenv().espUse2DBoxes

    -- 2D Box
    local box2D = getgenv().ScreenGui:FindFirstChild(player.Name.."_2DBox")
              or Instance.new("Frame")
    box2D.Name = player.Name.."_2DBox"; box2D.Parent = getgenv().ScreenGui
    box2D.BackgroundTransparency = 1; box2D.BorderSizePixel = 0; box2D.Visible = false
    local function makeL(n,p,s)
        local l = box2D:FindFirstChild(n) or Instance.new("Frame")
        l.Name=n; l.Parent=box2D; l.BackgroundColor3=Color3.fromRGB(255,0,0)
        l.BorderSizePixel=0; l.Position=p; l.Size=s; return l
    end
    makeL("T",UDim2.new(0,0,0,0),UDim2.new(1,0,0,2))
    makeL("B",UDim2.new(0,0,1,-2),UDim2.new(1,0,0,2))
    makeL("L",UDim2.new(0,0,0,0),UDim2.new(0,2,1,0))
    makeL("R",UDim2.new(1,-2,0,0),UDim2.new(0,2,1,0))

    -- Name label
    local nameL = getgenv().ScreenGui:FindFirstChild(player.Name.."_Name")
              or Instance.new("TextLabel")
    nameL.Name = player.Name.."_Name"; nameL.Parent = getgenv().ScreenGui
    nameL.BackgroundTransparency = 0.5; nameL.BackgroundColor3 = Color3.new(0,0,0)
    nameL.TextColor3 = Color3.new(1,1,1); nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14; nameL.Size = UDim2.new(0,100,0,20)
    nameL.AnchorPoint = Vector2.new(0.5,1); nameL.Visible = false
    Instance.new("UICorner", nameL).CornerRadius = UDim.new(0,4)

    -- Distance label
    local distL = getgenv().ScreenGui:FindFirstChild(player.Name.."_Distance")
              or Instance.new("TextLabel")
    distL.Name = player.Name.."_Distance"; distL.Parent = getgenv().ScreenGui
    distL.BackgroundTransparency = 0.5; distL.BackgroundColor3 = Color3.new(0,0,0)
    distL.TextColor3 = Color3.fromRGB(255,255,0); distL.Font = Enum.Font.Gotham
    distL.TextSize = 12; distL.Size = UDim2.new(0,80,0,16)
    distL.AnchorPoint = Vector2.new(0.5,0); distL.Visible = false
    Instance.new("UICorner", distL).CornerRadius = UDim.new(0,4)
end

local function clearESPForPlayer(p)
    local parts = {p.Name.."_Name", p.Name.."_Distance", p.Name.."_2DBox"}
    for _, n in pairs(parts) do local o = getgenv().ScreenGui:FindFirstChild(n); if o then o:Destroy() end end
    local b3 = getgenv().ESPContainer:FindFirstChild(p.Name.."_Box"); if b3 then b3:Destroy() end
    removeDraw(p.Name)
end

-- ── Color for health (green→yellow→red) ──────────────────────────
local function healthColor(pct)
    if pct > 0.5 then
        return Color3.new(1 - (pct-0.5)*2, 1, 0)
    else
        return Color3.new(1, pct*2, 0)
    end
end

-- ── Main ESP update (called every Heartbeat from main.lua) ────────
local function updateESP()
    local env = getgenv()
    if not env.espEnabled or not env.scriptEnabled then
        for _, v in pairs(env.ESPContainer:GetChildren()) do v:Destroy() end
        for _, p in pairs(Players:GetPlayers()) do clearESPForPlayer(p) end
        return
    end

    local myChar = LocalPlayer.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local vp = Camera.ViewportSize
    
    -- Cache flags to radically reduce hash lookups
    local drawDist       = env.espDrawDistance
    local showNames      = env.espShowNames
    local showDistance   = env.espShowDistance
    local showBoxes      = env.espShowBoxes
    local use2DBoxes     = env.espUse2DBoxes
    local showTracers    = env.espShowTracers
    local showSkeleton   = env.espShowSkeleton
    local showHealthBars = env.espShowHealthBars
    local drawObjsDict   = drawObjects
    local hasDrawLib     = hasDrawing
    local creationsDone  = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character
                and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local hrp  = char.HumanoidRootPart
            local dist = (hrp.Position - myHRP.Position).Magnitude
            local hum  = char:FindFirstChildOfClass("Humanoid")

            if dist <= drawDist then
                -- Ensure base ESP is created
                local nameL = env.ScreenGui:FindFirstChild(p.Name.."_Name")
                if not nameL then
                    if creationsDone >= 2 then
                        -- Throttle heavy UI creation to prevent massive lag spikes. 
                        -- It will process this player securely on the next frame.
                        clearESPForPlayer(p) 
                    else
                        createESP(p)
                        creationsDone = creationsDone + 1
                        nameL = env.ScreenGui:FindFirstChild(p.Name.."_Name")
                    end
                end
                
                -- If we still don't have it (because we skipped), skip drawing loop
                if not nameL then
                    local fakeDist = 0 -- just bypassing this loop step for Lua 5.1 without 'continue'
                else
                    local distL = env.ScreenGui:FindFirstChild(p.Name.."_Distance")
                    local b2d   = env.ScreenGui:FindFirstChild(p.Name.."_2DBox")
                    local b3d   = env.ESPContainer:FindFirstChild(p.Name.."_Box")

                    local scrC, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local scrH           = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                    local scrF           = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                    local visible = onScreen and scrC.Z > 0

                if visible then
                    local boxH = math.abs(scrH.Y - scrF.Y); local boxW = math.max(boxH*0.5, 20)
                    local cX   = scrC.X
                    local tY   = math.min(scrH.Y, scrF.Y)

                    -- Name
                    if nameL then
                        nameL.Position = UDim2.new(0, cX, 0, tY - 2)
                        nameL.Visible  = showNames
                        if showNames then nameL.Text = p.Name end
                    end
                    -- Distance
                    if distL then
                        distL.Position = UDim2.new(0, cX, 0, tY + boxH + 2)
                        distL.Visible  = showDistance
                        if showDistance then distL.Text = math.floor(dist).." studs" end
                    end
                    -- 2D box
                    if b2d then
                        b2d.Position = UDim2.new(0, cX - boxW/2, 0, tY)
                        b2d.Size     = UDim2.new(0, boxW, 0, boxH)
                        b2d.Visible  = use2DBoxes
                    end
                    -- 3D box
                    if b3d then b3d.Visible = showBoxes and not use2DBoxes end

                    -- ── DRAWING: Tracer ──────────────────────────────
                    if hasDrawLib and showTracers then
                        local d = getDrawObj(p.Name)
                        if d.tracer then
                            d.tracer.Visible = true
                            d.tracer.From    = Vector2.new(vp.X/2, vp.Y)
                            d.tracer.To      = Vector2.new(cX, tY + boxH)
                            d.tracer.Color   = Color3.fromRGB(220,60,60)
                        end
                    elseif hasDrawLib then
                        local d = drawObjsDict[p.Name]
                        if d and d.tracer then d.tracer.Visible = false end
                    end

                    -- ── DRAWING: Health Bar ──────────────────────────
                    if hasDrawLib and showHealthBars and hum then
                        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        local barX = cX - boxW/2 - 5
                        local barTop = tY; local barBot = tY + boxH
                        local d = getDrawObj(p.Name)
                        if d.hpBg then
                            d.hpBg.Visible = true; d.hpBg.Thickness = 4
                            d.hpBg.From    = Vector2.new(barX, barTop)
                            d.hpBg.To      = Vector2.new(barX, barBot)
                        end
                        if d.hpFill then
                            d.hpFill.Visible    = true; d.hpFill.Thickness = 3
                            d.hpFill.Color      = healthColor(pct)
                            d.hpFill.From       = Vector2.new(barX, barBot)
                            d.hpFill.To         = Vector2.new(barX, barBot - (barBot-barTop)*pct)
                        end
                    elseif hasDrawLib then
                        local d = drawObjsDict[p.Name]
                        if d then
                            if d.hpBg   then d.hpBg.Visible   = false end
                            if d.hpFill then d.hpFill.Visible  = false end
                        end
                    end

                    -- ── DRAWING: Skeleton ESP ────────────────────────
                    if hasDrawLib and showSkeleton then
                        local d = getDrawObj(p.Name)
                        for i, pair in ipairs(SKELETON_BONES) do
                            local partA = char:FindFirstChild(pair[1])
                            local partB = char:FindFirstChild(pair[2])
                            local ln    = d.skeleton[i]
                            if ln and partA and partB then
                                local sA, okA = Camera:WorldToViewportPoint(partA.Position)
                                local sB, okB = Camera:WorldToViewportPoint(partB.Position)
                                if okA and okB and sA.Z > 0 and sB.Z > 0 then
                                    ln.Visible = true
                                    ln.From    = Vector2.new(sA.X, sA.Y)
                                    ln.To      = Vector2.new(sB.X, sB.Y)
                                else
                                    ln.Visible = false
                                end
                            elseif ln then
                                ln.Visible = false
                            end
                        end
                    elseif hasDrawLib then
                        local d = drawObjsDict[p.Name]
                        if d and d.skeleton then
                            for _, ln in pairs(d.skeleton) do ln.Visible = false end
                        end
                    end

                else
                    -- Off screen — hide everything
                    if nameL then nameL.Visible = false end
                    if distL then distL.Visible = false end
                    if b2d   then b2d.Visible   = false end
                    if b3d   then b3d.Visible   = false end
                    local d = drawObjsDict[p.Name]
                    if d then
                        if d.tracer  then d.tracer.Visible  = false end
                        if d.hpBg    then d.hpBg.Visible    = false end
                        if d.hpFill  then d.hpFill.Visible  = false end
                        if d.skeleton then for _,l in pairs(d.skeleton) do l.Visible=false end end
                    end
                end
                end -- Close the bypass block
            else
                -- Out of distance range — hide everything instead of destroying to save FPS
                local nameL = env.ScreenGui:FindFirstChild(p.Name.."_Name")
                local distL = env.ScreenGui:FindFirstChild(p.Name.."_Distance")
                local b2d   = env.ScreenGui:FindFirstChild(p.Name.."_2DBox")
                local b3d   = env.ESPContainer:FindFirstChild(p.Name.."_Box")
                if nameL then nameL.Visible = false end
                if distL then distL.Visible = false end
                if b2d   then b2d.Visible   = false end
                if b3d   then b3d.Visible   = false end
                local d = drawObjsDict[p.Name]
                if d then
                    if d.tracer  then d.tracer.Visible  = false end
                    if d.hpBg    then d.hpBg.Visible    = false end
                    if d.hpFill  then d.hpFill.Visible  = false end
                    if d.skeleton then for _,l in pairs(d.skeleton) do l.Visible=false end end
                end
            end
        elseif p ~= LocalPlayer then
            clearESPForPlayer(p)
        end
    end
end

-- ── Button wiring ─────────────────────────────────────────────────
getgenv().ESPButton.MouseButton1Click:Connect(function()
    getgenv().espEnabled = not getgenv().espEnabled
    getgenv().ESPButton.Text = "ESP: " .. (getgenv().espEnabled and "ON" or "OFF")
    getgenv().ESPButton.BackgroundColor3 = getgenv().espEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().espEnabled then
        for _, v in pairs(getgenv().ESPContainer:GetChildren()) do v:Destroy() end
        for _, p in pairs(Players:GetPlayers()) do clearESPForPlayer(p) end
    end
end)
getgenv().ESPButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().ESPSettingsFrame) end
end)

local function mkESPToggle(btn, key, label, onTxt, offTxt)
    local b = getgenv()[btn]; if not b then return end
    b.MouseButton1Click:Connect(function()
        getgenv()[key] = not getgenv()[key]
        b.Text = label .. (getgenv()[key] and (onTxt or "ON") or (offTxt or "OFF"))
        b.BackgroundColor3 = getgenv()[key] and getgenv().COL_ON or getgenv().COL_OFF
    end)
end

mkESPToggle("ESPShowNamesBtn",   "espShowNames",      "Names: ")
mkESPToggle("ESPShowDistBtn",    "espShowDistance",   "Distance: ")
mkESPToggle("ESPShowBoxesBtn",   "espShowBoxes",      "3D Boxes: ")
mkESPToggle("ESP2DBoxesBtn",     "espUse2DBoxes",     "2D Boxes: ")
mkESPToggle("ESPTracersBtn",     "espShowTracers",    "Tracers: ")
mkESPToggle("ESPSkeletonBtn",    "espShowSkeleton",   "Skeleton: ")
mkESPToggle("ESPHealthBarsBtn",  "espShowHealthBars", "Health Bars: ")

-- Warn if no Drawing lib
if not hasDrawing then
    warn("[RB Hub] Drawing library not found — Tracers, Skeleton, Health Bars require Synapse X / KRNL / Fluxus")
end

getgenv().updateESP = updateESP
