-- [[ FREE CAMERA — Three modes: Free Fly, Spectate, Minimap ]]
-- Free Fly : Detaches camera, WASD+mouse = free flight, P = toggle
-- Spectate : Smooth-follows a selected player's character  
-- Minimap  : Corner ViewportFrame overhead view, normal play continues

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ── Internal state ────────────────────────────────────────────────
local renderConn     = nil    -- RenderStepped connection for active mode
local minimapView    = nil    -- ViewportFrame for minimap
local minimapCam     = nil    -- Camera inside minimap
local crosshairGui   = nil    -- Crosshair overlay
local savedCamType   = nil    -- Camera.CameraType before takeover
local savedSubject   = nil    -- Camera.CameraSubject before takeover
local freeCamCF      = CFrame.new(0, 10, 0)  -- current free cam position
local pitchRad, yawRad = 0, 0

-- ── Helpers ───────────────────────────────────────────────────────
local function S(k) return getgenv()[k] end

local function stopRender()
    if renderConn then renderConn:Disconnect(); renderConn = nil end
end

local function restoreCamera()
    pcall(function()
        Camera.CameraType = savedCamType or Enum.CameraType.Custom
        local char = LocalPlayer.Character
        if savedSubject and savedSubject.Parent then
            Camera.CameraSubject = savedSubject
        elseif char then
            Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("HumanoidRootPart")
        end
        Camera.FieldOfView = getgenv().defaultFOV or 70
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end)
end

local function saveCameraState()
    savedCamType = Camera.CameraType
    savedSubject = Camera.CameraSubject
    -- Initialise free cam from current camera position so it doesn't snap
    freeCamCF = Camera.CFrame
    local _, y, p = Camera.CFrame:ToEulerAnglesYXZ()
    yawRad = y; pitchRad = p
end

-- ── CROSSHAIR ─────────────────────────────────────────────────────
local function createCrosshair()
    if crosshairGui or not getgenv().ScreenGui then return end
    crosshairGui = Instance.new("Frame")
    crosshairGui.Name = "FreeCamCrosshair"
    crosshairGui.Parent = getgenv().ScreenGui
    crosshairGui.BackgroundTransparency = 1
    crosshairGui.Size   = UDim2.new(0, 20, 0, 20)
    crosshairGui.Position = UDim2.new(0.5, -10, 0.5, -10)
    crosshairGui.ZIndex = 200

    local function line(horiz)
        local f = Instance.new("Frame", crosshairGui)
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        f.BackgroundTransparency = 0.3
        f.BorderSizePixel = 0
        f.ZIndex = 201
        if horiz then
            f.Size     = UDim2.new(1, 0, 0, 1)
            f.Position = UDim2.new(0, 0, 0.5, 0)
        else
            f.Size     = UDim2.new(0, 1, 1, 0)
            f.Position = UDim2.new(0.5, 0, 0, 0)
        end
    end
    line(true); line(false)
end

local function destroyCrosshair()
    if crosshairGui then crosshairGui:Destroy(); crosshairGui = nil end
end

-- ── PLAYER LIST (Spectate mode) ───────────────────────────────────
local function refreshPlayerList()
    local listFrame = getgenv().FreeCamPlayerList
    if not listFrame then return end

    -- Clear existing buttons
    for _, c in pairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local order = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            order = order + 1
            local btn = Instance.new("TextButton")
            btn.Parent = listFrame
            btn.LayoutOrder = order
            btn.Size = UDim2.new(1, -6, 0, 24)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextColor3 = getgenv().COL_TXT
            -- Highlight the currently selected target
            local isSelected = (getgenv().freeCamTarget == p)
            btn.BackgroundColor3 = isSelected and getgenv().COL_ON or getgenv().COL_OFF
            btn.Text = (isSelected and "► " or "  ") .. p.Name
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                getgenv().freeCamTarget = p
                refreshPlayerList()  -- re-highlight
            end)
        end
    end

    -- Auto-size canvas
    local ll = listFrame:FindFirstChildOfClass("UIListLayout")
    if ll then
        listFrame.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 4)
    end
end

-- ── MODE: FREE FLY ────────────────────────────────────────────────
local function startFreeFly()
    saveCameraState()
    Camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    if getgenv().freeCamShowCrosshair then createCrosshair() end

    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not S("freeCamEnabled") or S("freeCamMode") ~= "fly" then return end

        -- Mouse look (raw delta, sensitivity tuned)
        local delta = UserInputService:GetMouseDelta()
        local sens = 0.003
        yawRad   = yawRad   - delta.X * sens
        pitchRad = math.clamp(pitchRad - delta.Y * sens, -math.pi/2 + 0.05, math.pi/2 - 0.05)

        local lookCF = CFrame.Angles(0, yawRad, 0) * CFrame.Angles(pitchRad, 0, 0)
        local speed  = (S("freeCamSpeed") or 50) * dt

        -- WASD + Space/Shift for up/down
        local mv = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W)           then mv = mv + lookCF.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)           then mv = mv - lookCF.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)           then mv = mv - lookCF.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)           then mv = mv + lookCF.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then mv = mv + Vector3.new(0,  speed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)   then mv = mv - Vector3.new(0,  speed, 0) end

        freeCamCF = CFrame.new(freeCamCF.Position + mv) * lookCF
        Camera.CFrame      = freeCamCF
        Camera.FieldOfView = S("freeCamFOV") or 70
    end)
end

-- ── MODE: SPECTATE ────────────────────────────────────────────────
local function startSpectate()
    saveCameraState()
    Camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    destroyCrosshair()
    refreshPlayerList()

    -- Auto-select nearest if none chosen
    if not getgenv().freeCamTarget and getgenv().Utils then
        getgenv().freeCamTarget = getgenv().Utils:FindNearestAlivePlayer(nil)
        if getgenv().freeCamTarget then refreshPlayerList() end
    end

    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not S("freeCamEnabled") or S("freeCamMode") ~= "spectate" then return end

        local target = getgenv().freeCamTarget
        if not target or not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Smooth camera lerp: slightly behind and above target
        local goal = hrp.CFrame * CFrame.new(0, 2.5, 7)
        Camera.CFrame      = Camera.CFrame:Lerp(goal, math.min(1, dt * 7))
        Camera.FieldOfView = S("freeCamFOV") or 70
    end)
end

-- ── MODE: MINIMAP ─────────────────────────────────────────────────
local function startMinimap()
    -- Normal camera stays active — no CameraType change
    destroyCrosshair()
    local sg = getgenv().ScreenGui
    if not sg then return end

    -- Destroy any existing minimap
    if minimapView then minimapView:Destroy(); minimapView = nil end

    -- ViewportFrame in bottom-right corner
    minimapView = Instance.new("ViewportFrame")
    minimapView.Name = "FreeCamMinimap"
    minimapView.Parent = sg
    minimapView.Size = UDim2.new(0, 210, 0, 210)
    minimapView.Position = UDim2.new(1, -222, 1, -222)
    minimapView.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    minimapView.BorderSizePixel = 0
    minimapView.LightColor = Color3.fromRGB(220, 220, 255)
    minimapView.LightDirection = Vector3.new(0, -1, 0.3)
    minimapView.ZIndex = 10
    Instance.new("UICorner", minimapView).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", minimapView)
    stroke.Color = Color3.fromRGB(60, 120, 180); stroke.Thickness = 1.5

    -- Top label
    local lbl = Instance.new("TextLabel", minimapView)
    lbl.Size = UDim2.new(1, 0, 0, 18); lbl.Position = UDim2.new(0, 0, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = "▲ OVERHEAD MAP"
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9
    lbl.TextColor3 = Color3.fromRGB(80, 180, 255)
    lbl.ZIndex = 11

    -- Camera looking straight down
    minimapCam = Instance.new("Camera")
    minimapCam.CameraType = Enum.CameraType.Scriptable
    minimapCam.FieldOfView = 60
    minimapCam.Parent = minimapView
    minimapView.CurrentCamera = minimapCam

    renderConn = RunService.RenderStepped:Connect(function()
        if not S("freeCamEnabled") or S("freeCamMode") ~= "minimap" then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pos = char.HumanoidRootPart.Position
        local h = 70  -- height above player in studs
        minimapCam.CFrame = CFrame.new(pos + Vector3.new(0, h, 0), pos)
    end)
end

local function stopMinimap()
    if minimapView then minimapView:Destroy(); minimapView = nil end
    minimapCam = nil
end

-- ── Enable / Disable ─────────────────────────────────────────────
local function enableFreeCamera()
    if not getgenv().scriptEnabled then return end
    stopRender()
    stopMinimap()

    local mode = getgenv().freeCamMode or "fly"

    if mode == "fly" then
        startFreeFly()
    elseif mode == "spectate" then
        startSpectate()
    elseif mode == "minimap" then
        startMinimap()
    end
end

local function disableFreeCamera()
    getgenv().freeCamEnabled = false
    stopRender()
    stopMinimap()
    destroyCrosshair()
    if getgenv().freeCamMode ~= "minimap" then
        pcall(restoreCamera)
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

-- ── Toggle helper used by button AND [P] keybind ─────────────────
local function toggleFreeCamera()
    if not getgenv().scriptEnabled then return end
    getgenv().freeCamEnabled = not getgenv().freeCamEnabled
    if getgenv().freeCamEnabled then
        getgenv().FreeCameraButton.Text = "FreeCam: ON"
        getgenv().FreeCameraButton.BackgroundColor3 = getgenv().COL_ON
        enableFreeCamera()
    else
        getgenv().FreeCameraButton.Text = "FreeCam: OFF"
        getgenv().FreeCameraButton.BackgroundColor3 = getgenv().COL_OFF
        disableFreeCamera()
    end
end

-- ── Button wiring ─────────────────────────────────────────────────
getgenv().FreeCameraButton.MouseButton1Click:Connect(toggleFreeCamera)

getgenv().FreeCameraButton.MouseButton2Click:Connect(function()
    if getgenv().TogglePanel then getgenv().TogglePanel(getgenv().FreeCameraSettingsFrame) end
    if getgenv().freeCamMode == "spectate" then refreshPlayerList() end
end)

-- ── Mode selector buttons ─────────────────────────────────────────
local function setMode(mode)
    getgenv().freeCamMode = mode
    getgenv().FreeCamFlyBtn.BackgroundColor3      = (mode == "fly")       and getgenv().COL_ON or getgenv().COL_OFF
    getgenv().FreeCamSpectateBtn.BackgroundColor3 = (mode == "spectate")  and getgenv().COL_ON or getgenv().COL_OFF
    getgenv().FreeCamMinimapBtn.BackgroundColor3  = (mode == "minimap")   and getgenv().COL_ON or getgenv().COL_OFF

    -- If already active, switch mode live
    if getgenv().freeCamEnabled then
        enableFreeCamera()
    end
    -- Show player list only in spectate mode
    if getgenv().FreeCamPlayerList then
        if mode == "spectate" then refreshPlayerList() end
    end
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

-- ── Refresh button (player list) ──────────────────────────────────
getgenv().FreeCamRefreshBtn.MouseButton1Click:Connect(refreshPlayerList)

-- ── [P] key = quick toggle ────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P and getgenv().scriptEnabled then
        toggleFreeCamera()
    end
end)

-- ── Export for destroyScript, CharacterAdded ─────────────────────
getgenv().disableFreeCamera = disableFreeCamera
