
---@class REC_Library.Client.Class.Ped.PedGroupController
local PedGroupController = {}
PedGroupController.__index = PedGroupController

---instantiation
---@return self
function PedGroupController:new()
    local instance = setmetatable({}, self)
    return instance
end

return PedGroupController
