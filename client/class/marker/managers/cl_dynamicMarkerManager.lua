
---@type REC_Library.Client.Class._Core.TickManager
local TickManager = require "@REC_Library.client.class._core.cl_tickManager"

---@class REC_Library.Client.Class.Marker.Managers.DynamicMarkerManager
local DynamicMarkerManager = {}
DynamicMarkerManager.name = "DynamicMarkerManager"
DynamicMarkerManager.boundItemsByResource = {}
DynamicMarkerManager.nextId = 1

---Connect drawable objects to entities and start managing them as dynamic markers
---@param renderable table rendering object. Must have `.drawAt(position)` method.
---@param target integer Tracked entity handle
---@param offset? vector3 Offset from entity coordinates (optional)
---@return integer ID used for unbind
function DynamicMarkerManager:bind(renderable, target, offset)
    local ownerResource = GetCurrentResourceName()
    if not self.boundItemsByResource[ownerResource] then
        self.boundItemsByResource[ownerResource] = {}
    end

    local needsToRegister = not self:hasBoundItems()
    local id = self.nextId
    self.boundItemsByResource[ownerResource][id] = {
        renderable = renderable,
        target = target,
        offset = offset or vector3(0.0, 0.0, 0.0)
    }
    self.nextId = self.nextId + 1

    if needsToRegister then
        TickManager:register(self.name, function() self:update() end)
    end

    return id
end

---Untrack dynamic markers
---@param id integer ID returned by the bind function
function DynamicMarkerManager:unbind(id)
    local ownerResource = GetCurrentResourceName()
    if self.boundItemsByResource[ownerResource] and self.boundItemsByResource[ownerResource][id] then
        self.boundItemsByResource[ownerResource][id] = nil
    end
end

---Update process called every frame from TickManager
function DynamicMarkerManager:update()

    -- When there are no more management targets, unregister yourself from TickManager and stop the loop
    if not self:hasBoundItems() then
        TickManager:unregisterTick(self.name)
        return
    end

    for resourceName, items in pairs(self.boundItemsByResource) do
        for id, item in pairs(items) do
            if DoesEntityExist(item.target) then
                local entityPos = GetEntityCoords(item.target)
                local drawPos = entityPos + item.offset
                item.renderable:drawAt(drawPos)
            else
                items[id] = nil
            end
        end
    end
end

---Helper function to check whether the table to be drawn is empty
---@return boolean
function DynamicMarkerManager:hasBoundItems()
    for resourceName, items in pairs(self.boundItemsByResource) do
        if next(items) then return true end
    end
    return false
end

-- Detect that a resource has stopped, and if there is a resource name that has registered a drawing target, invalidate it
AddEventHandler('onResourceStop', function(resourceName)
    if DynamicMarkerManager.boundItemsByResource[resourceName] then
        DynamicMarkerManager.boundItemsByResource[resourceName] = nil
    end
end)

return DynamicMarkerManager
