local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- [[ RAW UI CREATION - Migrated 1:1 from rb.lua ]]
-- This file handles VISUALS. Logic is centralized in feature files.

getgenv().ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatGUI"; ScreenGui.Parent = CoreGui; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ScreenGui.IgnoreGuiInset = true

-- FPS / Ping HUD
local HudFrame = Instance.new("Frame")
HudFrame.Name = "FPSPingHUD"; HudFrame.Parent = ScreenGui; HudFrame.Size = UDim2.new(0, 145, 0, 24); HudFrame.Position = UDim2.new(1, -153, 0, 8); HudFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 15); HudFrame.BackgroundTransparency = 0.3; HudFrame.BorderSizePixel = 0
Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(1, 0)
local HudStroke = Instance.new("UIStroke", HudFrame); HudStroke.Color = Color3.fromRGB(40, 40, 60); HudStroke.Thickness = 1
getgenv().HudLabel = Instance.new("TextLabel"); HudLabel.Parent = HudFrame; HudLabel.BackgroundTransparency = 1; HudLabel.Size = UDim2.new(1, 0, 1, 0); HudLabel.Font = Enum.Font.GothamBold; HudLabel.TextSize = 11; HudLabel.TextColor3 = getgenv().COL_TXT; HudLabel.RichText = true; HudLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Main Frame
getgenv().MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = getgenv().COL_BG; MainFrame.BorderSizePixel = 0; MainFrame.Position = UDim2.new(0, 18, 0.5, -190); MainFrame.Size = UDim2.new(0, 380, 0, 226); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MStroke = Instance.new("UIStroke", MainFrame); MStroke.Color = Color3.fromRGB(40, 40, 56); MStroke.Thickness = 1

local Title = Instance.new("Frame")
Title.Name = "Title"; Title.Parent = MainFrame; Title.BackgroundColor3 = getgenv().COL_BAR; Title.BorderSizePixel = 0; Title.Size = UDim2.new(1, 0, 0, 32); Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)
local TitleLabel = Instance.new("TextLabel"); TitleLabel.Parent = Title; TitleLabel.BackgroundTransparency = 1; TitleLabel.Size = UDim2.new(1, -58, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.Text = "RB Cheat · right-click = settings"; TitleLabel.TextColor3 = getgenv().COL_TXT; TitleLabel.TextSize = 11; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

getgenv().HideButton = Instance.new("TextButton")
HideButton.Name = "HideButton"; HideButton.Parent = Title; HideButton.BackgroundColor3 = Color3.fromRGB(50, 50, 68); HideButton.BorderSizePixel = 0; HideButton.Position = UDim2.new(1, -50, 0.5, -9); HideButton.Size = UDim2.new(0, 18, 0, 18); HideButton.Font = Enum.Font.GothamBold; HideButton.Text = "-"; HideButton.TextColor3 = Color3.fromRGB(200, 200, 220); HideButton.TextSize = 16; Instance.new("UICorner", HideButton).CornerRadius = UDim.new(0, 4)

getgenv().CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"; CloseButton.Parent = Title; CloseButton.BackgroundColor3 = getgenv().COL_CLO; CloseButton.BorderSizePixel = 0; CloseButton.Position = UDim2.new(1, -26, 0.5, -9); CloseButton.Size = UDim2.new(0, 18, 0, 18); CloseButton.Font = Enum.Font.GothamBold; CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.new(1,1,1); CloseButton.TextSize = 11; Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 4)

getgenv().ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"; ContentScroll.Parent = MainFrame; ContentScroll.BackgroundTransparency = 1; ContentScroll.BorderSizePixel = 0; ContentScroll.Position = UDim2.new(0, 0, 0, 32); ContentScroll.Size = UDim2.new(1, 0, 1, -32); ContentScroll.ScrollBarThickness = 3; ContentScroll.ScrollBarImageColor3 = getgenv().COL_MUTE; ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y; ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 400)

local function makeBtn(n, t, c, r)
    local PAD, BH, BW, GAP = 12, 28, (380 - 12*2 - 8) / 2, 8
    local function rowY(rv) return PAD + (rv-1)*(BH+GAP) end
    local function colX(cv) return PAD + (cv-1)*(BW+8) end
    local b = Instance.new("TextButton"); b.Name = n; b.Parent = ContentScroll; b.BackgroundColor3 = getgenv().COL_OFF; b.BorderSizePixel = 0; b.Position = UDim2.new(0, colX(c), 0, rowY(r)); b.Size = UDim2.new(0, BW, 0, BH); b.Font = Enum.Font.Gotham; b.Text = t; b.TextColor3 = getgenv().COL_TXT; b.TextSize = 12; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseEnter:Connect(function() if b.BackgroundColor3 ~= getgenv().COL_ON then TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(46,46,62)}):Play() end end)
    b.MouseLeave:Connect(function() if b.BackgroundColor3 ~= getgenv().COL_ON then TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = getgenv().COL_OFF}):Play() end end)
    return b
end

getgenv().FlightButton       = makeBtn("FlightButton",       "Flight: OFF",     1, 1)
getgenv().WallhackButton     = makeBtn("WallhackButton",     "Wallhack: OFF",   2, 1)
getgenv().ESPButton          = makeBtn("ESPButton",          "ESP: OFF",        1, 2)
getgenv().SpeedButton        = makeBtn("SpeedButton",        "Speed: OFF",      2, 2)
getgenv().NoclipButton       = makeBtn("NoclipButton",       "Noclip: OFF",     1, 3)
getgenv().InfiniteJumpButton = makeBtn("InfiniteJumpButton", "Inf Jump: OFF",   2, 3)
getgenv().FullbrightButton   = makeBtn("FullbrightButton",   "Fullbright: OFF", 1, 4)
getgenv().FOVButton          = makeBtn("FOVButton",          "FOV: OFF",        2, 4)
getgenv().ShiftLockButton    = makeBtn("ShiftLockButton",    "Shift Lock: OFF", 1, 5)
getgenv().CtrlLockButton     = makeBtn("CtrlLockButton",     "Ctrl Lock: OFF",  2, 5)
getgenv().FollowButton       = makeBtn("FollowButton",       "Follow: OFF",     1, 6)
getgenv().HitboxButton       = makeBtn("HitboxButton",       "Hitbox: OFF",     2, 6)
getgenv().ReachButton        = makeBtn("ReachButton",        "Reach: OFF",      1, 7)
getgenv().SaveButton         = makeBtn("SaveButton",         "Save Settings",   2, 7)
getgenv().NoDamageButton     = makeBtn("NoDamageButton",     "No Damage: OFF",  1, 8)
getgenv().RejoinButton       = makeBtn("RejoinButton",       "Rejoin Server",   2, 8)
getgenv().JoinInstanceButton = makeBtn("JoinInstanceButton", "Join Instance",   1, 9)

local PAD, BH, GAP = 12, 28, 8
local function rowY(r) return PAD + (r-1)*(BH+GAP) end
getgenv().TipLabel = Instance.new("TextLabel"); TipLabel.Parent = ContentScroll; TipLabel.BackgroundTransparency = 1; TipLabel.Position = UDim2.new(0, 12, 0, rowY(10)); TipLabel.Size = UDim2.new(1, -24, 0, 20); TipLabel.Font = Enum.Font.Gotham; TipLabel.Text = "Ctrl+Click = Teleport | Right-click = Settings | Shift+C = Hide"; TipLabel.TextColor3 = getgenv().COL_MUTE; TipLabel.TextSize = 10; TipLabel.TextXAlignment = Enum.TextXAlignment.Center
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, rowY(10) + 30)

local function makePanel(name, title, w, h)
    local f = Instance.new("Frame"); f.Name = name; f.Parent = ScreenGui; f.BackgroundColor3 = Color3.fromRGB(16, 16, 23); f.BorderSizePixel = 0; f.Position = UDim2.new(0.5, -w/2, 0.5, -h/2); f.Size = UDim2.new(0, w, 0, h); f.Visible = false; f.Active = true; f.Draggable = true; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8); local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(38, 38, 54); s.Thickness = 1
    local tb = Instance.new("Frame"); tb.Parent = f; tb.BackgroundColor3 = Color3.fromRGB(10, 10, 16); tb.BorderSizePixel = 0; tb.Size = UDim2.new(1, 0, 0, 30); Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    local tl = Instance.new("TextLabel"); tl.Parent = tb; tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, -34, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0); tl.Font = Enum.Font.GothamBold; tl.Text = title; tl.TextColor3 = getgenv().COL_TXT; tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left
    local cb = Instance.new("TextButton"); cb.Parent = tb; cb.BackgroundColor3 = getgenv().COL_CLO; cb.BorderSizePixel = 0; cb.Position = UDim2.new(1, -24, 0.5, -8); cb.Size = UDim2.new(0, 16, 0, 16); cb.Font = Enum.Font.GothamBold; cb.Text = "X"; cb.TextColor3 = Color3.new(1,1,1); cb.TextSize = 11; Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4); cb.MouseButton1Click:Connect(function() f.Visible = false end)
    return f
end
local function pBtn(par, name, text, x, y, w, h)
    local b = Instance.new("TextButton"); b.Name = name; b.Parent = par; b.BackgroundColor3 = getgenv().COL_OFF; b.BorderSizePixel = 0; b.Position = UDim2.new(0, x, 0, y); b.Size = UDim2.new(0, w, 0, h or 26); b.Font = Enum.Font.Gotham; b.Text = text; b.TextColor3 = getgenv().COL_TXT; b.TextSize = 11; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end
local function pLabel(par, name, text, x, y, w, h)
    local l = Instance.new("TextLabel"); l.Name = name; l.Parent = par; l.BackgroundColor3 = Color3.fromRGB(22, 22, 32); l.BorderSizePixel = 0; l.Position = UDim2.new(0, x, 0, y); l.Size = UDim2.new(0, w, 0, h or 24); l.Font = Enum.Font.Gotham; l.Text = text; l.TextColor3 = getgenv().COL_TXT; l.TextSize = 11; Instance.new("UICorner", l).CornerRadius = UDim.new(0, 5)
    return l
end
local function pSlider(par, name, x, y, w)
    local s = Instance.new("TextButton"); s.Name = name; s.Parent = par; s.BackgroundColor3 = Color3.fromRGB(38, 38, 54); s.BorderSizePixel = 0; s.Position = UDim2.new(0, x, 0, y); s.Size = UDim2.new(0, w, 0, 14); s.Font = Enum.Font.Gotham; s.Text = ""; Instance.new("UICorner", s).CornerRadius = UDim.new(0, 7)
    return s
end

getgenv().ESPSettingsFrame    = makePanel("ESPSettingsFrame", "ESP Settings", 300, 172)
getgenv().ESPShowNamesBtn     = pBtn(ESPSettingsFrame, "ESPShowNamesBtn",    "Names: ON",     12, 40, 130, 26)
getgenv().ESPShowDistBtn      = pBtn(ESPSettingsFrame, "ESPShowDistBtn",     "Distance: ON",  158, 40, 130, 26)
getgenv().ESPShowBoxesBtn     = pBtn(ESPSettingsFrame, "ESPShowBoxesBtn",    "3D Boxes: ON",  12, 76, 130, 26)
getgenv().ESP2DBoxesBtn       = pBtn(ESPSettingsFrame, "ESP2DBoxesBtn",      "2D Boxes: OFF", 158, 76, 130, 26)
getgenv().ESPDistanceLabel    = pLabel(ESPSettingsFrame, "ESPDistanceLabel", "Distance: 1000", 12, 112, 276, 24)
getgenv().ESPDistanceSlider   = pSlider(ESPSettingsFrame, "ESPDistanceSlider", 12, 146, 276)

getgenv().SpeedSettingsFrame  = makePanel("SpeedSettingsFrame", "Speed Settings", 300, 100)
getgenv().SpeedLabel          = pLabel(SpeedSettingsFrame, "SpeedLabel", "Speed Multiplier: 1.0x", 12, 40, 276, 24)
getgenv().SpeedSlider         = pSlider(SpeedSettingsFrame, "SpeedSlider", 12, 74, 276)

getgenv().FOVSettingsFrame    = makePanel("FOVSettingsFrame", "FOV Settings", 300, 100)
getgenv().FOVLabel            = pLabel(FOVSettingsFrame, "FOVLabel", "FOV: 70°", 12, 40, 276, 24)
getgenv().FOVSlider           = pSlider(FOVSettingsFrame, "FOVSlider", 12, 74, 276)

getgenv().FollowSettingsFrame = makePanel("FollowSettingsFrame", "Follow Settings", 300, 204)
getgenv().FollowDistanceLabel = pLabel(FollowSettingsFrame, "FollowDistLabel",   "Distance: 5",  12,  40, 130, 24)
getgenv().FollowHeightLabel   = pLabel(FollowSettingsFrame, "FollowHeightLabel", "Height: 0",    158, 40, 130, 24)
getgenv().FollowDistanceSlider= pSlider(FollowSettingsFrame, "FollowDistSlider",  12,  74, 130)
getgenv().FollowHeightSlider  = pSlider(FollowSettingsFrame, "FollowHeightSlider",158, 74, 130)
getgenv().ClickCheckBtn       = pBtn(FollowSettingsFrame, "ClickCheckBtn",   "Click Check: OFF",  12, 98,  276, 26)
getgenv().DeathCheckBtn       = pBtn(FollowSettingsFrame, "DeathCheckBtn",   "Death Check: OFF",  12, 132, 130, 26)
getgenv().AutoSwitchBtn       = pBtn(FollowSettingsFrame, "AutoSwitchBtn",   "Auto Switch: OFF",  158, 132, 130, 26)
getgenv().SwitchTargetBtn     = pBtn(FollowSettingsFrame, "SwitchTargetBtn", "Switch Target",     12, 166, 276, 26)

getgenv().ReachSettingsFrame  = makePanel("ReachSettingsFrame", "Reach Settings", 300, 128)
getgenv().ReachDistLabel      = pLabel(ReachSettingsFrame, "ReachDistLabel",  "Reach Distance: 15", 12, 40, 276, 24)
getgenv().ReachDistSlider     = pSlider(ReachSettingsFrame, "ReachDistSlider", 12, 72, 276)
getgenv().ReachVisualBtn      = pBtn(ReachSettingsFrame, "ReachVisualBtn", "Visual: ON", 12, 92, 130, 26)

getgenv().HitboxSettingsFrame = makePanel("HitboxSettingsFrame", "Hitbox Settings", 300, 134)
getgenv().HitboxSizeLabel     = pLabel(HitboxSettingsFrame, "HitboxSizeLabel",  "Hitbox Size: 10", 12, 40, 276, 24)
getgenv().HitboxSizeSlider    = pSlider(HitboxSettingsFrame, "HitboxSizeSlider", 12, 72, 276)
getgenv().HitboxVisualBtn     = pBtn(HitboxSettingsFrame, "HitboxVisualBtn", "Visual: ON",  12, 98, 130, 26)

getgenv().FlightSettingsFrame = makePanel("FlightSettingsFrame", "Flight Settings", 300, 100)
getgenv().FlightSpeedLabel    = pLabel(FlightSettingsFrame, "FlightSpeedLabel", "Flight Speed: 50", 12, 40, 276, 24)
getgenv().FlightSpeedSlider   = pSlider(FlightSettingsFrame, "FlightSpeedSlider", 12, 74, 276)

getgenv().TogglePanel = function(target)
    local panels = {ESPSettingsFrame, SpeedSettingsFrame, FOVSettingsFrame, FollowSettingsFrame, ReachSettingsFrame, HitboxSettingsFrame, FlightSettingsFrame}
    local newState = not target.Visible
    for _, p in pairs(panels) do p.Visible = false end
    target.Visible = newState
end

-- Logic is now handled in main.lua to ensure global state availability
