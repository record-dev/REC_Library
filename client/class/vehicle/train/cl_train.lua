
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Functions
local clientFunctions = require "@REC_Library.client.cl_functions"

---@class REC_Library.Client.Class.Vehicle.Train.Train
---@field info REC_Library.Client.Class.Vehicle.Train.TrainConfigBuilder
local Train = {}
Train.__index = Train

---instantiation
---@param config REC_Library.Client.Class.Vehicle.Train.TrainConfigBuilder
---@return self
function Train:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Create an instance from an existing train
---@param entityHandle integer Train entity handle
---@param settings? REC_Library.Client.Class.Vehicle.Train.Train.NewFromHandle.Settings
---@return self|nil
function Train:newFromHandle(entityHandle, settings)

    --Existence check
    if DoesEntityExist(entityHandle) == false then
        utils:debugPrint("Vehicle:newFromHandle: Entity does not exist for handle: " .. tostring(entityHandle))
        return nil
    end

    ---@type REC_Library.Client.Class.Vehicle.Train.TrainConfigBuilder
    local config = {
        handle = entityHandle,
        models = {},
        modelHashs = {},
        variation = 0,
        coords = GetEntityCoords(entityHandle),
        direction = true,
        startSpeed = settings ~= nil and settings.defaultSpeed or 20.0,
        speed = 25.0,
        spawnedSpeed = 30.0,
        spawnedHeading = 0.0,
        carriageEntities = {},
        drivers = {},
        guards = {},
        guardsVehicles = {},
        spawnTimeout = 1500,
        destroyTimeout = 1000,
        isStopAtStation = false,
        isInvincible = false,
        isNetworked = false,
        isMissionEntity = false,
        isResolving = false
    }

    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Spawn
---@return boolean success or not
function Train:spawn()
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        info.isResolving = false
        utils:debugPrint("Train is already resolving.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Check if it already exists
    if info.handle ~= nil or DoesEntityExist(info.handle) then
        utils:debugPrint("Train entity already exists.")
        info.isResolving = false
        return false
    end

    -- Load all vehicle models
    for _, modelHash in ipairs(info.modelHashs) do
        if not clientFunctions.requestModel(modelHash) then
            info.isResolving = false
            utils:debugPrint("Failed to request model for train: " .. modelHash)
            return false
        end
    end

    -- Generate vehicle
    info.handle = CreateMissionTrain(
        info.variation,
        info.coords.x, info.coords.y, info.coords.z,
        info.direction
        ,
        true,
        true
    )

    -- Wait for spawn to complete
    local currentTimeout = info.spawnTimeout
    while not DoesEntityExist(info.handle) do
        currentTimeout = currentTimeout - 100
        if currentTimeout <= 0 then
            utils:debugPrint("Failed to spawn main train")
            info.isResolving = false
            return false
        end
        Wait(100)
    end

    -- Disable engine deletion
    SetEntityCleanupByEngine(info.handle, false)

    -- Networking
    -- NetworkRegisterEntityAsNetworked(info.handle)

    -- designated as important
    SetEntityAsMissionEntity(info.handle, false, true)

    -- Get net ID
    info.netId = NetworkGetNetworkIdFromEntity(info.handle)

    -- Confirm netId acquisition
    local getNetIdTimeout = 2000
    while info.netId == 0 do
        getNetIdTimeout = getNetIdTimeout - 100
        if getNetIdTimeout <= 0 then
            utils:debugPrint("Failed to get network ID for train")
            return false
        end
        Wait(100)
    end

    -- Also get the loading vehicle
    for i = 1, 15 do
        local carriageHandle = GetTrainCarriage(info.handle, i)
        if DoesEntityExist(carriageHandle) then

            local carriageNetID = 0
            local getCarriageNetIdTimeout = 2000
            while carriageNetID == 0 do
                carriageNetID = NetworkGetNetworkIdFromEntity(carriageHandle)
                getCarriageNetIdTimeout = getCarriageNetIdTimeout - 100
                if getCarriageNetIdTimeout <= 0 then
                    utils:debugPrint("Failed to get network ID for train")
                    return false
                end
                Wait(100)
            end

            -- Disable engine deletion
            SetEntityCleanupByEngine(carriageHandle, false)

            SetEntityAsMissionEntity(carriageHandle, false, true)

            info.carriageEntities[#info.carriageEntities+1] = {
                handle = carriageHandle,
                netId = carriageNetID
            }
        else
            -- If you can't get it anymore, it means the convoy is gone, so forcefully terminate the loop.
            break
        end
    end

    -- Record spawn location
    info.spawnedCoords = GetEntityCoords(info.handle)

    -- Heading storage
    info.spawnedHeading = GetEntityHeading(info.handle)

    -- Default does not run
    self:applySpeedNaturally(0)

    -- Whether to add a flag to stay at the station
    self:applyStopAtStation(info.isStopAtStation)

    -- Cancel invincibility?
    if info.isInvincible == false then
        SetEntityInvincible(info.handle, false)
    end

    -- Tolerance settings
    if info.proofs ~= nil then
        SetEntityProofs(
            info.handle,
            info.proofs.bullet or false,
            info.proofs.fire or false,
            info.proofs.explosion or false,
            info.proofs.collision or false,
            info.proofs.melee or false,
            info.proofs.steam or false,
            info.proofs.headshot or false,
            info.proofs.water or false
        )
    end

    -- lower flag in progress
    info.isResolving = false

    return true
end

---Run the vehicle
---@param speed? number If you want to specify any speed
---@return boolean success or not
function Train:start(speed)
    local info = self.info
    speed = speed or info.startSpeed or info.speed

    -- Existence confirmation
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Failed to create train entity.")
        return false
    end

    -- Cancel if already running
    if GetTrainSpeed(info.handle) ~= 0 then
        utils:debugPrint("Train is already running.")
        return false
    end

    -- Gives natural acceleration
    self:applySpeedNaturally(speed)

    return true
end

---Stop the vehicle naturally
---@return boolean success or not
function Train:stop()
    local info = self.info

    -- Existence confirmation
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Failed to create train entity.")
        return false
    end

    -- Cancel if already stopped
    if GetTrainSpeed(info.handle) == 0 then
        utils:debugPrint("Train is already stopped.")
        return false
    end

    -- stop
    self:applySpeedNaturally(0)

    return true
end

---Change train speed naturally
---@param speed? number Custom speed
---@return boolean success or not
function Train:applySpeedNaturally(speed)
    local info = self.info
    speed = (speed or info.speed) * 1.0

    -- Existence confirmation
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Failed to create train entity.")
        return false
    end

    SetTrainCruiseSpeed(info.handle, speed)

    return true
end

---Force train speed to change instantly
---@param speed? number Custom speed
---@return boolean success or not
function Train:applySpeedForce(speed)
    local info = self.info
    speed = (speed or info.speed) * 1.0

    -- Existence confirmation
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Failed to create train entity.")
        return false
    end

    SetTrainSpeed(info.handle, speed)

    return true
end

---Whether to enable the stop flag at the station
---@param isStopAtStation boolean
---@return boolean success or not
function Train:applyStopAtStation(isStopAtStation)
    local info = self.info

    -- Existence confirmation
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Failed to create train entity.")
        return false
    end

    SetTrainStopAtStations(info.handle, isStopAtStation)

    return true
end

---Delete
---@return boolean success or not
function Train:destroy()
    local info = self.info
    local trains = { info.handle }
    for index, carriage in ipairs(info.carriageEntities) do
        trains[#trains+1] = carriage.handle
    end

    for index, train in ipairs(trains) do
       -- Existence confirmation
        if train == nil or DoesEntityExist(train) == false then
            utils:debugPrint("Train entity does not exist.")
            return false
        end

        -- Disable Missionentity flag for deletion protection
        SetEntityAsMissionEntity(train, false, true)

        -- Delete
        DeleteEntity(train)
    end

    return true
end

---@class REC_Library.Client.Class.Vehicle.Train.Train.NewFromHandle.Settings
---@field defaultSpeed number

return Train
