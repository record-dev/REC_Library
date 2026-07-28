
---@class REC_Library.Client.Class.Ped.Manager.PedManager
---@field info REC_Library.Client.Class.Ped.Manager.PedManagerConfigBuilder
local PedManager = {}
PedManager.__index = PedManager

---instantiation
---@param config REC_Library.Client.Class.Ped.Manager.PedManagerConfigBuilder
---@return self
function PedManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Ped registration
---@return boolean
function PedManager:register()

    

    return true
end

return PedManager
