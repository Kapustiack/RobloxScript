-- [[ RB GLOBAL STATE & VARIABLES ]]
-- Migrated 1:1 from rb.lua (Lines 1-75 and 415-431)
-- Added to getgenv() so all modular scripts can see them exactly like the original.

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
getgenv().reachEnabled = false
getgenv().hitboxEnabled = false
getgenv().noDamageEnabled = false

-- Follow settings
getgenv().followDistance = 5
getgenv().followHeight = 0
getgenv().followTarget = nil
getgenv().originalPosition = nil
getgenv().followConnection = nil
getgenv().deathCheckEnabled = false
getgenv().autoSwitchEnabled = false
getgenv().targetHistory = {}

-- Reach Extender settings
getgenv().reachDistance = 15
getgenv().reachVisual = true
getgenv().reachIndicator = nil
getgenv().reachActivatedConn = nil
getgenv().reachToolWatcher = nil

-- Hitbox Expander settings
getgenv().hitboxSize = 10
getgenv().hitboxVisual = true
getgenv().hitboxAdornments = {}
getgenv().hitboxRestoreFunc = nil

-- ESP Settings
getgenv().espDrawDistance = 1000
getgenv().espShowNames = true
getgenv().espShowDistance = true
getgenv().espShowBoxes = true
getgenv().espUse2DBoxes = false

-- Speed settings
getgenv().walkSpeed = 16
getgenv().jumpPower = 50
getgenv().speedMultiplier = 1

-- FOV settings
getgenv().defaultFOV = 70
getgenv().currentFOV = 70

-- Teleport settings
getgenv().teleportEnabled = true

-- Fullbright settings
getgenv().originalLightingSettings = {}

-- Loops & internal
getgenv().noclipConnection = nil
getgenv().infiniteJumpConnection = nil
getgenv().fovDragging = false
getgenv().guiHidden = false
getgenv().followDragging = false
getgenv().followHeightDragging = false
getgenv().leftMouseClicked = false
getgenv().clickLingerUntil = 0
