
local VehicleConfigBuilder = require "@REC_Library.shared.class.vehicle.sh_vehicleConfigBuilder"

---@class REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder: REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
---@field magnetOffset vector3
---@field moveDuration integer
---@field hasAttached boolean
local SkyliftConfigBuilder = {}
setmetatable(SkyliftConfigBuilder, { __index = VehicleConfigBuilder })
SkyliftConfigBuilder.__index = SkyliftConfigBuilder

---instantiation
---@return self
function SkyliftConfigBuilder:new(model, coords, heading)
    assert(model and type(model) == "string")
    assert(coords and type(coords) == "vector3")
    assert(heading and type(heading) == "number")
    local instance = VehicleConfigBuilder:new(model, coords, heading)
    ---@cast instance REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder

    instance.model = model
    instance.modelHash = joaat(model)
    instance.coords = coords
    instance.heading = heading
    instance.magnetOffset = vector3(0.0, 0.0, -5.0)
    instance.moveDuration = 2000
    instance.spawnTimeout = 1500
    instance.destroyTimeout = 1000
    instance.useServerSetter = true
    instance.isNetworked = true
    instance.isMissionEntity = false
    instance.isFreezeEntity = false
    instance.isResolving = false
    instance.hasAttached = false
    return instance
end

---Define the magnet position
---@param magnetOffset vector3|nil
---@return self
function SkyliftConfigBuilder:setMagnetOffset(magnetOffset)
    if magnetOffset == nil then return self end
    assert(type(magnetOffset) == "vector3", "magnetOffset must be a vector3")
    self.magnetOffset = magnetOffset
    return self
end

---Specify the time to draw
---@param moveDuration integer|nil
---@return self
function SkyliftConfigBuilder:setMoveDuration(moveDuration)
    if moveDuration == nil then return self end
    assert(type(moveDuration) == "number", "moveDuration must be a number")
    self.moveDuration = moveDuration
    return self
end

return SkyliftConfigBuilder
