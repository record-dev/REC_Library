
---[[
---     Notifications
---]]

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@class REC_Library.Lib.Notify.Data
---@field id? string same id replaces the notification that is still on screen
---@field title? string
---@field description? string
---@field duration? integer ms, default 3000
---@field showDuration? boolean
---@field position? "top" | "top-right" | "top-left" | "bottom" | "bottom-right" | "bottom-left" | "center-right" | "center-left"
---@field type? "inform" | "info" | "success" | "warning" | "error"
---@field icon? string font awesome class
---@field iconColor? string
---@field sound? { bank?: string, set: string, name: string }

---@param data REC_Library.Lib.Notify.Data
function lib.notify(data)

    assert(type(data) == "table", "data must be a table")

    if data.sound ~= nil then

        if data.sound.bank ~= nil then
            lib.requestAudioBank(data.sound.bank)
        end

        PlaySoundFrontend(-1, data.sound.name, data.sound.set, true)

        if data.sound.bank ~= nil then
            ReleaseNamedScriptAudioBank(data.sound.bank)
        end
    end

    nui:send("notify", {
        id = data.id,
        title = data.title,
        description = data.description,
        duration = data.duration,
        showDuration = data.showDuration,
        position = data.position,
        type = data.type == "info" and "inform" or data.type,
        icon = data.icon,
        iconColor = data.iconColor,
    })
end

---[[
---     The game's own feed, for the places a NUI toast is too much
---]]
---@param data { title?: string, description?: string }
function lib.defaultNotify(data)

    assert(type(data) == "table", "data must be a table")

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(data.description or data.title or "")
    EndTextCommandThefeedPostTicker(false, true)
end

lib.showNotification = lib.notify

RegisterNetEvent("REC_Library:notify", lib.notify)
RegisterNetEvent("REC_Library:defaultNotify", lib.defaultNotify)

exports("notify", lib.notify)
exports("defaultNotify", lib.defaultNotify)
exports("showNotification", lib.notify)
