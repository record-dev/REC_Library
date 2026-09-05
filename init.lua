
---[[
---     REC_Library bootstrap
---     Every REC_* resource loads this first through shared_script '@REC_Library/init.lua'.
---     It gives the resource its own require, the lib table and the cache table, the
---     three things that used to come from ox_lib.
---]]

---@type string
local libraryName = "REC_Library"

---@type string
local resourceName = GetCurrentResourceName()

---@type boolean
local isServer = IsDuplicityVersion()

---@type "client" | "server"
local context = isServer and "server" or "client"

if GetResourceState(libraryName) == "missing" then
    error(("^1%s is missing, %s cannot start...^0"):format(libraryName, resourceName))
end



---[[
---     require
---     '@Resource.dir.file' reads another resource, 'dir.file' reads the resource the
---     calling file belongs to (ox_fuel's require 'config' keeps pointing at ox_fuel).
---     The chunk runs with this resource's globals, so a library class sees the lib
---     and cache tables of the resource that required it.
---]]
---@type table<string, any>
local loaded = {}

---@type table<string, boolean>
local loading = {}

---[[
---     The resource the file calling require belongs to, read from its chunk name
---     ('@REC_Utils/client/cl_api.lua' for a manifest script, '@@ox_fuel/client/fuel.lua' for a required one)
---]]
---@param level integer
---@return string
local function callerResource(level)

    local info = debug.getinfo(level, "S")
    if info == nil or type(info.source) ~= "string" then
        return resourceName
    end

    return info.source:match("^@@?([^/]+)/") or resourceName
end

---@param modName string
---@param caller string
---@return string resource
---@return string path
local function resolveModule(modName, caller)

    local resource, path = modName:match("^@([^%.]+)%.(.+)$")
    if resource == nil then
        resource, path = caller, modName
    end

    return resource, (path:gsub("%.", "/"))
end

---@param modName string
---@param resource string
---@param path string
---@return function|nil chunk
---@return string|nil err
local function loadModule(modName, resource, path)

    for _, file in ipairs({ path .. ".lua", path .. "/init.lua", }) do

        local source = LoadResourceFile(resource, file)
        if source ~= nil then

            local chunk, err = load(source, ("@@%s/%s"):format(resource, file), "t", _ENV)
            if chunk == nil then
                return nil, ("failed to load module '%s'\n%s"):format(modName, err)
            end

            return chunk
        end
    end

    return nil, ("module '%s' not found (%s/%s.lua)"):format(modName, resource, path)
end

---@param modName string
---@return any
function require(modName)

    assert(type(modName) == "string", ("module name must be a string (received %s)"):format(type(modName)))

    local resource, path = resolveModule(modName, callerResource(3))
    local key = ("%s/%s"):format(resource, path)

    local module = loaded[key]
    if module ~= nil then
        return module
    end

    if loading[key] == true then
        error(("circular require of module '%s'"):format(modName), 2)
    end

    local chunk, err = loadModule(modName, resource, path)
    if chunk == nil then
        error(err, 2)
    end

    -- the flag must go even when the chunk throws, or every later require reports a loop
    loading[key] = true
    local ok, result = pcall(chunk, modName)
    loading[key] = nil

    if ok == false then
        error(result, 0)
    end

    -- a module without a return still counts as loaded
    if result == nil then
        result = true
    end

    loaded[key] = result

    return result
end



---[[
---     lib
---     Keys resolve lazily. A key listed in moduleIndex runs REC_Library/lib/<module>/
---     {sh,cl,sv}_<module>.lua inside this resource, a key listed in uiExports is a
---     proxy to the export the REC_Library resource registers for its NUI.
---]]
---@type table<string, string>
local moduleIndex = {
    callback = "callback",
    addCommand = "command",
    addKeybind = "keybind",
    onCache = "cache",
    zones = "zones",
    table = "table",
    getFilesInDirectory = "files",

    requestModel = "streaming",
    requestAnimDict = "streaming",
    requestAnimSet = "streaming",
    requestNamedPtfxAsset = "streaming",
    requestAudioBank = "streaming",
    requestScaleformMovie = "streaming",
    requestWeaponAsset = "streaming",
    requestStreamedTextureDict = "streaming",

    getNearbyPlayers = "entities",
    getClosestPlayer = "entities",
    getNearbyObjects = "entities",
    getClosestObject = "entities",
    getNearbyVehicles = "entities",
    getClosestVehicle = "entities",
    getNearbyPeds = "entities",
    getClosestPed = "entities",

    getVehicleProperties = "vehicleProperties",
    setVehicleProperties = "vehicleProperties",

    notify = "notify", -- server only, the client resolves it through uiExports

    points = "points",

    checkDependency = "common",
    print = "common",
    waitFor = "common",
    timer = "common",
    string = "common",
    math = "common",
    getRelativeCoords = "common",
    load = "common",
    loadJson = "common",
    locale = "common",
    getLocale = "common",
    disableControls = "common",
    playAnim = "common",
    raycast = "common",
    marker = "common",
}

---@type table<string, boolean>
local uiExports = {
    notify = true,
    defaultNotify = true,
    showNotification = true,
    alertDialog = true,
    inputDialog = true,
    closeInputDialog = true,
    registerContext = true,
    showContext = true,
    hideContext = true,
    getOpenContextMenu = true,
    progressBar = true,
    progressCircle = true,
    progressActive = true,
    cancelProgress = true,
    showTextUI = true,
    hideTextUI = true,
    isTextUIOpen = true,
    setClipboard = true,
}

---@type table<string, boolean>
local loadedModules = {}

---@param module string
local function loadLibModule(module)

    if loadedModules[module] == true then
        return
    end

    loadedModules[module] = true

    for _, prefix in ipairs({ "sh", context == "server" and "sv" or "cl", }) do

        local file = ("lib/%s/%s_%s.lua"):format(module, prefix, module)
        local source = LoadResourceFile(libraryName, file)
        if source ~= nil then

            local chunk, err = load(source, ("@@%s/%s"):format(libraryName, file), "t", _ENV)
            if chunk == nil then
                error(("failed to load lib module '%s'\n%s"):format(module, err))
            end

            chunk()
        end
    end
end

---@class REC_Library.Lib
---@field name string the resource this lib table belongs to
---@field context "client" | "server"
---@field library string
lib = setmetatable({
    name = resourceName,
    context = context,
    library = libraryName,
}, {
    __index = function (self, key)

        if context == "client" and uiExports[key] == true then

            local function proxy(...)
                return exports[libraryName][key](nil, ...)
            end

            rawset(self, key, proxy)
            return proxy
        end

        local module = moduleIndex[key]
        if module ~= nil then
            loadLibModule(module)
            return rawget(self, key)
        end

        return nil
    end,
})



---[[
---     cache / common
---     Loaded eagerly, cache.ped and the global locale() must be there before any
---     script body runs.
---]]
loadLibModule("cache")
loadLibModule("common")
