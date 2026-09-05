
---[[
---     helpText (server)
---     Shows a help text on one client through the REC_Library NUI.
---]]

---@param playerId integer
---@param data REC_Library.Lib.HelpText.Data
function lib.showHelpText(playerId, data)
    TriggerClientEvent("REC_Library:showHelpText", playerId, data)
end

---@param playerId integer
---@param id? string
function lib.hideHelpText(playerId, id)
    TriggerClientEvent("REC_Library:hideHelpText", playerId, id)
end
