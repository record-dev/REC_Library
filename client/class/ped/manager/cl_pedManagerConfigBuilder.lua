
---@class REC_Library.Client.Class.Ped.Manager.PedManagerConfigBuilder
---@field peds table<number, REC_Library.Client.Class.Ped.Ped>
local PedManagerConfigBuilder = {}
PedManagerConfigBuilder.__index = PedManagerConfigBuilder

---instantiation
---@return self
function PedManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.peds = {}
    return instance
end

---Return built table format
---@return table
function PedManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return PedManagerConfigBuilder
