-- [[ RB GLOBAL STATE & VARIABLES - LITERAL 1:1 ]]
-- Migrated from rb.lua (All variables found in the script)

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

-- Feature settings
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

-- Flight internals
getgenv().flightSpeed = 50
getgenv().flying = false
getgenv().flyVelocity = nil
getgenv().bodyGyro = nil

-- Loop & Display internals
getgenv().smoothFPS = 60
getgenv().lastPingMs = 0
getgenv().nextPingTime = 0
getgenv().guiHidden = false
getgenv().leftMouseClicked = false
getgenv().clickLingerUntil = 0
getgenv().noclipConnection = nil
getgenv().infiniteJumpConnection = nil
getgenv().followConnection = nil
getgenv().reachActivatedConn = nil
getgenv().reachToolWatcher = nil
getgenv().hitboxAdornments = {}
getgenv().hitboxRestoreFunc = nil
getgenv().originalLightingSettings = {}
