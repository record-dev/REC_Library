
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class._Core.TickManager
local TickManager = require "@REC_Library.client.class._core.cl_tickManager"

---@class REC_Library.Client.Class.Marker.Managers.DynamicMarkerManager
---@field boundItems table<integer, REC_Library.Client.Class.Marker.Managers.DynamicMarkerManager.BoundItem>
---@field count integer
local DynamicMarkerManager = {}
DynamicMarkerManager.name = "DynamicMarkerManager"
DynamicMarkerManager.boundItems = {}
DynamicMarkerManager.count = 0
DynamicMarkerManager.nextId = 1

---Connect drawable objects to entities and start managing them as dynamic markers
---@param renderable table rendering object. Must have `.drawAt(position)` method.
---@param target integer Tracked entity handle
---@param offset? vector3 Offset from entity coordinates (optional)
---@return integer ID used for unbind
function DynamicMarkerManager:bind(renderable, target, offset)

    local id = self.nextId
    self.nextId = id + 1

    self.boundItems[id] = {
        renderable = renderable,
        target = target,
        offset = offset or vector3(0.0, 0.0, 0.0),
        drawDistance = renderable.info ~= nil and renderable.info.drawDistance or 150.0,
    }
    self.count += 1

    -- the first binding opens the shared tick, the last one closes it again
    if self.count == 1 then
        TickManager:registerTick(self.name, function () self:update() end)
    end

    return id
end

---Untrack dynamic markers
---@param id integer ID returned by the bind function
function DynamicMarkerManager:unbind(id)

    if self.boundItems[id] == nil then
        utils:debugPrint(("^3[DynamicMarkerManager:unbind] item is not founded... id: %s^0"):format(tostring(id)))
        return
    end

    self.boundItems[id] = nil
    self.count -= 1

    if self.count <= 0 then
        self.count = 0
        TickManager:unregisterTick(self.name)
    end
end

---Update process called every frame from TickManager
function DynamicMarkerManager:update()

    local coords = cache.coords

    for id, item in pairs(self.boundItems) do

        if DoesEntityExist(item.target) == false then
            self:unbind(id)
            goto continue
        end

        local drawPos = GetEntityCoords(item.target) + item.offset
        if #(coords - drawPos) <= item.drawDistance then
            item.renderable:drawAt(drawPos)
        end

        ::continue::
    end
end

---Helper function to check whether the table to be drawn is empty
---@return boolean
function DynamicMarkerManager:hasBoundItems()
    return self.count > 0
end

return DynamicMarkerManager

---@class REC_Library.Client.Class.Marker.Managers.DynamicMarkerManager.BoundItem
---@field renderable table
---@field target integer
---@field offset vector3
---@field drawDistance number
