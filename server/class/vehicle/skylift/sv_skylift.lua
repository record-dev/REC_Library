
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

local Vehicle = require "@REC_Library.server.class.vehicle.sv_vehicle"

---@class REC_Library.Server.Class.Vehicle.Skylift.Skylift: REC_Library.Server.Class.Vehicle.Vehicle
---@field info REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder
local Skylift = {}
setmetatable(Skylift, { __index = Vehicle })
Skylift.__index = Skylift

---instantiation
---@param config REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder
---@return self
function Skylift:new(config)
    local instance = Vehicle:new(config)
    instance.info = config
    return instance
end

-- ---instantiate from handle
-- ---@return self|nil
-- function Skylift:newFromHandle(entityHandle)

-- -- Existence check
--     if DoesEntityExist(entityHandle) == false then
--         utils:debugPrint("Vehicle:newFromHandle: Entity does not exist for handle: " .. tostring(entityHandle))
--         return nil
--     end

--     ---@type REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder
--     local config = {
--         model = "",
--         handle = entityHandle,
--         modelHash = GetEntityModel(entityHandle),
--         coords = GetEntityCoords(entityHandle),
--         heading = GetEntityHeading(entityHandle),
--         useServerSetter = true,
--         isFreezeEntity = false,
--         isResolving = false
--     }

--     local instance = setmetatable({}, self)
--     instance.info = config

--     return instance
-- end

return Skylift
