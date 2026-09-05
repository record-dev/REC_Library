
---[[
---     notify (client)
---     The toast lives in REC_Notify, lib.notify keeps the ox_lib shape so callers do not change.
---     Without REC_Notify the message goes to the game's own feed instead of vanishing.
---]]

---@type string
local notifyResource = "REC_Notify"

---@class REC_Library.Lib.Notify.Data
---@field id? string same id replaces the notification that is still on screen
---@field title? string
---@field description? string
---@field duration? integer ms, default config.ui.defaultDuration of REC_Notify
---@field showDuration? boolean remaining time bar
---@field position? "top" | "top-right" | "top-left" | "bottom" | "bottom-right" | "bottom-left" | "center-right" | "center-left"
---@field type? "inform" | "info" | "success" | "warning" | "error" | "neutral"
---@field icon? string font awesome class
---@field iconColor? string
---@field color? string same as iconColor
---@field playSound? boolean
---@field sound? string | { bank?: string, set: string, name: string } audio file of REC_Notify, or a GTA sound played instead of the type sound

---@return boolean
local function hasNotify()
    return GetResourceState(notifyResource) == "started"
end

---[[
---     The game's own feed, for the places a NUI toast is too much
---]]
---@param data { title?: string, description?: string }
---@return boolean
function lib.defaultNotify(data)

    assert(type(data) == "table", "data must be a table")

    local message = data.description or data.title
    if type(message) ~= "string" then
        return false
    end

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)

    return true
end

---@param data REC_Library.Lib.Notify.Data
---@return string|nil id
function lib.notify(data)

    assert(type(data) == "table", "data must be a table")

    if hasNotify() == false then
        print(("^3[%s] %s is not started, notify falls back to the game feed...^0"):format(lib.name, notifyResource))
        lib.defaultNotify(data)
        return nil
    end

    return exports[notifyResource]:notify(data)
end

lib.showNotification = lib.notify
