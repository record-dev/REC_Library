
---@class REC_Library.Client.Class.Vehicle.VehicleModsConfigBuilder
local VehicleModsConfigBuilder = {}
VehicleModsConfigBuilder.__index = VehicleModsConfigBuilder

function VehicleModsConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.spoiler = nil
    instance.frontBumper = nil
    instance.rearBumper = nil
    instance.sideSkirt = nil
    instance.exhaust = nil
    instance.hood = nil
    instance.grille = nil
    instance.roof = nil
    instance.fenders = nil
    instance.engine = nil
    instance.brakes = nil
    instance.transmission = nil
    instance.suspension = nil
    instance.horns = nil
    instance.windowTint = nil
    instance.wheelType = nil
    instance.wheels = nil
    instance.tireSmokeColor = nil
    instance.livery = nil
    instance.plateStyle = nil
    instance.xenonHeadlights = false
    return instance
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setSpoiler(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.spoiler = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setFrontBumper(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.frontBumper = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setRearBumper(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.rearBumper = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setSideSkirt(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.sideSkirt = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setExhaust(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.exhaust = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setHood(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.hood = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setGrille(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.grille = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setRoof(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.roof = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setFenders(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.fenders = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setEngine(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.engine = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setBrakes(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.brakes = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setTransmission(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.transmission = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setSuspension(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.suspension = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setHorns(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.horns = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setWindowTint(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.windowTint = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setWheelType(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.wheelType = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setWheels(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.wheels = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setTireSmokeColor(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.tireSmokeColor = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setLivery(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.livery = value return self
end

---@param value number|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setPlateStyle(value)
    if value == nil then return self end
    assert(type(value) == "number")
    self.plateStyle = value return self
end

---@param value boolean|nil
---@return self VehicleModsConfigBuilder chain method
function VehicleModsConfigBuilder:setXenonHeadlights(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.xenonHeadlights = value return self
end

---build method
---@return table
function VehicleModsConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end
