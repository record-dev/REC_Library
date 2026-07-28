
---@class REC_Library.Client.Class.Ped.PedGroupControllerConfigBuilder
---@field leader REC_Library.Client.Class.Ped.Ped
---@field member? table<number, REC_Library.Client.Class.Ped.Ped>
local PedGroupControllerConfigBuilder = {}
PedGroupControllerConfigBuilder.__index = PedGroupControllerConfigBuilder

---instantiation
---@param leader REC_Library.Client.Class.Ped.Ped
---@return self
function PedGroupControllerConfigBuilder:new(leader)
    assert(leader ~= nil and type(leader) == "table", "")
    local instance = setmetatable({}, self)
    instance.leader = leader
    return instance
end

return PedGroupControllerConfigBuilder
