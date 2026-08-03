
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
---      Detect Framework
---]]
---@type REC_Library.Shared.Enums.Framework
config.framework = getConfigValue({
    { resource = "ox_core", value = "ox" },
    { resource = "qbx_core", value = "qbox" },
    { resource = "es_extended", value = "esx" },
    { resource = "qb-core", value = "qb" },
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
        qbox    = "QBCore:Client:OnPlayerLoaded",
        esx     = "esx:playerLoaded",
        qb      = "QBCore:Client:OnPlayerLoaded",
    },
    onPlayerLogOuted = {
        qbox    = "qbx_core:client:playerLoggedOut",
        esx     = "esx:playerLogout",
        qb      = "QBCore:Client:OnPlayerUnload",
    },
    onResourceStart = "onResourceStart",
    onResourceStop  = "onResourceStop"

}

return config