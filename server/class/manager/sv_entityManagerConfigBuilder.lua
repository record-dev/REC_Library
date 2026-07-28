
---@class REC_Library.Server.Class.Manager.EntityManagerConfigBuilder
---@field entitiesByUniqueId table<string, REC_Library.Server.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId>
---@field entitiesByZone table<string, table<string, string>>
local EntityManagerConfigBuilder = {}
EntityManagerConfigBuilder.__index = EntityManagerConfigBuilder

---instantiation
---@return self
function EntityManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.entitiesByUniqueId = {}
    instance.entitiesByZone = {}
    return instance
end

---@return table Built table format
function EntityManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end


---@class REC_Library.Server.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId
---@field syncType REC_Library.Shared.Enums.EntitySyncType Sync type
---@field entityInstance? REC_Library.Server.Class.Object.Object|REC_Library.Server.Class.Ped.Ped|REC_Library.Server.Class.Vehicle.Vehicle Entity instance
---@field netId? integer NetId
---@field creatorId? integer Creator (for network generation)
---@field zoneName? string Zone name


return EntityManagerConfigBuilder
