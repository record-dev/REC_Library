
---[[
---     notify (server)
---     Shows a notification on one client through the REC_Library NUI.
---]]

---@param playerId integer
---@param data REC_Library.Lib.Notify.Data
function lib.notify(playerId, data)
    TriggerClientEvent("REC_Library:notify", playerId, data)
end

---@param playerId integer
---@param data REC_Library.Lib.Notify.Data
function lib.defaultNotify(playerId, data)
    TriggerClientEvent("REC_Library:defaultNotify", playerId, data)
end
