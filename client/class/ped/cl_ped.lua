
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"


---@type REC_Library.Client.Functions
local clientFunctions = require "@REC_Library.client.cl_functions"

---@class REC_Library.Client.Class.Ped.Ped
---@field info REC_Library.Shared.Class.Ped.PedConfigBuilder
local Ped = {}
Ped.__index = Ped

---@param config REC_Library.Shared.Class.Ped.PedConfigBuilder
---@return self Ped
function Ped:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---instantiate from handle
---@param netId integer
---@return self|nil
function Ped:newFromNetId(netId)
    assert(type(netId) == "number", "netId must be a number or integer")

    local handle = NetworkGetEntityFromNetworkId(netId)

    local timeout = 1200
    while DoesEntityExist(handle) == false do
        utils:debugPrint("waiting exist")
        handle = NetworkGetEntityFromNetworkId(netId)

        if timeout <= 0 then
            utils:debugPrint("waiting timeout")
            return
        end

        timeout = timeout - 50
        Wait(100)
    end

    -- Existence confirmation
    if DoesEntityExist(handle) == false then
        utils:debugPrint("[Ped:newFromHandle] ped is not founded with handle:", handle)
        return
    end

    ---@type REC_Library.Shared.Class.Ped.PedConfigBuilder
    local config = {
        handle = handle,
        netId = netId,
        model = "",
        modelHash = GetEntityModel(handle),
        coords = GetEntityCoords(handle),
        heading = GetEntityHeading(handle),
        spawnedCoords = GetEntityCoords(handle),
        spawnedHeading = GetEntityHeading(handle),
        interiorId = 0,
        roomKeyHash = 0,
        isMissionEntity = false,
        isResolving = false,
    }

    local instance = setmetatable({}, self)
    instance.info = config

    return instance
end

---Return whether it was successful or not
---@return boolean
function Ped:spawn()
    local info = self.info

    -- Cancel if another location is running
    if info.isResolving then
        utils:debugPrint("Ped is already resolving, cannot spawn again.")
        return false
    end

    -- Existence confirmation
    if info.handle and DoesEntityExist(info.handle) then
        utils:debugPrint("Ped already exists with entity ID: " .. tostring(info.handle))
        return false
    end

    -- Load model
    if not clientFunctions.requestModel(info.modelHash, 2000) then
        utils:debugPrint("Failed to load model: " .. info.model)
        return false
    end

    -- flag the process in progress
    info.isResolving = true

    -- Incorporate any custom offsets into the table
    if info.customOffset ~= nil then
        info.coords = info.coords + info.customOffset
    end

    -- Generation of PEDs
    info.handle = CreatePed(
        info.type,
        info.modelHash,
        info.coords.x,
        info.coords.y,
        info.coords.z,
        info.heading,
        info.isNetworked,
        true
    )

    --Spawn confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        info.isResolving = false -- lower processing flag
        utils:debugPrint("Failed to create PED entity.")
        return false
    end

    -- Stores actual spawn coordinates
    info.spawnedCoords = GetEntityCoords(info.handle)

    -- Freezes once due to fall prevention
    FreezeEntityPosition(info.handle, true)

    -- Obtain NetId If NetId is true but cannot be obtained, an error will occur at that point.
    if info.isNetworked then
        info.netId = NetworkGetNetworkIdFromEntity(info.handle)
        if info.netId == 0 then
            info.isResolving = false -- lower processing flag
            utils:debugPrint("Failed to get NetId for Ped entity.")
            return false
        end
    end

    -- -- Set the deletion flag to true when you want to monitor it from the script
    -- SetEntityAsMissionEntity(info.handle, info.isMissionEntity, false)

    -- ==== Various PED settings ==== --

    -- hp settings
    if info.hp ~= nil then
        SetEntityHealth(info.handle, info.hp)
    end

    -- Aromour settings
    if info.armour ~= nil then
        SetPedArmour(info.handle, info.armour)
    end

    --weapon settings
    if info.weapon ~= nil then
        GiveWeaponToPed(
            info.handle,
            info.weaponHash,
            info.weaponAmmo or 0,
            false,
            true -- force to hold in hand
        )
        SetCurrentPedWeapon(
            info.handle,
            info.weaponHash,
            true -- force to hold in hand
        )

        -- Accessory parts added
        if info.weaponComponents ~= nil and next(info.weaponComponents) ~= nil then
            for _, component in ipairs(info.weaponComponents) do
                GiveWeaponComponentToPed(
                    info.handle,
                    info.weaponHash,
                    component.modelHash
                )
            end
        end

    end

    -- Default relationship group storage
    self:setDefaultRelationGroup()

    -- Configuring relationship groups
    if info.relationshipGroup ~= nil then
        SetPedRelationshipGroupHash(info.handle, info.relationshipGroup)
    end

    -- Tolerance settings
    if info.proofs ~= nil then
        SetEntityProofs(
            info.handle,
            info.proofs.bullet,
            info.proofs.fire,
            info.proofs.explosion,
            info.proofs.collision,
            info.proofs.melee,
            info.proofs.steam,
            info.proofs.headshot,
            info.proofs.water
        )
    end

    -- Check if it freezes eventually
    if info.isFreezeEntity == false then
        FreezeEntityPosition(info.handle, false)
    end

    -- Grants invincibility
    SetEntityInvincible(info.handle, info.isInvincible)

    -- Set whether to ignore the event
    SetBlockingOfNonTemporaryEvents(info.handle, info.isBlockingOfTemporaryEvents)

    --Give room key
    if info.roomKeyHash ~= 0 then
        ForceRoomForEntity(info.handle, GetInteriorFromEntity(info.handle), info.roomKeyHash)
    end

    -- ==== Various PED settings END ==== --

    -- lower processing flag
    info.isResolving = false

    utils:debugPrint("Ped spawned successfully with entity ID: " .. tostring(info.handle))

    return true
end

---Set default relationship group for PED
function Ped:setDefaultRelationGroup()
    local info = self.info

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Ped entity does not exist.")
        return false
    end

    info.defaultRelationshipGroup = GetPedRelationshipGroupDefaultHash(info.handle)
end

---Relationship group settings
---@param relationshipGroup integer relationship group
---@return boolean
function Ped:setRelationshipGroup(relationshipGroup)
    local info = self.info

    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Ped entity does not exist.")
        return false
    end

    -- Relationship group settings
    SetPedRelationshipGroupHash(info.handle, relationshipGroup)

    return true
end

---Grant interaction
---@param options? REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder|REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder If you want to overwrite existing targetOptions
---@return boolean
function Ped:addTarget(options)
    local info = self.info

    -- Overwrite if you want to add it later
    if options ~= nil and type(options) == "table" then
        info.targetOptions = options
    end

    -- Check if option exists here
    if info.targetOptions == nil then
        utils:debugPrint("[Object:addTarget] parameter 'targetOptions' is nil")
        return false
    end

    -- Cancel if operation is in progress
    if info.isResolving then
        utils:debugPrint("Object:addTarget: Object with UID " .. (info.uid or "N/A") .. " is already resolving.")
        return false
    end

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Object:addTarget: Object with UID " .. (info.uid or "N/A") .. " does not exist.")
        return false
    end

    -- Operation flag enabled
    info.isResolving = true

    -- Grant
    if not clientFunctions.addTargetEntity(
        info.handle,
        info.targetOptions
    ) then
        utils:debugPrint("Object:addTarget: Failed to add target for object with UID " .. (info.handle or "N/A"))
        info.isResolving = false
        return false
    end

    -- Operation flag disabled
    info.isResolving = false

    return true
end

---Put the Ped in the vehicle
---@param vehHandle number Vehicle handle
---@param seat number seat
---@return boolean Return whether it was successful
function Ped:putInVehicle(vehHandle, seat)
    local info = self.info

    -- Cancel if another location is running
    if info.isResolving then
        utils:debugPrint("Ped is already resolving, cannot put in vehicle.")
        return false
    end

    -- flag as running
    info.isResolving = true

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        info.isResolving = false
        utils:debugPrint("Ped entity does not exist.")
        return false
    end

    -- Vehicle presence confirmation
    if vehHandle == nil or DoesEntityExist(vehHandle) == false then
        info.isResolving = false
        utils:debugPrint("Vehicle entity does not exist.")
        return false
    end

    --Put the PED in the vehicle
    TaskWarpPedIntoVehicle(info.handle, vehHandle, seat)

    -- lower running flag
    info.isResolving = false

    return true
end

---Discard Ped
---@return boolean Return whether it was successful
function Ped:destroy()
    local info = self.info

    -- Cancel if another location is running
    if info.isResolving then
        utils:debugPrint("Ped is already resolving, cannot destroy.")
        return false
    end

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        info.isResolving = false
        utils:debugPrint("Ped entity does not exist.")
        return false
    end

    -- flag as running
    info.isResolving = false

    -- isNetwork and request owner privileges if you do not have control privileges
    if info.isNetworked then
        if not clientFunctions.requestOwnership(info.handle, 2000) then
            info.isResolving = false
            utils:debugPrint("Failed to gain ownership of PED entity.")
            return false
        end
    end

    -- PED removal
    DeleteEntity(info.handle)

    -- Deleted so no longer needed
    info.handle = 0
    info.netId = nil

    -- Lower running flag
    info.isResolving = false

    return true
end

---Get the flag whether it is in progress or not
---@return boolean
function Ped:getIsResolving()
    return self.info.isResolving
end

---@return integer
function Ped:getHandle()
    return self.info.handle
end

---@return vector3
function Ped:getCoords()
    return self.info.coords
end

return Ped
