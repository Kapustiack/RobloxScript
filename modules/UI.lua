local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UI = {}

function UI:Init(state)
    -- [[ RAW UI CREATION - Migrated 1:1 from rb.lua ]]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CheatGUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true

    local COL_BG   = Color3.fromRGB(13, 13, 20)
    local COL_BAR  = Color3.fromRGB(9,  9, 15)
    local COL_OFF  = Color3.fromRGB(30, 30, 44)
    local COL_ON   = Color3.fromRGB(25, 145, 80)
    local COL_TXT  = Color3.fromRGB(205, 205, 222)
    local COL_MUTE = Color3.fromRGB(80, 80, 100)
    local COL_CLO  = Color3.fromRGB(155, 32, 46)

    -- HUD
    local HudFrame = Instance.new("Frame")
    HudFrame.Name = "FPSPingHUD"; HudFrame.Parent = ScreenGui
    HudFrame.Size = UDim2.new(0, 145, 0, 24); HudFrame.Position = UDim2.new(1, -153, 0, 8)
    HudFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 15); HudFrame.BackgroundTransparency = 0.3; HudFrame.BorderSizePixel = 0
    Instance.new("UICorner", HudFrame).CornerRadius = UDim.new(1, 0)
    local HudStroke = Instance.new("UIStroke", HudFrame); HudStroke.Color = Color3.fromRGB(40, 40, 60); HudStroke.Thickness = 1
    local HudLabel = Instance.new("TextLabel")
    HudLabel.Parent = HudFrame; HudLabel.BackgroundTransparency = 1; HudLabel.Size = UDim2.new(1, 0, 1, 0)
    HudLabel.Font = Enum.Font.GothamBold; HudLabel.TextSize = 11; HudLabel.TextColor3 = Color3.fromRGB(205, 205, 222)
    HudLabel.Text = "FPS: -- | Ping: --ms"; HudLabel.TextXAlignment = Enum.TextXAlignment.Center; HudLabel.RichText = true

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = COL_BG; MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 18, 0.5, -190); MainFrame.Size = UDim2.new(0, 380, 0, 100); MainFrame.Active = true; MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local MStroke = Instance.new("UIStroke", MainFrame); MStroke.Color = Color3.fromRGB(40, 40, 56); MStroke.Thickness = 1

    local Title = Instance.new("Frame")
    Title.Name = "Title"; Title.Parent = MainFrame; Title.BackgroundColor3 = COL_BAR; Title.BorderSizePixel = 0; Title.Size = UDim2.new(1, 0, 0, 32)
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Title; TitleLabel.BackgroundTransparency = 1; TitleLabel.Size = UDim2.new(1, -58, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.Text = "RB Cheat  ·  right-click = settings"; TitleLabel.TextColor3 = COL_TXT; TitleLabel.TextSize = 11; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local HideButton = Instance.new("TextButton")
    HideButton.Name = "HideButton"; HideButton.Parent = Title; HideButton.BackgroundColor3 = Color3.fromRGB(50, 50, 68); HideButton.BorderSizePixel = 0
    HideButton.Position = UDim2.new(1, -50, 0.5, -9); HideButton.Size = UDim2.new(0, 18, 0, 18); HideButton.Font = Enum.Font.GothamBold; HideButton.Text = "-"; HideButton.TextColor3 = Color3.fromRGB(200, 200, 220); HideButton.TextSize = 16
    Instance.new("UICorner", HideButton).CornerRadius = UDim.new(0, 4)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"; CloseButton.Parent = Title; CloseButton.BackgroundColor3 = COL_CLO; CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -26, 0.5, -9); CloseButton.Size = UDim2.new(0, 18, 0, 18); CloseButton.Font = Enum.Font.GothamBold; CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.new(1,1,1); CloseButton.TextSize = 11
    Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 4)

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name = "ContentScroll"; ContentScroll.Parent = MainFrame; ContentScroll.BackgroundTransparency = 1; ContentScroll.BorderSizePixel = 0
    ContentScroll.Position = UDim2.new(0, 0, 0, 32); ContentScroll.Size = UDim2.new(1, 0, 1, -32); ContentScroll.ScrollBarThickness = 3
    ContentScroll.ScrollBarImageColor3 = COL_MUTE; ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local function createStyledButton(name, text, position, size)
        local b = Instance.new("TextButton")
        b.Name = name; b.Parent = ContentScroll; b.BackgroundColor3 = COL_OFF; b.BorderSizePixel = 0
        b.Position = position; b.Size = size; b.Font = Enum.Font.Gotham; b.Text = text; b.TextColor3 = COL_TXT; b.TextSize = 12
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function()
            if b.BackgroundColor3 ~= COL_ON then
                TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(46,46,62)}):Play()
            end
        end)
        b.MouseLeave:Connect(function()
            if b.BackgroundColor3 ~= COL_ON then
                TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = COL_OFF}):Play()
            end
        end)
        return b
    end

    local PAD, BH, GAP = 12, 28, 8
    local BW  = (380 - PAD*2 - 8) / 2
    local function rowY(r) return PAD + (r-1)*(BH+GAP) end
    local function colX(c) return PAD + (c-1)*(BW+8) end
    local function makeBtn(n,t,c,r) return createStyledButton(n,t, UDim2.new(0,colX(c),0,rowY(r)), UDim2.new(0,BW,0,BH)) end

    -- All 17 Buttons
    self.Buttons = {
        Flight         = makeBtn("FlightButton",       "Flight: OFF",     1, 1),
        Wallhack       = makeBtn("WallhackButton",     "Wallhack: OFF",   2, 1),
        ESP            = makeBtn("ESPButton",          "ESP: OFF",        1, 2),
        Speed          = makeBtn("SpeedButton",        "Speed: OFF",      2, 2),
        Noclip         = makeBtn("NoclipButton",       "Noclip: OFF",     1, 3),
        InfJump        = makeBtn("InfiniteJumpButton", "Inf Jump: OFF",   2, 3),
        Fullbright     = makeBtn("FullbrightButton",   "Fullbright: OFF", 1, 4),
        FOV            = makeBtn("FOVButton",          "FOV: OFF",        2, 4),
        ShiftLock      = makeBtn("ShiftLockButton",    "Shift Lock: OFF", 1, 5),
        CtrlLock       = makeBtn("CtrlLockButton",     "Ctrl Lock: OFF",  2, 5),
        Follow         = makeBtn("FollowButton",       "Follow: OFF",     1, 6),
        Hitbox         = makeBtn("HitboxButton",       "Hitbox: OFF",     2, 6),
        Reach          = makeBtn("ReachButton",        "Reach: OFF",      1, 7),
        Save           = makeBtn("SaveButton",         "Save Settings",   2, 7),
        NoDamage       = makeBtn("NoDamageButton",     "No Damage: OFF",  1, 8),
        Rejoin         = makeBtn("RejoinButton",       "Rejoin Server",   2, 8),
        JoinInstance   = makeBtn("JoinInstanceButton", "Join Instance",   1, 9)
    }

    local canvasH = rowY(9) + BH + 28
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, canvasH)
    local visibleH = rowY(5) + BH + 10
    MainFrame.Size = UDim2.new(0, 380, 0, 32 + visibleH)

    -- [[ SUB-PANEL FACTORY (RAW) ]]
    local function makePanel(name, title, w, h)
        local f = Instance.new("Frame"); f.Name = name; f.Parent = ScreenGui
        f.BackgroundColor3 = Color3.fromRGB(16, 16, 23); f.BorderSizePixel = 0; f.Position = UDim2.new(0.5, -w/2, 0.5, -h/2); f.Size = UDim2.new(0, w, 0, h); f.Visible = false; f.Active = true; f.Draggable = true
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(38, 38, 54); s.Thickness = 1
        local tb = Instance.new("Frame"); tb.Parent = f; tb.BackgroundColor3 = Color3.fromRGB(10, 10, 16); tb.BorderSizePixel = 0; tb.Size = UDim2.new(1, 0, 0, 30); Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
        local tl = Instance.new("TextLabel"); tl.Parent = tb; tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, -34, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0); tl.Font = Enum.Font.GothamBold; tl.Text = title; tl.TextColor3 = COL_TXT; tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left
        local cb = Instance.new("TextButton"); cb.Parent = tb; cb.BackgroundColor3 = COL_CLO; cb.BorderSizePixel = 0; cb.Position = UDim2.new(1, -24, 0.5, -8); cb.Size = UDim2.new(0, 16, 0, 16); cb.Font = Enum.Font.GothamBold; cb.Text = "X"; cb.TextColor3 = Color3.new(1,1,1); cb.TextSize = 11; Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        cb.MouseButton1Click:Connect(function() f.Visible = false end)
        return f
    end

    self.Panels = {
        ESP     = makePanel("ESPSettingsFrame", "ESP Settings", 300, 172),
        Speed   = makePanel("SpeedSettingsFrame", "Speed Settings", 300, 100),
        FOV     = makePanel("FOVSettingsFrame", "FOV Settings", 300, 100),
        Follow  = makePanel("FollowSettingsFrame", "Follow Settings", 300, 204),
        Reach   = makePanel("ReachSettingsFrame", "Reach Settings", 300, 128),
        Hitbox  = makePanel("HitboxSettingsFrame", "Hitbox Settings", 300, 134)
    }

    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.HudLabel  = HudLabel
    self.CloseBtn  = CloseButton
    self.HideBtn   = HideButton
    self.COL_ON    = COL_ON
    self.COL_OFF   = COL_OFF

    return self
end

return UI
