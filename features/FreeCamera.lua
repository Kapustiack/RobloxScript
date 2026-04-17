-- [[ FREE CAMERA — FIXED: CAS blocks character movement, InputChanged tracks mouse delta ]]
-- Free Fly  : Camera detaches, WASD = fly, mouse look via InputChanged delta
-- Spectate  : Smooth lerp behind selected player
-- Minimap   : Corner ViewportFrame overhead view, normal play continues

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local CAS           = game:GetService("ContextActionService")
local LocalPlayer   = Players.LocalPlayer
local Camera        = workspace.CurrentCamera

-- ── Internal state ────────────────────────────────────────────────
local renderConn    = nil
local deltaConn     = nil
local minimapView   = nil
local minimapCam    = nil
local crosshairGui  = nil
local savedCamType  = nil
local savedSubject  = nil
local freeCamCF     = CFrame.new(0, 10, 0)
local pitchRad      = 0
local yawRad        = 0
local accDelta      = Vector2.new(0, 0)   -- accumulated mouse delta each frame

local function S(k) return getgenv()[k] end

-- ── SINK: absorbs WASD/Space from reaching character controller ──
-- IsKeyDown() still returns true (reads hardware), so our loop works.
local SINK_ACTION = "__rbFreeCamSink"
local function sinkInput(_, state)
    if state == Enum.UserInputState.Begin or state == Enum.UserInputState.Change then
        return Enum.ContextActionResult.Sink
    end
    return Enum.ContextActionResult.Pass
end

local function blockMovement()
    CAS:BindAction(SINK_ACTION, sinkInput, false,
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Space, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl,
        Enum.KeyCode.Q, Enum.KeyCode.E
    )
end
local function unblockMovement()
    pcall(function() CAS:UnbindAction(SINK_ACTION) end)
end

-- ── Mouse delta accumulator (more reliable than GetMouseDelta in exploits) ──
local function startDeltaAccum()
    if deltaConn then deltaConn:Disconnect() end
    accDelta = Vector2.new(0, 0)
    deltaConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            accDelta = accDelta + Vector2.new(input.Delta.X, input.Delta.Y)
        end
    end)
end
local function stopDeltaAccum()
    if deltaConn then deltaConn:Disconnect(); deltaConn = nil end
    accDelta = Vector2.new(0, 0)
end

-- ── Stop all active render loops ─────────────────────────────────
local function stopRender()
    if renderConn then renderConn:Disconnect(); renderConn = nil end
end

-- ── Save & restore camera state ───────────────────────────────────
local function saveCameraState()
    savedCamType  = Camera.CameraType
    savedSubject  = Camera.CameraSubject
    freeCamCF     = Camera.CFrame
    local _, y, p = Camera.CFrame:ToEulerAnglesYXZ()
    yawRad = y; pitchRad = p
end

local function restoreCamera()
    pcall(function()
        Camera.CameraType     = savedCamType or Enum.CameraType.Custom
        Camera.FieldOfView    = getgenv().defaultFOV or 70
        local char = LocalPlayer.Character
        if savedSubject and pcall(function() return savedSubject.Parent end) and savedSubject.Parent then
            Camera.CameraSubject = savedSubject
        elseif char then
            Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
                                or char:FindFirstChild("HumanoidRootPart")
        end
    end)
    UIS.MouseBehavior = Enum.MouseBehavior.Default
end

-- ── Freeze / unfreeze local character ─────────────────────────────
local function freezeChar(state)
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = not state end
    -- PlatformStand = true prevents humanoid from standing up or moving
    if state then
        if hum then hum:ChangeState(Enum.HumanoidStateType.PlatformStanding) end
    else
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

-- ── CROSSHAIR ─────────────────────────────────────────────────────
local function createCrosshair()
    if crosshairGui or not getgenv().ScreenGui then return end
    crosshairGui = Instance.new("Frame", getgenv().ScreenGui)
    crosshairGui.Name = "FreeCamCrosshair"
    crosshairGui.BackgroundTransparency = 1
    crosshairGui.Size = UDim2.new(0, 20, 0, 20)
    crosshairGui.Position = UDim2.new(0.5, -10, 0.5, -10)
    crosshairGui.ZIndex = 200
    local function line(h)
        local f = Instance.new("Frame", crosshairGui)
        f.BackgroundColor3 = Color3.new(1,1,1); f.BackgroundTransparency = 0.2
        f.BorderSizePixel = 0; f.ZIndex = 201
        if h then f.Size = UDim2.new(1,0,0,1); f.Position = UDim2.new(0,0,0.5,0)
        else      f.Size = UDim2.new(0,1,1,0); f.Position = UDim2.new(0.5,0,0,0) end
    end
    line(true); line(false)
end
local function destroyCrosshair()
    if crosshairGui then crosshairGui:Destroy(); crosshairGui = nil end
end

-- ── PLAYER LIST (Spectate) ────────────────────────────────────────
local function refreshPlayerList()
    local lf = getgenv().FreeCamPlayerList; if not lf then return end
    for _, c in pairs(lf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local ord = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            ord = ord + 1
            local b = Instance.new("TextButton", lf)
            b.LayoutOrder = ord
            b.Size = UDim2.new(1, -6, 0, 24)
            b.BorderSizePixel = 0; b.Font = Enum.Font.Gotham; b.TextSize = 11
            b.TextColor3 = getgenv().COL_TXT
            local sel = (getgenv().freeCamTarget == p)
            b.BackgroundColor3 = sel and getgenv().COL_ON or getgenv().COL_OFF
            b.Text = (sel and "► " or "  ") .. p.Name
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function()
                getgenv().freeCamTarget = p; refreshPlayerList()
            end)
        end
    end
    local ll = lf:FindFirstChildOfClass("UIListLayout")
    if ll then lf.CanvasSize = UDim2.new(0,0,0, ll.AbsoluteContentSize.Y + 4) end
end

-- ── MODE: FREE FLY ────────────────────────────────────────────────
local function startFreeFly()
    saveCameraState()
    blockMovement()       -- block WASD from reaching character
    freezeChar(true)      -- stop humanoid from walking
    startDeltaAccum()     -- start tracking mouse movement
    -- Removed: UIS.MouseBehavior = Enum.MouseBehavior.LockCenter so mouse is free by default

    Camera.CameraType = Enum.CameraType.Scriptable
    if S("freeCamShowCrosshair") then createCrosshair() end

    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not S("freeCamEnabled") or S("freeCamMode") ~= "fly" then return end

        -- Consume accumulated delta
        local delta = accDelta
        accDelta = Vector2.new(0, 0)

        local sens = 0.003
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            yawRad   = yawRad   - delta.X * sens
            pitchRad = math.clamp(pitchRad - delta.Y * sens, -math.pi/2 + 0.05, math.pi/2 - 0.05)
        else
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end

        local lookCF = CFrame.Angles(0, yawRad, 0) * CFrame.Angles(pitchRad, 0, 0)
        local spd    = (S("freeCamSpeed") or 50) * dt

        local mv = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W)         then mv = mv + lookCF.LookVector  * spd end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then mv = mv - lookCF.LookVector  * spd end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then mv = mv - lookCF.RightVector * spd end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then mv = mv + lookCF.RightVector * spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then mv = mv + Vector3.new(0,  spd, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0,  spd, 0) end

        freeCamCF      = CFrame.new(freeCamCF.Position + mv) * lookCF
        Camera.CFrame  = freeCamCF
        Camera.FieldOfView = S("freeCamFOV") or 70
    end)
end

-- ── MODE: SPECTATE ────────────────────────────────────────────────
local function startSpectate()
    saveCameraState()
    -- Don't sink input in spectate — player can still move
    freezeChar(false)
    stopDeltaAccum()
    destroyCrosshair()
    UIS.MouseBehavior = Enum.MouseBehavior.Default

    Camera.CameraType = Enum.CameraType.Scriptable
    refreshPlayerList()

    if not getgenv().freeCamTarget and getgenv().Utils then
        getgenv().freeCamTarget = getgenv().Utils:FindNearestAlivePlayer(nil)
        if getgenv().freeCamTarget then refreshPlayerList() end
    end

    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not S("freeCamEnabled") or S("freeCamMode") ~= "spectate" then return end
        local target = getgenv().freeCamTarget
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local goal = hrp.CFrame * CFrame.new(0, 2.5, 7)
        Camera.CFrame = Camera.CFrame:Lerp(goal, math.min(1, dt * 7))
        Camera.FieldOfView = S("freeCamFOV") or 70
    end)
end

-- ── MODE: MINIMAP ─────────────────────────────────────────────────
local function stopMinimap()
    if minimapView then minimapView:Destroy(); minimapView = nil end
    minimapCam = nil
end

local function startMinimap()
    stopMinimap()
    -- Normal camera untouched — no CameraType change, no movement block
    freezeChar(false)
    stopDeltaAccum()
    destroyCrosshair()
    local sg = getgenv().ScreenGui; if not sg then return end

    minimapView = Instance.new("ViewportFrame", sg)
    minimapView.Name = "FreeCamMinimap"
    minimapView.Size = UDim2.new(0, 210, 0, 210)
    minimapView.Position = UDim2.new(1, -222, 1, -222)
    minimapView.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    minimapView.BorderSizePixel = 0
    minimapView.LightColor = Color3.fromRGB(220, 220, 255)
    minimapView.LightDirection = Vector3.new(0, -1, 0.3)
    minimapView.ZIndex = 10
    Instance.new("UICorner", minimapView).CornerRadius = UDim.new(0, 10)
    local sk = Instance.new("UIStroke", minimapView); sk.Color = Color3.fromRGB(60,120,180); sk.Thickness = 1.5
    local lbl = Instance.new("TextLabel", minimapView)
    lbl.Size = UDim2.new(1,0,0,18); lbl.Position = UDim2.new(0,0,0,4)
    lbl.BackgroundTransparency = 1; lbl.Text = "▲ OVERHEAD MAP"
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9
    lbl.TextColor3 = Color3.fromRGB(80,180,255); lbl.ZIndex = 11

    minimapCam = Instance.new("Camera", minimapView)
    minimapCam.CameraType = Enum.CameraType.Scriptable
    minimapCam.FieldOfView = 60
    minimapView.CurrentCamera = minimapCam

    renderConn = RunService.RenderStepped:Connect(function()
        if not S("freeCamEnabled") or S("freeCamMode") ~= "minimap" then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pos = char.HumanoidRootPart.Position
        minimapCam.CFrame = CFrame.new(pos + Vector3.new(0,70,0), pos)
    end)
end

-- ── Enable / Disable ─────────────────────────────────────────────
local function enableFreeCamera()
    if not getgenv().scriptEnabled then return end
    stopRender(); stopMinimap(); unblockMovement(); stopDeltaAccum()

    local mode = getgenv().freeCamMode or "fly"
    if mode == "fly"       then startFreeFly()
    elseif mode == "spectate" then startSpectate()
    elseif mode == "minimap"  then startMinimap() end
end

local function disableFreeCamera()
    getgenv().freeCamEnabled = false
    stopRender(); stopMinimap(); unblockMovement(); stopDeltaAccum()
    destroyCrosshair()
    freezeChar(false)
    -- Only restore if we actually saved state (FreeCam was used)
    if savedCamType and getgenv().freeCamMode ~= "minimap" then 
        pcall(restoreCamera) 
        savedCamType = nil
        savedSubject = nil
    end
    UIS.MouseBehavior = Enum.MouseBehavior.Default
end

-- ── Toggle helper ─────────────────────────────────────────────────
local function toggleFreeCamera()
    if not getgenv().scriptEnabled then return end
    getgenv().freeCamEnabled = not getgenv().freeCamEnabled
    getgenv().FreeCameraButton.Text = "FreeCam: " .. (getgenv().freeCamEnabled and "ON" or "OFF")
    getgenv().FreeCameraButton.BackgroundColor3 = getgenv().freeCamEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().freeCamEnabled then enableFreeCamera() else disableFreeCamera() end
end

-- ── Button wiring ─────────────────────────────────────────────────
getgenv().FreeCameraButton.MouseButton1Click:Connect(toggleFreeCamera)
getgenv().FreeCameraButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().FreeCameraSettingsFrame) end
    if getgenv().freeCamMode == "spectate" then refreshPlayerList() end
end)

-- ── Mode buttons ──────────────────────────────────────────────────
local function setMode(mode)
    getgenv().freeCamMode = mode
    getgenv().FreeCamFlyBtn.BackgroundColor3      = (mode=="fly")       and getgenv().COL_ON or getgenv().COL_OFF
    getgenv().FreeCamSpectateBtn.BackgroundColor3 = (mode=="spectate")  and getgenv().COL_ON or getgenv().COL_OFF
    getgenv().FreeCamMinimapBtn.BackgroundColor3  = (mode=="minimap")   and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().freeCamEnabled then enableFreeCamera() end
    if mode == "spectate" then refreshPlayerList() end
end
getgenv().FreeCamFlyBtn.MouseButton1Click:Connect(function()      setMode("fly")      end)
getgenv().FreeCamSpectateBtn.MouseButton1Click:Connect(function() setMode("spectate") end)
getgenv().FreeCamMinimapBtn.MouseButton1Click:Connect(function()  setMode("minimap")  end)

-- ── Crosshair toggle ──────────────────────────────────────────────
getgenv().FreeCamCrosshairBtn.MouseButton1Click:Connect(function()
    getgenv().freeCamShowCrosshair = not getgenv().freeCamShowCrosshair
    getgenv().FreeCamCrosshairBtn.Text = "Crosshair: " .. (getgenv().freeCamShowCrosshair and "ON" or "OFF")
    getgenv().FreeCamCrosshairBtn.BackgroundColor3 = getgenv().freeCamShowCrosshair and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().freeCamEnabled and getgenv().freeCamMode == "fly" then
        if getgenv().freeCamShowCrosshair then createCrosshair() else destroyCrosshair() end
    end
end)
getgenv().FreeCamRefreshBtn.MouseButton1Click:Connect(refreshPlayerList)

-- ── [P] key quick toggle ──────────────────────────────────────────
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P and getgenv().scriptEnabled then toggleFreeCamera() end
end)

getgenv().disableFreeCamera = disableFreeCamera
