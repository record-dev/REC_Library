
---@type REC_Library.Shared.Validator
local validator = require "@REC_Library.shared.sh_validator"

---@class REC_Library.Client.Class.Vehicle.Train.TrainConfigBuilder
---@field handle number 
---@field netId? number
---@field models string[]
---@field modelHashs number[]
---@field variation number
---@field coords vector3
---@field direction boolean
---@field startSpeed number float type
---@field speed number float type
---@field spawnedSpeed? number float type
---@field spawnedCoords? vector3
---@field spawnedHeading? number float type
---@field carriageEntities table<number, REC_Library.Client.Class.Vehicle.Train.TrainConfigBuilder.CarriageEntities>
---@field drivers number[]
---@field guards number[]
---@field guardsVehicles number[]
---@field proofs? REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder
---@field spawnTimeout integer
---@field destroyTimeout integer
---@field isStopAtStation boolean
---@field isInvincible boolean
---@field isNetworked boolean
---@field isMissionEntity boolean
---@field isResolving boolean
local TrainConfigBuilder = {}
TrainConfigBuilder.__index = TrainConfigBuilder

---instantiation
---@param models string[] Train model list
---@param variation number Train variation(reccomanded: 0-24 latest:0-26)
---@param coords vector3 spawn coordinates
---@param direction boolean Should the direction be the opposite of the normal direction?
---@return self
function TrainConfigBuilder:new(models, variation, coords, direction)
    assert(models ~= nil and type(models) == "table" and validator.isTableOfNumberString(models))
    assert(variation ~= nil and type(variation) == "number")
    assert(coords ~= nil and type(coords) == "vector3")
    assert(direction ~= nil and type(direction) == "boolean")
    local instance = setmetatable({}, self)
    instance.models = models
    instance.modelHashs = {}
    for _, model in pairs(instance.models) do
        instance.modelHashs[#instance.modelHashs+1] = joaat(model)
    end
    instance.variation = joaat(variation)
    instance.coords = coords
    instance.direction = direction
    instance.spawnedCoords = coords
    instance.carriageEntities = {}
    instance.drivers = {}
    instance.guards = {}
    instance.guardsVehicles = {}
    instance.spawnTimeout = 1500
    instance.destroyTimeout = 1000
    instance.isStopAtStation = false
    instance.isInvincible = true
    instance.isNetworked = false
    instance.isMissionEntity = false
    instance.isResolving = false
    return instance
end

---Initial speed setting
---@param startSpeed number|nil
---@return self method chain
function TrainConfigBuilder:setStartSpeedNaturally(startSpeed)
    if startSpeed == nil then return self end
    assert(startSpeed ~= nil and type(startSpeed) == "number")
    self.startSpeed = startSpeed * 1.0
    return self
end

---Initial speed setting
---@param speed number|nil
---@return self method chain
function TrainConfigBuilder:setSpeedNaturally(speed)
    if speed == nil then return self end
    assert(speed ~= nil and type(speed) == "number")
    self.speed = speed * 1.0
    -- self.spawnedSpeed = speed * 1.0
    return self
end

---Cancel invincibility?
---@param isInvincible boolean|nil
---@return self chain method
function TrainConfigBuilder:setIsInvincible(isInvincible)
    if isInvincible == nil then return self end
    assert(type(isInvincible) == "boolean")
    self.isInvincible = isInvincible
    return self
end

---Gives resistance
---@param proofs REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder|nil
---@return self method chain
function TrainConfigBuilder:setProofs(proofs)
    if proofs == nil then return self end
    assert(type(proofs) == "table")
    self.proofs = proofs
    return self
end

---Specify whether to stop at the station flag
---@param isStopAtStation boolean|nil
---@return self method chain
function TrainConfigBuilder:setIsStopAtStation(isStopAtStation)
    if isStopAtStation == nil then return self end
    assert(isStopAtStation ~= nil and type(isStopAtStation) == "boolean")
    self.isStopAtStation = isStopAtStation return self
end

---@param isNetworked boolean|nil
---@return self method chain
function TrainConfigBuilder:setIsNetworked(isNetworked)
    if isNetworked == nil then return self end
    assert(isNetworked ~= nil and type(isNetworked) == "boolean")
    self.isNetworked = isNetworked return self
end

---@param isMissionEntity boolean|nil
---@return self method chain
function TrainConfigBuilder:setIsMissionEntity(isMissionEntity)
    if isMissionEntity == nil then return self end
    assert(isMissionEntity ~= nil and type(isMissionEntity) == "boolean")
    self.isMissionEntity = isMissionEntity return self
end

---@return table Return in table format
function TrainConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

---@class REC_Library.Client.Class.Vehicle.Train.TrainConfigBuilder.CarriageEntities
---@field handle integer handle
---@field netId integer Network ID

return TrainConfigBuilder
