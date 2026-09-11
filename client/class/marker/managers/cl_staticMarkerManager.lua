
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class._Core.TickManager
local TickManager = require "@REC_Library.client.class._core.cl_tickManager"

---@type REC_Library.Client.Class.Marker.Marker
local Marker = require "@REC_Library.client.class.marker.cl_marker"

---@class REC_Library.Client.Class.Marker.Managers.StaticMarkerManager
---@field markers table<integer, REC_Library.Client.Class.Marker.Marker>
---@field count integer
local StaticMarkerManager = {}
StaticMarkerManager.name = "StaticMarkerManager"
StaticMarkerManager.markers = {}
StaticMarkerManager.count = 0
StaticMarkerManager.nextId = 1

---Create new static markers and manage them
---@param markerConfigBuilder REC_Library.Client.Class.Marker.MarkerConfigBuilder
---@return integer
function StaticMarkerManager:create(markerConfigBuilder)

    local id = self.nextId
    self.nextId = id + 1

    self.markers[id] = Marker:new(markerConfigBuilder)
    self.count += 1

    -- the first marker opens the shared tick, the last one closes it again
    if self.count == 1 then
        TickManager:registerTick(self.name, function () self:update() end)
    end

    return id
end

---Remove static marker by ID
---@param id integer
function StaticMarkerManager:remove(id)

    if self.markers[id] == nil then
        utils:debugPrint(("^3[StaticMarkerManager:remove] marker is not founded... id: %s^0"):format(tostring(id)))
        return
    end

    self.markers[id] = nil
    self.count -= 1

    if self.count <= 0 then
        self.count = 0
        TickManager:unregisterTick(self.name)
    end
end

---Update process called every frame from TickManager
function StaticMarkerManager:update()

    local coords = cache.coords

    for _, marker in pairs(self.markers) do

        local info = marker.info
        if #(coords - info.coords) <= (info.drawDistance or 150.0) then
            marker:draw()
        end
    end
end

---Helper function to check if there is at least one marker being managed
---@return boolean
function StaticMarkerManager:hasMarkers()
    return self.count > 0
end

return StaticMarkerManager
