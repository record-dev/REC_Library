
---@type REC_Library.Shared.Class.Object.ObjectConfigBuilder
local ObjectConfigBuilder = require "@REC_Library.shared.class.object.sh_objectConfigBuilder"

---@class REC_Library.Shared.Class.Object.DoorConfigBuilder: REC_Library.Shared.Class.Object.ObjectConfigBuilder
---@field isLocked boolean
local DoorConfigBuilder = {}
setmetatable(DoorConfigBuilder, { __index = ObjectConfigBuilder, })
DoorConfigBuilder.__index = DoorConfigBuilder

---@param model integer|string
---@param coords vector3
---@param heading number
function DoorConfigBuilder:new(model, coords, heading)

    ---@diagnostic disable-next-line
    local instance = ObjectConfigBuilder:new(model, coords, heading)
    ---@cast instance REC_Library.Shared.Class.Object.DoorConfigBuilder

    instance.isDoorFlag = true
    instance.isLocked = false

    return instance
end

return DoorConfigBuilder