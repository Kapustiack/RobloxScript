-- [[ RB GLOBAL STATE - ABSOLUTE 1:1 RESTORATION ]]
-- Migrated from rb.lua (All constants, variables, and toggles)

getgenv().scriptEnabled = true
getgenv().flightEnabled = false
getgenv().wallhackEnabled = false
getgenv().espEnabled = false
getgenv().speedhackEnabled = false
getgenv().noclipEnabled = false
getgenv().infiniteJumpEnabled = false
getgenv().fullbrightEnabled = false
getgenv().fovChangerEnabled = false
getgenv().shiftLockDisabled = false
getgenv().ctrlLockDisabled = false
getgenv().followEnabled = false
getgenv().clickCheckEnabled = false
getgenv().deathCheckEnabled = false
getgenv().autoSwitchEnabled = false
getgenv().reachEnabled = false
getgenv().hitboxEnabled = false
getgenv().noDamageEnabled = false
-- NEW: Inf Jump mode
getgenv().infJumpHoldMode = false
getgenv().infJumpHoldConnection = nil
-- NEW: Wallhack options
getgenv().wallhackTransparency = 0.5
getgenv().wallhackTeamCheck = false
-- NEW: FreeCamera
getgenv().freeCamEnabled = false
getgenv().freeCamMode = "fly"
getgenv().freeCamSpeed = 50
getgenv().freeCamFOV = 70
getgenv().freeCamTarget = nil
getgenv().freeCamShowCrosshair = true
-- NEW: ESP visuals
getgenv().espShowTracers    = false
getgenv().espShowSkeleton   = false
getgenv().espShowHealthBars = false
-- NEW: Low Gravity
getgenv().lowGravityEnabled = false
getgenv().lowGravityValue   = 50
-- NEW: Freeze Self
getgenv().freezeSelfEnabled = false



-- Settings & Limits
getgenv().followDistance = 5
getgenv().followHeight = 0
getgenv().followTarget = nil
getgenv().targetHistory = {}
getgenv().reachDistance = 15
getgenv().reachVisual = true
getgenv().hitboxSize = 10
getgenv().hitboxVisual = true
getgenv().espDrawDistance = 1000
getgenv().espShowNames = true
getgenv().espShowDistance = true
getgenv().espShowBoxes = true
getgenv().espUse2DBoxes = false
getgenv().walkSpeed = 16
getgenv().jumpPower = 50
getgenv().speedMultiplier = 1
getgenv().currentFOV = 70
getgenv().defaultFOV = 70
getgenv().noclipDensity = 0.7

-- Internals (Flight / Loops / Display)
getgenv().flightSpeed = 50
getgenv().flying = false
getgenv().flyVelocity = nil
getgenv().bodyGyro = nil
getgenv().smoothFPS = 60
getgenv().lastPingMs = 0
getgenv().nextPingTime = 0
getgenv().guiHidden = false
getgenv().leftMouseClicked = false
getgenv().clickLingerUntil = 0
getgenv().noclipConnection = nil
getgenv().noclipTrackerConnection = nil
getgenv().infiniteJumpConnection = nil
getgenv().followConnection = nil
getgenv().reachActivatedConn = nil
getgenv().reachToolWatcher = nil
getgenv().hitboxAdornments = {}
getgenv().hitboxRestoreFunc = nil
getgenv().noDamageRestoreFunc = nil
getgenv().noDamageLoop = nil
getgenv().fullbrightLoop = nil
getgenv().originalLightingSettings = { saved = false }
getgenv().noclipTrackedParts = {}
getgenv().noclipLastRefresh = 0

-- Sliders dragging
getgenv().draggingESPDistance    = false
getgenv().draggingSpeed          = false
getgenv().draggingFOV            = false
getgenv().draggingFollowDistance = false
getgenv().draggingFollowHeight   = false
getgenv().draggingReachDist      = false
getgenv().draggingHitboxSize     = false
getgenv().draggingFlightSpeed    = false
getgenv().draggingWallhackTransp = false
getgenv().draggingFreeCamSpeed   = false
getgenv().draggingFreeCamFOV     = false
getgenv().draggingLowGravity     = false  -- NEW



-- UI Globals (Pre-assigned to nil)
getgenv().ScreenGui = nil
getgenv().MainFrame = nil
getgenv().ContentScroll = nil
getgenv().HudLabel = nil
getgenv().FlightButton = nil
getgenv().WallhackButton = nil
getgenv().ESPButton = nil
getgenv().SpeedButton = nil
getgenv().NoclipButton = nil
getgenv().InfiniteJumpButton = nil
getgenv().FullbrightButton = nil
getgenv().FOVButton = nil
getgenv().ShiftLockButton = nil
getgenv().CtrlLockButton = nil
getgenv().FollowButton = nil
getgenv().HitboxButton = nil
getgenv().ReachButton = nil
getgenv().SaveButton = nil
getgenv().NoDamageButton = nil
getgenv().RejoinButton = nil
getgenv().JoinInstanceButton = nil

-- UI Settings panels
getgenv().ESPSettingsFrame          = nil
getgenv().SpeedSettingsFrame        = nil
getgenv().FOVSettingsFrame          = nil
getgenv().FollowSettingsFrame       = nil
getgenv().ReachSettingsFrame        = nil
getgenv().HitboxSettingsFrame       = nil
getgenv().FlightSettingsFrame       = nil
getgenv().InfiniteJumpSettingsFrame = nil
getgenv().WallhackSettingsFrame     = nil
getgenv().FreeCameraSettingsFrame   = nil  -- NEW
-- FreeCam panel elements
getgenv().FreeCameraButton    = nil
getgenv().FreeCamFlyBtn       = nil
getgenv().FreeCamSpectateBtn  = nil
getgenv().FreeCamMinimapBtn   = nil
getgenv().FreeCamCrosshairBtn = nil
getgenv().FreeCamRefreshBtn   = nil
getgenv().FreeCamPlayerList   = nil
getgenv().FreeCamSpeedLabel   = nil
getgenv().FreeCamSpeedSlider  = nil
getgenv().FreeCamFOVLabel     = nil
getgenv().FreeCamFOVSlider    = nil



-- Colors
getgenv().COL_BG   = Color3.fromRGB(13, 13, 20)
getgenv().COL_BAR  = Color3.fromRGB(9,  9, 15)
getgenv().COL_OFF  = Color3.fromRGB(30, 30, 44)
getgenv().COL_ON   = Color3.fromRGB(25, 145, 80)
getgenv().COL_TXT  = Color3.fromRGB(205, 205, 222)
getgenv().COL_MUTE = Color3.fromRGB(80, 80, 100)
getgenv().COL_CLO  = Color3.fromRGB(155, 32, 46)
