
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class._Core.TickManager
local TickManager = require "@REC_Library.client.class._core.cl_tickManager"

---@type REC_Library.Client.Class.Marker.Marker
local Marker = require "@REC_Library.client.class.marker.cl_marker"

---@class REC_Library.Client.Class.Marker.Managers.StaticMarkerManager
local StaticMarkerManager = {}
StaticMarkerManager.name = "StaticMarkerManager"
StaticMarkerManager.staticMarkersByResource = {}
StaticMarkerManager.nextId = 1

---Create new static markers and manage them with resources
---@param markerConfigBuilder REC_Library.Client.Class.Marker.MarkerConfigBuilder
---@return integer
function StaticMarkerManager:create(markerConfigBuilder)
    local ownerResource = GetCurrentResourceName()
    if not self.staticMarkersByResource[ownerResource] then
        self.staticMarkersByResource[ownerResource] = {}
    end

    local wasEmpty = not self:hasMarkers()

    local id = self.nextId
    local markerInstance = Marker:new(markerConfigBuilder)

    -- Store markers in a table for each resource
    self.staticMarkersByResource[ownerResource][id] = markerInstance
    self.nextId = self.nextId + 1

    if wasEmpty then
        TickManager:registerTick(self.name, function() self:update() end)
    end

    return id
end

---Remove static marker by ID
---@param id integer
function StaticMarkerManager:remove(id)
    -- Identify which resource the deletion request is from
    local ownerResource = GetCurrentResourceName()
    if self.staticMarkersByResource[ownerResource] and self.staticMarkersByResource[ownerResource][id] then
        self.staticMarkersByResource[ownerResource][id] = nil
    end
end

---Update process called every frame from TickManager
function StaticMarkerManager:update()
    if not self:hasMarkers() then
        TickManager:unregisterTick(self.name)
        return
    end

    for resourceName, markers in pairs(self.staticMarkersByResource) do
        for id, marker in pairs(markers) do
            marker:draw()
        end
    end
end

---Helper function to check if there is at least one marker being managed
---@return boolean
function StaticMarkerManager:hasMarkers()
    for resourceName, markers in pairs(self.staticMarkersByResource) do
        if next(markers) then
            return true
        end
    end
    return false
end

-- This onResourceStop handler now works properly now that the data structure is correct
AddEventHandler('onResourceStop', function(resourceName)
    if StaticMarkerManager.staticMarkersByResource[resourceName] then
        utils:debugPrint(('[%s] Resource "%s" stopped. Cleaning up static markers.'):format(StaticMarkerManager.name, resourceName))
        StaticMarkerManager.staticMarkersByResource[resourceName] = nil
    end
end)

return StaticMarkerManager
