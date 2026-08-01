
---@class REC_Library.Shared.Class.Ped.PedConfig
---@field uid? string
---@field handle integer
---@field netId integer
---@field model string
---@field modelHash number
---@field coords vector3
---@field heading number
---@field customOffset? vector3
---@field type? number
---@field hp? number
---@field armour? number
---@field weapon? string
---@field weaponHash? number
---@field weaponAmmo? number
---@field weaponComponents? REC_Library.Shared.Class.Ped.PedConfigBuilder.Weapon.Components[]
---@field defaultRelationshipGroup? number
---@field relationshipGroup? number
---@field interiorId integer
---@field roomHashKey integer
---@field proofs? REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder
---@field components? REC_Library.Shared.Class.Ped.PedComponentsConfigBuilder
---@field targetOptions? REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder|REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder|nil
---@field spawnedCoords vector3
---@field spawnedHeading number
---@field spawnTimeout integer
---@field destroyTimeout integer
---@field isFreezeEntity boolean
---@field isMissionEntity boolean
---@field isNetworked boolean
---@field isSciptHosted boolean
---@field isBlockingOfTemporaryEvents boolean
---@field isInvincible boolean
---@field isResolving boolean

---@class REC_Library.Shared.Class.Ped.PedConfigBuilder: REC_Library.Shared.Class.Ped.PedConfig
local PedConfigBuilder = {}
PedConfigBuilder.__index = PedConfigBuilder

---instantiation
---@param model string ped model
---@param coords vector3 Coordinates where you want to spawn
---@param heading number heading
---@return self
function PedConfigBuilder:new(model, coords, heading)
    assert(model ~= nil and type(model) == "string")
    assert(coords ~= nil and type(coords) == "vector3")
    assert(heading ~= nil and type(heading) == "number")
    local instance = setmetatable({}, self)
    instance.handle = 0
    instance.model = model
    instance.modelHash = joaat(model)
    instance.coords = coords
    instance.heading = heading
    instance.type = 4
    instance.weaponAmmo = 255
    instance.interiorId = 0
    instance.roomHashKey = 0
    instance.spawnTimeout = 1500
    instance.destroyTimeout = 1000
    instance.isFreezeEntity = false
    instance.isMissionEntity= false
    instance.isNetworked = false
    instance.isSciptHosted = false
    instance.isBlockingOfTemporaryEvents = false
    instance.isInvincible = false
    instance.isResolving = false
    return instance
end

---@param uid string|nil
---@return self 
function PedConfigBuilder:setUid(uid)
    if uid == nil then return self end
    assert(type(uid) == "string", "")
    self.uid = uid
    return self
end

---@param pedType number|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setType(pedType)
    if pedType == nil then return self end
    assert(type(pedType) == "number" and pedType >= 0)
    self.type = pedType
    return self
end

---@param hp number|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setHp(hp)
    if hp == nil then return self end
    assert(type(hp) == "number")
    self.hp = hp
    return self
end

---@param armour number|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setArmour(armour)
    if armour == nil then return self end
    assert(type(armour) == "number")
    self.armour = armour
    return self
end

---@param weaponModel string|nil weapon model
---@param weaponAmmo? number Number of weapon ammo
---@param weaponComponents? REC_Library.Shared.Class.Ped.PedConfigBuilder.Weapon.Components[] Weapon parts
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setWeapon(weaponModel, weaponAmmo, weaponComponents)
    if weaponModel == nil then return self end
    assert(type(weaponModel) == "string")
    self.weapon = weaponModel
    if weaponModel then
        self.weaponHash = joaat(weaponModel)
    else
        self.weaponHash = nil
    end

    -- Setting optional items
    if weaponAmmo ~= nil and type(weaponAmmo) == "number" then
        self.weaponAmmo = weaponAmmo
    end

    if weaponComponents ~= nil and type(weaponComponents) == "table" then
        for index, component in ipairs(weaponComponents) do
            self.weaponComponents = {}
            self.weaponComponents[#self.weaponComponents+1] = {
                model = component.model,
                modelHash = joaat(component.model)
            }
        end
    end

    return self
end

---Relationship group settings
---@param relationshipGroup string|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setRelationshipGroup(relationshipGroup)
    if relationshipGroup == nil then return self end
    assert(type(relationshipGroup) == "string")
    self.relationshipGroup = joaat(relationshipGroup)
    return self
end

---Room key settings
---@param roomKey integer|string|nil
---@return self
function PedConfigBuilder:setRoomKey(roomKey)
    if roomKey == nil then return self end
    local valueType = type(roomKey)
    assert((valueType == "number" or valueType == "string"))
    self.roomHashKey = valueType == "string" and joaat(roomKey) or roomKey
    return self
end

---Resistance settings
---@param proofs REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setProofs(proofs)
    if proofs == nil then return self end
    assert(type(proofs) == "table")
    self.proofs = proofs
    return self
end

---Setting a custom offset
---@param customOffset vector3|nil
---@return self chain method
function PedConfigBuilder:setCustomOffset(customOffset)
    if customOffset == nil then return self end
    assert(type(customOffset) == "vector3")
    self.customOffset = customOffset
    return self
end

---@param spawnTimeout integer|nil
function PedConfigBuilder:setSpawnTimeout(spawnTimeout)
    if spawnTimeout == nil then return self end
    assert(type(spawnTimeout) == "number", "")
    self.spawnTimeout = spawnTimeout
    return self
end

---@param destroyTimeout integer|nil
function PedConfigBuilder:setDestroyTimeout(destroyTimeout)
    if destroyTimeout == nil then return self end
    assert(type(destroyTimeout) == "number", "")
    self.destroyTimeout = destroyTimeout
    return self
end

---@param isFreezeEntity boolean|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setIsFreezeEntity(isFreezeEntity)
    if isFreezeEntity == nil then return self end
    assert(type(isFreezeEntity) == "boolean")
    self.isFreezeEntity = isFreezeEntity
    return self
end

---@param isNetworked boolean|nil
---@return self PedConfigBuilder chain method
function PedConfigBuilder:setIsNetworked(isNetworked)
    if isNetworked == nil then return self end
    assert(type(isNetworked) == "boolean")
    self.isNetworked = isNetworked
    return self
end

---@param isSciptHosted boolean|nil
function PedConfigBuilder:setIsSciptHosted(isSciptHosted)
    if isSciptHosted == nil then return self end
    assert(type(isSciptHosted) == "boolean", "")
    self.isSciptHosted = isSciptHosted
    return self
end

---@param isInvincible boolean|nil
function PedConfigBuilder:setIsInvincible(isInvincible)
    if isInvincible == nil then return self end
    assert(type(isInvincible) == "boolean", "isInvincible must be a boolean")
    self.isInvincible = isInvincible
    return self
end

---@param isBlockingOfTemporaryEvents boolean|nil
function PedConfigBuilder:setIsBlockingOfTemporaryEvents(isBlockingOfTemporaryEvents)
    if isBlockingOfTemporaryEvents == nil then return self end
    assert(type(isBlockingOfTemporaryEvents) == "boolean", "isBlockingOfTemporaryEvents must be a boolean")
    self.isBlockingOfTemporaryEvents = isBlockingOfTemporaryEvents
    return self
end

---@return table table of built object settings
function PedConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return PedConfigBuilder

---@class REC_Library.Shared.Class.Ped.PedConfigBuilder.Weapon.Components
---@field model string
---@field modelHash integer
