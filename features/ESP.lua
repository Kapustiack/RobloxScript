local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local hasDrawing  = (typeof(Drawing) == "table") and (typeof(Drawing.new) == "function")

local drawObjects = {}
local processIndex = 1

local function newLine(color, thickness, transparency)
    if not hasDrawing then return nil end
    local l = Drawing.new("Line")
    l.Visible, l.Color, l.Thickness, l.Transparency, l.ZIndex = false, color or Color3.new(1,0,0), thickness or 1, transparency or 1, 5
    return l
end

local function removeDraw(name)
    local d = drawObjects[name]; if not d then return end
    if d.tracer then pcall(function() d.tracer:Remove() end) end
    if d.hpBg then pcall(function() d.hpBg:Remove() end) end
    if d.hpFill then pcall(function() d.hpFill:Remove() end) end
    if d.skeleton then for _, ln in pairs(d.skeleton) do pcall(function() ln:Remove() end) end end
    drawObjects[name] = nil
end

local SKELETON_BONES_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local SKELETON_BONES_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function getPlayerColor(p)
    if getgenv().espTeamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then
        return Color3.fromRGB(60, 120, 255)
    end
    return Color3.fromRGB(220, 60, 60)
end

local function getDrawObj(name)
    if not drawObjects[name] then
        local skeletonLines = {}
        for _ = 1, #SKELETON_BONES_R15 do table.insert(skeletonLines, newLine(Color3.fromRGB(60,220,120), 1)) end
        drawObjects[name] = {
            tracer = newLine(Color3.fromRGB(220,60,60), 1),
            hpBg = newLine(Color3.fromRGB(30,30,30), 4),
            hpFill = newLine(Color3.fromRGB(60,220,60), 3),
            skeleton = skeletonLines,
        }
    end
    return drawObjects[name]
end

getgenv().ESPContainer = Instance.new("Folder")
getgenv().ESPContainer.Name = "ESPContainer"; getgenv().ESPContainer.Parent = getgenv().ScreenGui

local function createESP(player)
    if not getgenv().espEnabled or not getgenv().scriptEnabled then return end
    local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local box = getgenv().ESPContainer:FindFirstChild(player.Name.."_Box") or Instance.new("BoxHandleAdornment")
    box.Name = player.Name.."_Box"; box.Parent = getgenv().ESPContainer; box.Size = Vector3.new(4,5,2); box.Transparency = 0.65; box.AlwaysOnTop = true; box.ZIndex = 10; box.Adornee = hrp; box.Visible = getgenv().espShowBoxes and not getgenv().espUse2DBoxes

    local nameL = getgenv().ScreenGui:FindFirstChild(player.Name.."_Name") or Instance.new("TextLabel")
    nameL.Name = player.Name.."_Name"; nameL.Parent = getgenv().ScreenGui; nameL.BackgroundTransparency = 0.5; nameL.BackgroundColor3 = Color3.new(0,0,0); nameL.TextColor3 = Color3.new(1,1,1); nameL.Font = Enum.Font.GothamBold; nameL.TextSize = 14; nameL.Size = UDim2.new(0,100,0,20); nameL.AnchorPoint = Vector2.new(0.5,1); nameL.Visible = false
    Instance.new("UICorner", nameL).CornerRadius = UDim.new(0,4)

    local distL = getgenv().ScreenGui:FindFirstChild(player.Name.."_Distance") or Instance.new("TextLabel")
    distL.Name = player.Name.."_Distance"; distL.Parent = getgenv().ScreenGui; distL.BackgroundTransparency = 0.5; distL.BackgroundColor3 = Color3.new(0,0,0); distL.TextColor3 = Color3.fromRGB(255,255,0); distL.Font = Enum.Font.Gotham; distL.TextSize = 12; distL.Size = UDim2.new(0,80,0,16); distL.AnchorPoint = Vector2.new(0.5,0); distL.Visible = false
    Instance.new("UICorner", distL).CornerRadius = UDim.new(0,4)

    local box2D = getgenv().ScreenGui:FindFirstChild(player.Name.."_2DBox") or Instance.new("Frame")
    box2D.Name = player.Name.."_2DBox"; box2D.Parent = getgenv().ScreenGui; box2D.BackgroundTransparency = 1; box2D.BorderSizePixel = 0; box2D.Visible = false
    local function makeL(n,p,s)
        local l = box2D:FindFirstChild(n) or Instance.new("Frame")
        l.Name=n; l.Parent=box2D; l.BackgroundColor3=Color3.fromRGB(255,0,0); l.BorderSizePixel=0; l.Position=p; l.Size=s; return l
    end
    makeL("T",UDim2.new(0,0,0,0),UDim2.new(1,0,0,2)); makeL("B",UDim2.new(0,0,1,-2),UDim2.new(1,0,0,2)); makeL("L",UDim2.new(0,0,0,0),UDim2.new(0,2,1,0)); makeL("R",UDim2.new(1,-2,0,0),UDim2.new(0,2,1,0))
end

local function clearESPForPlayer(p)
    local parts = {p.Name.."_Name", p.Name.."_Distance", p.Name.."_2DBox"}
    for _, n in pairs(parts) do local o = getgenv().ScreenGui:FindFirstChild(n); if o then o:Destroy() end end
    local b3 = getgenv().ESPContainer:FindFirstChild(p.Name.."_Box"); if b3 then b3:Destroy() end
    removeDraw(p.Name)
end

local function healthColor(pct)
    if pct > 0.5 then return Color3.new(1 - (pct-0.5)*2, 1, 0) else return Color3.new(1, pct*2, 0) end
end

local function updateESP()
    local env = getgenv()
    if not env.espEnabled or not env.scriptEnabled then return end

    local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local vp = Camera.ViewportSize; local allP = Players:GetPlayers(); local n = #allP

    processIndex = (processIndex > n) and 1 or processIndex
    local batch = 10; local pEnd = math.min(processIndex + batch, n)

    local drawDist = env.espDrawDistance; local showNames = env.espShowNames; local showDist = env.espShowDistance; local showBoxes = env.espShowBoxes; local use2D = env.espUse2DBoxes; local showTracer = env.espShowTracers; local showSkel = env.espShowSkeleton; local showHP = env.espShowHealthBars

    for i = 1, n do
        local p = allP[i]
        if p ~= LocalPlayer and p.Character then
            local char = p.Character; local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist <= drawDist then
                    local scrC, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local scrH = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                    local scrF = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                    
                    if onScreen and scrH.Z > 0 and scrF.Z > 0 then
                        local boxH = math.abs(scrH.Y - scrF.Y); local boxW = math.max(boxH*0.5, 20)
                        local cX, tY = scrC.X, math.min(scrH.Y, scrF.Y)
                        local nameL = env.ScreenGui:FindFirstChild(p.Name.."_Name")
                        if not nameL and i >= processIndex and i <= pEnd then createESP(p); nameL = env.ScreenGui:FindFirstChild(p.Name.."_Name") end

                        if nameL then
                            local pColor = getPlayerColor(p)
                            local distL = env.ScreenGui:FindFirstChild(p.Name.."_Distance"); local b2d = env.ScreenGui:FindFirstChild(p.Name.."_2DBox"); local b3d = env.ESPContainer:FindFirstChild(p.Name.."_Box")
                            nameL.Position = UDim2.new(0, cX, 0, tY - 2); nameL.Visible = showNames; if showNames then nameL.Text = p.Name; nameL.TextColor3 = pColor end
                            if distL then distL.Position = UDim2.new(0, cX, 0, tY + boxH + 2); distL.Visible = showDist; if showDist then distL.Text = math.floor(dist).." studs"; distL.TextColor3 = pColor end end
                            if b2d then
                                b2d.Position = UDim2.new(0, cX - boxW/2, 0, tY); b2d.Size = UDim2.new(0, boxW, 0, boxH); b2d.Visible = use2D
                                for _, c in ipairs(b2d:GetChildren()) do if c:IsA("Frame") then c.BackgroundColor3 = pColor end end
                            end
                            if b3d then b3d.Visible = showBoxes and not use2D; b3d.Color3 = pColor end
                            if hasDrawing then
                                local d = getDrawObj(p.Name)
                                if showTracer and d.tracer then d.tracer.Visible = true; d.tracer.From = Vector2.new(vp.X/2, vp.Y); d.tracer.To = Vector2.new(cX, tY + boxH); d.tracer.Color = pColor elseif d.tracer then d.tracer.Visible = false end
                                if showHP and hum and d.hpBg and d.hpFill then
                                    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                    local barX = cX - boxW/2 - 5
                                    d.hpBg.Visible = true; d.hpBg.From = Vector2.new(barX, tY); d.hpBg.To = Vector2.new(barX, tY+boxH)
                                    d.hpFill.Visible = true; d.hpFill.Color = healthColor(pct); d.hpFill.From = Vector2.new(barX, tY+boxH); d.hpFill.To = Vector2.new(barX, tY+boxH - (boxH*pct))
                                elseif d.hpBg then d.hpBg.Visible = false; d.hpFill.Visible = false end
                                if showSkel and d.skeleton then
                                    local isR6 = char:FindFirstChild("Torso") ~= nil
                                    local bones = isR6 and SKELETON_BONES_R6 or SKELETON_BONES_R15
                                    for sIdx, pair in ipairs(bones) do
                                        local pA, pB = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2]); local ln = d.skeleton[sIdx]
                                        if ln and pA and pB then
                                            local sA, oA = Camera:WorldToViewportPoint(pA.Position); local sB, oB = Camera:WorldToViewportPoint(pB.Position)
                                            if oA and oB and sA.Z > 0 and sB.Z > 0 then ln.Visible = true; ln.From = Vector2.new(sA.X, sA.Y); ln.To = Vector2.new(sB.X, sB.Y); ln.Color = pColor else ln.Visible = false end
                                        elseif ln then ln.Visible = false end
                                    end
                                    for sIdx = #bones + 1, #d.skeleton do if d.skeleton[sIdx] then d.skeleton[sIdx].Visible = false end end
                                elseif d.skeleton then for _,l in pairs(d.skeleton) do l.Visible = false end end
                            end
                        end
                    else
                        local nameL = env.ScreenGui:FindFirstChild(p.Name.."_Name")
                        if nameL then nameL.Visible = false end
                        local distL = env.ScreenGui:FindFirstChild(p.Name.."_Distance")
                        if distL then distL.Visible = false end
                        local b2d = env.ScreenGui:FindFirstChild(p.Name.."_2DBox")
                        if b2d then b2d.Visible = false end
                        local b3d = env.ESPContainer:FindFirstChild(p.Name.."_Box")
                        if b3d then b3d.Visible = false end
                        local d = drawObjects[p.Name]; if d then if d.tracer then d.tracer.Visible = false end; if d.hpBg then d.hpBg.Visible = false end; if d.hpFill then d.hpFill.Visible = false end; if d.skeleton then for _,l in pairs(d.skeleton) do l.Visible=false end end end
                    end
                else clearESPForPlayer(p) end
            else clearESPForPlayer(p) end
        end
    end
    processIndex = pEnd + 1
end

getgenv().ESPButton.MouseButton1Click:Connect(function()
    getgenv().espEnabled = not getgenv().espEnabled
    getgenv().ESPButton.Text = "ESP: " .. (getgenv().espEnabled and "ON" or "OFF"); getgenv().ESPButton.BackgroundColor3 = getgenv().espEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if not getgenv().espEnabled then for _, v in pairs(getgenv().ESPContainer:GetChildren()) do v:Destroy() end; for _, p in pairs(Players:GetPlayers()) do clearESPForPlayer(p) end end
end)
if getgenv().BindPanelButton and getgenv().ESPSettingsFrame then
    getgenv().BindPanelButton(getgenv().ESPButton, getgenv().ESPSettingsFrame)
end

local function mkESPToggle(btn, key, label)
    local b = getgenv()[btn]; if not b then return end
    b.MouseButton1Click:Connect(function()
        getgenv()[key] = not getgenv()[key]; b.Text = label .. (getgenv()[key] and "ON" or "OFF"); b.BackgroundColor3 = getgenv()[key] and getgenv().COL_ON or getgenv().COL_OFF
    end)
end
mkESPToggle("ESPShowNamesBtn", "espShowNames", "Names: "); mkESPToggle("ESPShowDistBtn", "espShowDistance", "Distance: "); mkESPToggle("ESPShowBoxesBtn", "espShowBoxes", "3D Boxes: "); mkESPToggle("ESP2DBoxesBtn", "espUse2DBoxes", "2D Boxes: "); mkESPToggle("ESPTracersBtn", "espShowTracers", "Tracers: "); mkESPToggle("ESPSkeletonBtn", "espShowSkeleton", "Skeleton: "); mkESPToggle("ESPHealthBarsBtn", "espShowHealthBars", "Health Bars: "); mkESPToggle("ESPTeamCheckBtn", "espTeamCheck", "Team Check: ")

-- Expose the Drawing-object cleanup so main.lua's PlayerRemoving handler can
-- reach it. Drawing.new() objects aren't Instances parented to ScreenGui, so
-- without this, every tracer/HP-bar/skeleton-line for a player who leaves
-- while in ESP draw distance was leaked for the rest of the session.
getgenv().clearESPDrawings = removeDraw
getgenv().updateESP = updateESP
