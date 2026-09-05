
---[[
--
--                       ________ __________      ________________ ________ ________                
--                       ___  __ \___  ____/_____ __  ____/__  __ \___  __ \___  __ \               
--        ________       __  /_/ /__  __/   ___(_)_  /     _  / / /__  /_/ /__  / / /       ________
--        _/_____/       _  _, _/ _  /___   ___   / /___   / /_/ / _  _, _/ _  /_/ /        _/_____/
--                       /_/ |_|  /_____/   _(_)  \____/   \____/  /_/ |_|  /_____/                 
--                                                                                                  
---]]


---[[
---      This function is used to determine the configuration value based on the state of various resources.
---]]
---@param resourceChecks { resource: string, value: any }[]
---@return any
local function getConfigValue(resourceChecks)
    for _, check in ipairs(resourceChecks) do
        local status, result = pcall(GetResourceState, check.resource)
        if status and result == 'started' then
            return check.value
        elseif not status then
            print(('^6[REC_Library] Error calling GetResourceState for resource "%s": %s^0'):format(check.resource, tostring(result)))
        end
    end
    return "custom"
end

---@class REC_Library.Shared.Config
local config = {}

---@type boolean
config.debugMode = true

---[[
---     language settings.
---     'en' or 'ja' or 'custom'
---]]
---@type REC_Library.Shared.Enums.Languages 
config.language = "ja"

---[[
---     NUI theme.
---     "rec" is the RE:CORD look, "ox" reproduces the classic ox_lib look
---]]
---@type REC_Library.Shared.Enums.Theme
config.theme = "rec"

---[[
---     Per theme options. "ox" reads the same convars ox_lib did, so a server.cfg
---     that already sets ox:primaryColor keeps its colour
---]]
---@type REC_Library.Shared.Config.ThemeOptions
config.themeOptions = {
    ox = {
        primaryColor = GetConvar("ox:primaryColor", "blue"),
        primaryShade = GetConvarInt("ox:primaryShade", 8),
    },
}

---[[
---     Layout of the HUD text the NUI draws (lib.showHelpText / lib.showSubtitle)
---]]
config.ui = {

    ---[[
    ---     Help text (control hint), the NUI version of the GTA help text
    ---]]
    helpText = {

        ---[[
        ---     Default position (each help text can override it with data.position)
        ---]]
        ---@type REC_Library.Shared.Enums.HelpTextPosition
        position = "top-left",
        offset = {
            ---@type string
            x = "1.6vw",
            ---@type string
            y = "3vh",
        },

        ---[[
        ---     Widest the card can get (CSS units)
        ---]]
        ---@type string
        maxWidth = "380px",

        ---[[
        ---     Colour of the icon and the keycaps when the caller omits color
        ---]]
        ---@type string
        color = "#e2e8f0",

        ---[[
        ---     Font size multiplier (1.0 is the default)
        ---]]
        ---@type number
        fontScale = 1.0,

        ---[[
        ---     Enter and exit animation time
        ---]]
        ---@type integer
        animationDuration = 200, -- ms

        ---[[
        ---     Key drawn for a GTA control token in the text ("~INPUT_CONTEXT~" becomes the [E] keycap)
        ---     a token missing here is drawn with its control name
        ---]]
        ---@type table<string, string>
        inputKeys = {
            INPUT_CONTEXT          = "E",
            INPUT_PICKUP           = "E",
            INPUT_TALK             = "E",
            INPUT_VEH_HORN         = "E",
            INPUT_ENTER            = "F",
            INPUT_VEH_EXIT         = "F",
            INPUT_DETONATE         = "G",
            INPUT_COVER            = "Q",
            INPUT_RELOAD           = "R",
            INPUT_MULTIPLAYER_INFO = "Z",
            INPUT_INTERACTION_MENU = "M",
            INPUT_SPRINT           = "SHIFT",
            INPUT_JUMP             = "SPACE",
            INPUT_DUCK             = "CTRL",
            INPUT_ATTACK           = "LMB",
            INPUT_AIM              = "RMB",
            INPUT_FRONTEND_ACCEPT  = "ENTER",
            INPUT_FRONTEND_CANCEL  = "ESC",
            INPUT_FRONTEND_RRIGHT  = "BACKSPACE",
            INPUT_FRONTEND_X       = "SPACE",
            INPUT_FRONTEND_UP      = "\u{2191}",
            INPUT_FRONTEND_DOWN    = "\u{2193}",
            INPUT_FRONTEND_LEFT    = "\u{2190}",
            INPUT_FRONTEND_RIGHT   = "\u{2192}",
            INPUT_CELLPHONE_UP     = "\u{2191}",
            INPUT_CELLPHONE_DOWN   = "\u{2193}",
            INPUT_CELLPHONE_LEFT   = "\u{2190}",
            INPUT_CELLPHONE_RIGHT  = "\u{2192}",
        },
    },

    ---[[
    ---     Subtitle (objective text at the bottom of the screen), the NUI version of the GTA subtitle
    ---]]
    subtitle = {

        ---[[
        ---     Distance from the bottom of the screen and the widest the text can get (CSS units)
        ---]]
        offset = {
            ---@type string
            y = "9vh",
        },
        ---@type string
        maxWidth = "60vw",

        ---[[
        ---     Draw a translucent box behind the text
        ---]]
        ---@type boolean
        background = true,

        ---[[
        ---     Colour of the speaker name when the caller omits color
        ---]]
        ---@type string
        color = "#fbbf24",

        ---[[
        ---     Font size multiplier (1.0 is the default)
        ---]]
        ---@type number
        fontScale = 1.0,

        ---[[
        ---     Display time used when duration is omitted (0 in the data keeps it until lib.hideSubtitle)
        ---]]
        ---@type integer
        defaultDuration = 5000, -- ms

        ---[[
        ---     Enter and exit animation time
        ---]]
        ---@type integer
        animationDuration = 200, -- ms
    },
}

---[[
---      Detect Framework
---]]
---@type REC_Library.Shared.Enums.Framework
config.framework = getConfigValue({
    { resource = "ox_core", value = "ox" },
    { resource = "qbx_core", value = "qbx" },
    { resource = "es_extended", value = "esx" },
    { resource = "qb-core", value = "qb" },
    -- last on purpose: REC_Core stays dormant next to another core, so that core wins
    { resource = "REC_Core", value = "rec" },
})


---[[
---      Detect Inventory
---]]
---@type REC_Library.Shared.Enums.Inventory
config.inventory = getConfigValue({
    { resource = "ox_inventory", value = "ox" },
    { resource = "qb-inventory", value = "qb" },
})

---[[
---      Detect Bank
---]]
---@type REC_Library.Shared.Enums.Bank
config.bank = getConfigValue({
    { resource = "okokBanking", value = "okok" },
    { resource = "tgg-banking", value = "tgg" },
    { resource = "Renewed-Banking", value = "renewed" },
    { resource = "qb-banking", value = "qb" },
    { resource = "esx_society", value = "esx" },
})

---[[
---      Detect Medicals
---]]
---@type REC_Library.Shared.Enums.Medicals
config.medical = getConfigValue({
    { resource = "qb-ambulancejob", value = "qb" },
    { resource = "qbx_medical", value = "qbx" },
    { resource = "wasabi_ambulance", value = "wsb_v1" },
    { resource = "wasabi_ambulance_v2", value = "wsb_v2" },
})

---[[
---      Detect Target
---]]
---@type REC_Library.Shared.Enums.Target
config.target = getConfigValue({
    { resource = "ox_target", value = "ox" },
    { resource = "qb-target", value = "qb" },
})

---[[
---      Detect Doors
---]]
---@type REC_Library.Shared.Enums.Doors
config.door = getConfigValue({
    { resource = "qb-doorlock", value = "qb" },
    { resource = "ox_doorlock", value = "ox" },
})

---[[
---      Detect Vehicleyfuel
---]]
---@type REC_Library.Shared.Enums.Vehiclefuel
config.vehiclefuel = getConfigValue({
    { resource = "ox_fuel", value = "ox" },
    { resource = "qb-fuel", value = "qb" },
    { resource = "lc_fuel", value = "lc" },
    { resource = "cdn-fuel", value = "cdn" },
})

---[[
---      Detect Vehiclekeys
---]]
---@type REC_Library.Shared.Enums.Vehiclekeys
config.vehiclekeys = getConfigValue({
    { resource = "qb-vehiclekeys", value = "qb" },
    { resource = "qbx_vehiclekeys", value = "qbx" },
    { resource = "wasabi_carlock", value = "wsb" },
})

---[[
---      Detect Dispatch
---]]
---@type REC_Library.Shared.Enums.Dispatch
config.dispatch = getConfigValue({
    { resource = "lb-tablet", value = "lb-tablet" },
    { resource = "ps-dispatch", value = "ps-dispatch" },
})

---[[
---      Detect Notify
---]]
---@type REC_Library.Shared.Enums.Notify
config.notify = getConfigValue({
    { resource = "REC_Notify", value = "rec" },
    { resource = "okokNotify", value = "okok" },
    { resource = "ox_lib", value = "ox" },
})


---[[
---      You can freely change the resource names. Adjust as needed.
---]]
---@type table
config.resources = {
    target = {
        ox_target = "ox_target",
        qb_target = "qb-target",
    },
}

---[[
---      You can freely change the events names. Adjust as needed.
---]]
config.events = {
    onPlayerLoaded = {
        qbx    = "QBCore:Client:OnPlayerLoaded",
        esx     = "esx:playerLoaded",
        qb      = "QBCore:Client:OnPlayerLoaded",
        rec     = "REC_Core:client:onPlayerLoaded",
    },
    onPlayerLogOuted = {
        qbx    = "qbx_core:client:playerLoggedOut",
        esx     = "esx:playerLogout",
        qb      = "QBCore:Client:OnPlayerUnload",
        rec     = "REC_Core:client:onPlayerUnloaded",
    },
    onResourceStart = "onResourceStart",
    onResourceStop  = "onResourceStop"

}

return config

---@class REC_Library.Shared.Config.ThemeOptions
---@field ox { primaryColor: string, primaryShade: integer }
