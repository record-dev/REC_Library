
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"


---@type REC_Library.Shared.Config
local sh_config = require "@REC_Library.shared.sh_config"

---@class REC_Library.Client.Class.Handler.HandlerBuilder
---@field session REC_Library.Client.Class.Manager.SessionManager
local HandlerBuilder = {}
HandlerBuilder.__index = HandlerBuilder

---instantiation
---@return self
function HandlerBuilder:new()
    local instance = setmetatable({}, self)
    return instance
end

---When spawning in the world
---@param onPlayerLoaded fun(...)
---@return self chain method
function HandlerBuilder:setOnPlayerLoaded(onPlayerLoaded)

    local eventName = sh_config.events.onPlayerLoaded[sh_config.framework]

    if eventName and type(onPlayerLoaded) == "function" then
        -- Register a handler with the obtained event name
        AddEventHandler(eventName, function (...)
            onPlayerLoaded(self.session, ...)
        end)
    else
        -- Error output when the framework is not supported or the event name is undefined
        utils:debugPrint(('[REC_Library] Error: Framework "%s" is not supported for the "playerLoaded" event.'):format(sh_config.framework))
    end

    return self
end

---When you log out of the server
---@param onPlayerLogOuted fun(...)
---@return self chain method
function HandlerBuilder:setOnPlayerLoggedOut(onPlayerLogOuted)

    local eventName = sh_config.events.onPlayerLogOuted[sh_config.framework]

    if eventName and type(onPlayerLogOuted) == "function" then
        -- Register a handler with the obtained event name
        RegisterNetEvent(eventName, function (...)
            onPlayerLogOuted(self.session, ...)
        end)
    else
        -- Error output when the framework is not supported or the event name is undefined
        utils:debugPrint(('[REC_Library] Error: Framework "%s" is not supported for the "playerlogouted" event.'):format(sh_config.framework))
    end

    return self
end

---When the resource is started
---@param onResourceStart fun(resourceName: string, ...)
---@return self chain method
function HandlerBuilder:setOnResourceStart(onResourceStart)

    local eventName = sh_config.events.onResourceStart

    if eventName and type(onResourceStart) == "function" then
        -- Register a handler with the obtained event name
        AddEventHandler(eventName, function (...)
            onResourceStart(...)
        end)
    else
        utils:debugPrint("[REC_Library] Error: The 'onResourceStart' event is not defined or the handler is not a function.")
    end

    return self
end

---When resources stop
---@param onResourceStop fun(resourceName: string, ...)
---@return self chain method
function HandlerBuilder:setOnResourceStop(onResourceStop)

    local eventName = sh_config.events.onResourceStop

    if eventName and type(onResourceStop) == "function" then
        -- Register a handler with the obtained event name
        AddEventHandler(eventName, function (...)
            onResourceStop(...)
        end)
    else
        utils:debugPrint("[REC_Library] Error: The 'onResourceStop' event is not defined or the handler is not a function.")
    end

    return self
end

return HandlerBuilder
