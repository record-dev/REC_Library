
---[[
---     notify (server)
---     The toast lives in REC_Notify, lib.notify keeps the ox_lib shape so callers do not change.
---]]

---@type string
local notifyResource = "REC_Notify"

---@return boolean
local function hasNotify()

    if GetResourceState(notifyResource) == "started" then
        return true
    end

    print(("^3[%s] %s is not started, notify is dropped...^0"):format(lib.name, notifyResource))

    return false
end

---@param playerId integer|integer[] -1 for everyone
---@param data REC_Library.Lib.Notify.Data
---@return boolean
function lib.notify(playerId, data)

    if hasNotify() == false then
        return false
    end

    return exports[notifyResource]:notify(playerId, data)
end

---@param playerId integer|integer[] -1 for everyone
---@param data { title?: string, description?: string }
---@return boolean
function lib.defaultNotify(playerId, data)

    if hasNotify() == false then
        return false
    end

    return exports[notifyResource]:defaultNotify(playerId, data)
end

lib.showNotification = lib.notify
