-- [[ SAVE SYSTEM — Writes to executor workspace RBHub/ folder ]]
-- File layout: RBHub/saves/<profileName>.json
-- Profile list: RBHub/profiles.json
-- NOTE: Executor APIs (writefile/readfile/makefolder/isfile) write to the
--       executor's own workspace directory (e.g. Synapse/workspace/, KRNL/workspace/).
--       This cannot be changed to C:\Users\Downloads due to executor sandboxing,
--       but the folder is clearly organized and easy to find.

local HttpService = game:GetService("HttpService")

local SAVE_DIR      = "RBHub"
local SAVES_DIR     = "RBHub/saves"
local PROFILES_FILE = "RBHub/profiles.json"

-- Create directories on first load
local function ensureDirs()
    pcall(makefolder, SAVE_DIR)
    pcall(makefolder, SAVES_DIR)
end

-- ── Profile list management ───────────────────────────────────────
local function getProfiles()
    local ok, data = pcall(readfile, PROFILES_FILE)
    if ok and data and #data > 2 then
        local ok2, t = pcall(HttpService.JSONDecode, HttpService, data)
        if ok2 and type(t) == "table" then return t end
    end
    return {"default"}
end

local function saveProfiles(list)
    pcall(writefile, PROFILES_FILE, HttpService:JSONEncode(list))
end

-- ── Serialize current state to JSON ──────────────────────────────
local function serializeSettings()
    local t = {
        _version   = 1,
        _profile   = getgenv().currentSaveProfile or "default",
        _player    = game:GetService("Players").LocalPlayer.Name,
        _game      = tostring(game.PlaceId),
        _saved     = os.time(),
        -- Feature states
        flightEnabled       = getgenv().flightEnabled,
        wallhackEnabled     = getgenv().wallhackEnabled,
        espEnabled          = getgenv().espEnabled,
        speedhackEnabled    = getgenv().speedhackEnabled,
        noclipEnabled       = getgenv().noclipEnabled,
        infiniteJumpEnabled = getgenv().infiniteJumpEnabled,
        fullbrightEnabled   = getgenv().fullbrightEnabled,
        fovChangerEnabled   = getgenv().fovChangerEnabled,
        noDamageEnabled     = getgenv().noDamageEnabled,
        reachEnabled        = getgenv().reachEnabled,
        hitboxEnabled       = getgenv().hitboxEnabled,
        lowGravityEnabled   = getgenv().lowGravityEnabled,
        freezeSelfEnabled   = false,  -- don't restore freeze (safety)
        -- Settings values
        speedMultiplier     = getgenv().speedMultiplier,
        currentFOV          = getgenv().currentFOV,
        followDistance      = getgenv().followDistance,
        followHeight        = getgenv().followHeight,
        reachDistance       = getgenv().reachDistance,
        hitboxSize          = getgenv().hitboxSize,
        flightSpeed         = getgenv().flightSpeed,
        espDrawDistance     = getgenv().espDrawDistance,
        freeCamSpeed        = getgenv().freeCamSpeed,
        freeCamFOV          = getgenv().freeCamFOV,
        freeCamMode         = getgenv().freeCamMode,
        freeCamShowCrosshair= getgenv().freeCamShowCrosshair,
        lowGravityValue     = getgenv().lowGravityValue,
        wallhackTransparency= getgenv().wallhackTransparency,
        wallhackTeamCheck   = getgenv().wallhackTeamCheck,
        infJumpHoldMode     = getgenv().infJumpHoldMode,
        -- ESP visual toggles
        espShowNames        = getgenv().espShowNames,
        espShowDistance     = getgenv().espShowDistance,
        espShowBoxes        = getgenv().espShowBoxes,
        espUse2DBoxes       = getgenv().espUse2DBoxes,
        espShowTracers      = getgenv().espShowTracers,
        espShowSkeleton     = getgenv().espShowSkeleton,
        espShowHealthBars   = getgenv().espShowHealthBars,
        -- Follow settings
        clickCheckEnabled   = getgenv().clickCheckEnabled,
        deathCheckEnabled   = getgenv().deathCheckEnabled,
        autoSwitchEnabled   = getgenv().autoSwitchEnabled,
    }
    return HttpService:JSONEncode(t)
end

-- ── Apply loaded settings to state (does NOT toggle features on/off) ─
local function applySettings(t)
    if type(t) ~= "table" then return end
    local function apply(k, v)
        if v ~= nil then getgenv()[k] = v end
    end
    apply("speedMultiplier",      t.speedMultiplier)
    apply("currentFOV",           t.currentFOV)
    apply("followDistance",       t.followDistance)
    apply("followHeight",         t.followHeight)
    apply("reachDistance",        t.reachDistance)
    apply("hitboxSize",           t.hitboxSize)
    apply("flightSpeed",          t.flightSpeed)
    apply("espDrawDistance",      t.espDrawDistance)
    apply("freeCamSpeed",         t.freeCamSpeed)
    apply("freeCamFOV",           t.freeCamFOV)
    apply("freeCamMode",          t.freeCamMode)
    apply("freeCamShowCrosshair", t.freeCamShowCrosshair)
    apply("lowGravityValue",      t.lowGravityValue)
    apply("wallhackTransparency", t.wallhackTransparency)
    apply("wallhackTeamCheck",    t.wallhackTeamCheck)
    apply("infJumpHoldMode",      t.infJumpHoldMode)
    apply("espShowNames",         t.espShowNames)
    apply("espShowDistance",      t.espShowDistance)
    apply("espShowBoxes",         t.espShowBoxes)
    apply("espUse2DBoxes",        t.espUse2DBoxes)
    apply("espShowTracers",       t.espShowTracers)
    apply("espShowSkeleton",      t.espShowSkeleton)
    apply("espShowHealthBars",    t.espShowHealthBars)
    apply("clickCheckEnabled",    t.clickCheckEnabled)
    apply("deathCheckEnabled",    t.deathCheckEnabled)
    apply("autoSwitchEnabled",    t.autoSwitchEnabled)
end

-- ── Public API ────────────────────────────────────────────────────
local function saveSettings(profileName)
    ensureDirs()
    local name = profileName or getgenv().currentSaveProfile or "default"
    getgenv().currentSaveProfile = name
    local path = SAVES_DIR .. "/" .. name .. ".json"
    local json = serializeSettings()
    local ok, err = pcall(writefile, path, json)
    if ok then
        -- Ensure profile name is in the list
        local profiles = getProfiles()
        local found = false
        for _, v in pairs(profiles) do if v == name then found = true; break end end
        if not found then table.insert(profiles, name); saveProfiles(profiles) end
        if getgenv().Utils then
            getgenv().Utils:Notify("Saved", "Settings saved → RBHub/saves/"..name..".json", Color3.fromRGB(80,200,120))
        end
    else
        warn("[RB Hub] Save failed:", tostring(err))
    end
end

local function loadSettings(profileName)
    ensureDirs()
    local name = profileName or getgenv().currentSaveProfile or "default"
    local path = SAVES_DIR .. "/" .. name .. ".json"
    local ok, data = pcall(readfile, path)
    if ok and data and #data > 2 then
        local ok2, t = pcall(HttpService.JSONDecode, HttpService, data)
        if ok2 then
            applySettings(t)
            getgenv().currentSaveProfile = name
            return true
        end
    end
    return false
end

local function deleteProfile(profileName)
    local name = profileName or "default"
    pcall(delfile, SAVES_DIR .. "/" .. name .. ".json")
    local profiles = getProfiles()
    for i, v in pairs(profiles) do if v == name and name ~= "default" then table.remove(profiles, i); break end end
    saveProfiles(profiles)
end

-- try to auto-load on startup
getgenv().currentSaveProfile = "default"
task.defer(function()
    -- Slight delay so all features are registered first
    task.wait(0.5)
    local loaded = loadSettings("default")
    if loaded and getgenv().Utils then
        getgenv().Utils:Notify("Settings", "Auto-loaded: default profile", Color3.fromRGB(80,180,255))
    end
end)

getgenv().saveSettings   = saveSettings
getgenv().loadSettings   = loadSettings
getgenv().getProfiles    = getProfiles
getgenv().deleteProfile  = deleteProfile
