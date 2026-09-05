
---[[
---     subtitle (server)
---     Shows a subtitle on one client through the REC_Library NUI.
---]]

---@param playerId integer
---@param data REC_Library.Lib.Subtitle.Data
function lib.showSubtitle(playerId, data)
    TriggerClientEvent("REC_Library:showSubtitle", playerId, data)
end

---@param playerId integer
---@param id? string
function lib.hideSubtitle(playerId, id)
    TriggerClientEvent("REC_Library:hideSubtitle", playerId, id)
end
