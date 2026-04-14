-- [[ RB GLOBAL STATE - Migrated 1:1 from rb.lua ]]
-- This table is stored in getgenv() so all modules can "see" and "edit" the same variables.

if not getgenv().RB_STATE then
    getgenv().RB_STATE = {
        scriptEnabled = true,
        flightEnabled = false,
        wallhackEnabled = false,
        espEnabled = false,
        speedhackEnabled = false,
        noclipEnabled = false,
        infiniteJumpEnabled = false,
        fullbrightEnabled = false,
        fovChangerEnabled = false,
        shiftLockDisabled = false,
        ctrlLockDisabled = false,
        followEnabled = false,
        clickCheckEnabled = false,
        reachEnabled = false,
        hitboxEnabled = false,
        noDamageEnabled = false,

        -- Follow settings
        followDistance = 5,
        followHeight = 0,
        followTarget = nil,
        originalPosition = nil,
        followConnection = nil,
        deathCheckEnabled = false,
        autoSwitchEnabled = false,
        targetHistory = {},

        -- Reach Extender settings
        reachDistance = 15,
        reachVisual = true,
        reachIndicator = nil,
        reachActivatedConn = nil,
        reachToolWatcher = nil,

        -- Hitbox Expander settings
        hitboxSize = 10,
        hitboxVisual = true,
        hitboxAdornments = {},
        hitboxRestoreFunc = nil,

        -- ESP Settings
        espDrawDistance = 1000,
        espShowNames = true,
        espShowDistance = true,
        espShowBoxes = true,
        espUse2DBoxes = false,

        -- Speed settings
        walkSpeed = 16,
        jumpPower = 50,
        speedMultiplier = 1,

        -- FOV settings
        defaultFOV = 70,
        currentFOV = 70,

        -- Teleport settings
        teleportEnabled = true,

        -- Fullbright settings
        originalLightingSettings = {},
        
        -- UI State
        guiHidden = false,
        leftMouseClicked = false,
        clickLingerUntil = 0
    }
end

return getgenv().RB_STATE
