
---[[
---     gauge (server)
---     Shows and drives a gauge on one client through the REC_Library NUI.
---]]

---@param playerId integer
---@param data REC_Library.Lib.Gauge.Data
function lib.showGauge(playerId, data)
    TriggerClientEvent("REC_Library:showGauge", playerId, data)
end

---@param playerId integer
---@param id string
---@param patch REC_Library.Lib.Gauge.Patch | number
function lib.updateGauge(playerId, id, patch)
    TriggerClientEvent("REC_Library:updateGauge", playerId, id, patch)
end

---@param playerId integer
---@param id? string
function lib.hideGauge(playerId, id)
    TriggerClientEvent("REC_Library:hideGauge", playerId, id)
end
