local HttpService = game:GetService("HttpService")

local SAVE_DIR      = "RBHub"
local SAVES_DIR     = "RBHub/saves"
local PROFILES_FILE = "RBHub/profiles.json"

local function ensureDirs()
    pcall(makefolder, SAVE_DIR)
    pcall(makefolder, SAVES_DIR)
end

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

-- Waypoints store live CFrame userdata, which HttpService:JSONEncode cannot
-- encode (it errors on any userdata). Convert to/from a plain component array
-- so saving settings never throws once a waypoint has been added.
local function serializeWaypoints(list)
    local out = {}
    if type(list) ~= "table" then return out end
    for _, wp in ipairs(list) do
        if type(wp) == "table" and typeof(wp.cf) == "CFrame" then
            out[#out + 1] = { name = wp.name, cf = {wp.cf:GetComponents()} }
        end
    end
    return out
end

local function deserializeWaypoints(list)
    local out = {}
    if type(list) ~= "table" then return out end
    for _, wp in ipairs(list) do
        if type(wp) == "table" and type(wp.cf) == "table" and #wp.cf == 12 then
            out[#out + 1] = { name = wp.name, cf = CFrame.new(table.unpack(wp.cf)) }
        end
    end
    return out
end

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
        espShowNames        = getgenv().espShowNames,
        espShowDistance     = getgenv().espShowDistance,
        espShowBoxes        = getgenv().espShowBoxes,
        espUse2DBoxes       = getgenv().espUse2DBoxes,
        espShowTracers      = getgenv().espShowTracers,
        espShowSkeleton     = getgenv().espShowSkeleton,
        espShowHealthBars   = getgenv().espShowHealthBars,
        clickCheckEnabled   = getgenv().clickCheckEnabled,
        deathCheckEnabled   = getgenv().deathCheckEnabled,
        autoSwitchEnabled   = getgenv().autoSwitchEnabled,
        noclipDensity       = getgenv().noclipDensity,
        savedWaypoints      = serializeWaypoints(getgenv().savedWaypoints),
        followUsePathfinding= getgenv().followUsePathfinding,
        noclipPreset        = getgenv().noclipPreset,
        freeCamCollision    = getgenv().freeCamCollision,
        flightSoftMode      = getgenv().flightSoftMode,
        noDamageFallPatterns= getgenv().noDamageFallPatterns,
    }
    return HttpService:JSONEncode(t)
end

local function restoreFeatureStates()
    if getgenv().speedhackEnabled then
        if getgenv().enableSpeedhack then pcall(getgenv().enableSpeedhack) end
    elseif getgenv().disableSpeedhack then
        pcall(getgenv().disableSpeedhack)
    end
    if getgenv().flightEnabled then
        if getgenv().enableFlight then pcall(getgenv().enableFlight) end
    elseif getgenv().disableFlight then
        pcall(getgenv().disableFlight)
    end
    if getgenv().noclipEnabled then
        if getgenv().setNoclipEnabled then
            pcall(getgenv().setNoclipEnabled, true)
        elseif getgenv().enableNoclip then
            pcall(getgenv().enableNoclip)
        end
    elseif getgenv().disableNoclip then
        pcall(getgenv().disableNoclip)
    end
    if getgenv().infiniteJumpEnabled then
        if getgenv().applyInfiniteJump then pcall(getgenv().applyInfiniteJump) end
    elseif getgenv().disableInfiniteJump then
        pcall(getgenv().disableInfiniteJump)
    end
    if getgenv().wallhackEnabled then
        if getgenv().enableWallhack then pcall(getgenv().enableWallhack) end
    elseif getgenv().disableWallhack then
        pcall(getgenv().disableWallhack)
    end
    if getgenv().fullbrightEnabled then
        if getgenv().enableFullbright then pcall(getgenv().enableFullbright) end
    elseif getgenv().disableFullbright then
        pcall(getgenv().disableFullbright)
    end
    if getgenv().fovChangerEnabled then
        pcall(function() workspace.CurrentCamera.FieldOfView = getgenv().currentFOV or 70 end)
    elseif getgenv().disableFOVChanger then
        pcall(getgenv().disableFOVChanger)
    end
    if getgenv().reachEnabled then
        if getgenv().enableReach then pcall(getgenv().enableReach) end
    elseif getgenv().disableReach then
        pcall(getgenv().disableReach)
    end
    if getgenv().hitboxEnabled then
        if getgenv().applyHitboxExpansion then pcall(getgenv().applyHitboxExpansion) end
    elseif getgenv().removeHitboxExpansion then
        pcall(getgenv().removeHitboxExpansion)
    end
    if getgenv().lowGravityEnabled then
        if getgenv().applyLowGravity then pcall(getgenv().applyLowGravity) end
    elseif getgenv().disableLowGravity then
        pcall(getgenv().disableLowGravity)
    end
    if getgenv().noDamageEnabled then
        if getgenv().enableNoDamage then pcall(getgenv().enableNoDamage) end
    elseif getgenv().disableNoDamage then
        pcall(getgenv().disableNoDamage)
    end
end

local function applySettings(t)
    if type(t) ~= "table" then return end
    local function apply(k, v)
        if v ~= nil then getgenv()[k] = v end
    end
    apply("flightEnabled",        t.flightEnabled)
    apply("wallhackEnabled",      t.wallhackEnabled)
    apply("espEnabled",           t.espEnabled)
    apply("speedhackEnabled",     t.speedhackEnabled)
    apply("noclipEnabled",        t.noclipEnabled)
    apply("infiniteJumpEnabled",  t.infiniteJumpEnabled)
    apply("fullbrightEnabled",    t.fullbrightEnabled)
    apply("fovChangerEnabled",    t.fovChangerEnabled)
    apply("noDamageEnabled",      t.noDamageEnabled)
    apply("reachEnabled",         t.reachEnabled)
    apply("hitboxEnabled",        t.hitboxEnabled)
    apply("lowGravityEnabled",    t.lowGravityEnabled)
    apply("speedMultiplier",      t.speedMultiplier)
    apply("currentFOV",           t.currentFOV)
    apply("followDistance",       t.followDistance)
    apply("followHeight",         t.followHeight)
    apply("reachDistance",        t.reachDistance)
    apply("hitboxSize",           t.hitboxSize)
    apply("flightSpeed",          t.flightSpeed and math.clamp(t.flightSpeed, 10, 1500) or nil)
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
    apply("noclipDensity",        t.noclipDensity)
    apply("followUsePathfinding", t.followUsePathfinding)
    apply("noclipPreset",         t.noclipPreset)
    apply("freeCamCollision",     t.freeCamCollision)
    apply("flightSoftMode",       t.flightSoftMode)
    if type(t.savedWaypoints) == "table" then
        getgenv().savedWaypoints = deserializeWaypoints(t.savedWaypoints)
        if getgenv().renderWaypoints then pcall(getgenv().renderWaypoints) end
    end
    if type(t.noDamageFallPatterns) == "table" and #t.noDamageFallPatterns > 0 then
        getgenv().noDamageFallPatterns = t.noDamageFallPatterns
        if getgenv().refreshNoDamagePatternsBox then pcall(getgenv().refreshNoDamagePatternsBox) end
    end
    if getgenv().refreshNoclipPresetButton then pcall(getgenv().refreshNoclipPresetButton) end
    restoreFeatureStates()
    if getgenv().RefreshUIState then
        getgenv().RefreshUIState()
    end
end

local function saveSettings(profileName)
    ensureDirs()
    local name = profileName or getgenv().currentSaveProfile or "default"
    getgenv().currentSaveProfile = name
    local path = SAVES_DIR .. "/" .. name .. ".json"
    local json = serializeSettings()
    local ok, err = pcall(writefile, path, json)
    if ok then
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

getgenv().currentSaveProfile = "default"
task.defer(function()
    task.wait(0.5)
    local loaded = loadSettings("default")
    if loaded and getgenv().Utils then
        getgenv().Utils:Notify("Settings", "Auto-loaded: default profile", Color3.fromRGB(80,180,255))
    end
end)

-- Export/import lets a config be shared between devices/executors without
-- touching the filesystem: copy the serialized JSON to the clipboard, or
-- read it back from the clipboard and apply it in place.
local function exportConfig()
    local json = serializeSettings()
    if not setclipboard then
        if getgenv().Utils then getgenv().Utils:Notify("Export", "setclipboard unavailable on this executor.", Color3.fromRGB(220, 60, 60)) end
        return false
    end
    local ok = pcall(setclipboard, json)
    if ok then
        if getgenv().Utils then getgenv().Utils:Notify("Export", "Config copied to clipboard.", Color3.fromRGB(80, 200, 120)) end
        return true
    end
    if getgenv().Utils then getgenv().Utils:Notify("Export", "Failed to write to clipboard.", Color3.fromRGB(220, 60, 60)) end
    return false
end

local function importConfig(jsonText)
    if type(jsonText) ~= "string" or jsonText == "" then
        if getgenv().Utils then getgenv().Utils:Notify("Import", "Clipboard is empty.", Color3.fromRGB(220, 60, 60)) end
        return false
    end
    local ok, t = pcall(HttpService.JSONDecode, HttpService, jsonText)
    if not ok or type(t) ~= "table" then
        if getgenv().Utils then getgenv().Utils:Notify("Import", "Clipboard does not contain a valid config.", Color3.fromRGB(220, 60, 60)) end
        return false
    end
    applySettings(t)
    if getgenv().Utils then getgenv().Utils:Notify("Import", "Config imported from clipboard.", Color3.fromRGB(80, 200, 120)) end
    return true
end

local function importConfigFromClipboard()
    if not getclipboard then
        if getgenv().Utils then getgenv().Utils:Notify("Import", "getclipboard unavailable on this executor.", Color3.fromRGB(220, 60, 60)) end
        return false
    end
    local ok, text = pcall(getclipboard)
    if not ok then
        if getgenv().Utils then getgenv().Utils:Notify("Import", "Failed to read clipboard.", Color3.fromRGB(220, 60, 60)) end
        return false
    end
    return importConfig(text)
end

getgenv().exportConfig            = exportConfig
getgenv().importConfig            = importConfig
getgenv().importConfigFromClipboard = importConfigFromClipboard

getgenv().saveSettings   = saveSettings
getgenv().loadSettings   = loadSettings
getgenv().getProfiles    = getProfiles
getgenv().deleteProfile  = deleteProfile
