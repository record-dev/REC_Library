
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
--- Class responsible for figuring out who has ownership
---]]

---@class REC_Library.Server.Class.Manager.OwnershipManager
---@field info REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder
local OwnershipManager = {}
OwnershipManager.__index = OwnershipManager

---instantiation
---@param config REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder
---@return self
function OwnershipManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Register as a monitoring target
---@param netId number NetId to register
---@param callbacks? REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities.Callbacks Callback registration
---@return boolean success or not
function OwnershipManager:register(netId, callbacks)
    local info = self.info

    -- Check if it is already registered
    if self:getDataByNetId(netId) ~= nil then
        return false
    end

    --Owner Acquisition Verification
    local entityHandle = NetworkGetEntityFromNetworkId(netId)
    local ownerId = NetworkGetEntityOwner(entityHandle)

    -- Confirm the existence of the owner
    if ownerId == 0 then
        utils:debugPrint("[OwnershipManager] Entity does not have an owner: " .. tostring(netId))
        return false
    end

    -- Assigned to the connection with the player
    if info.playerToNetIds[ownerId] == nil then
        info.playerToNetIds[ownerId] = {}
    end

    -- Add to owner
    info.playerToNetIds[ownerId][netId] = netId

    -- Check callback variables
    if callbacks ~= nil then
        assert(type(callbacks) == "table", "Callbacks must be a table")
        for _, callback in pairs(callbacks) do
            assert(type(callback) == "function", "Callback must be a function")
        end
    end

    -- Registration
    info.netIdsData[netId] = {
        handle = entityHandle,
        owner = ownerId,
        callbacks = callbacks or {},
        isChecking = false,
        isUnregisting = false,
    }

    if info.hasRunningMonitor ~= true then
        self:start()
    end

    -- Callback execution
    if info.onRegister ~= nil then
        info.onRegister(self, netId)
    end

    return true
end

---Cancel registration as a monitoring target
---@return boolean success or not
function OwnershipManager:unregister(netId)
    local info = self.info

    -- Check if there is registration information
    if self:getDataByNetId(netId) == nil then
        return false
    end

    -- Cancel if update is in progress
    if info.netIdsData[netId].isUnregisting == true or info.netIdsData[netId].isChecking == true then
        utils:debugPrint("[OwnershipManager] NetId is currently being checked or unregistered: " .. tostring(netId))
        return false
    end

    -- Set flag as unlocked
    info.netIdsData[netId].isUnregisting = true

    local existingOwner = info.netIdsData[netId].owner

    -- Execute unregistration callback
    if info.netIdsData[netId].callbacks.onUnregister ~= nil then
        info.netIdsData[netId].callbacks.onUnregister(self, existingOwner)
    end

    -- Unlink
    if info.playerToNetIds[existingOwner] ~= nil then
        info.playerToNetIds[existingOwner][netId] = nil
    end

    info.netIdsData[netId] = nil

    if info.onUnregister ~= nil then
        info.onUnregister(self, netId)
    end

    return true
end

---Start monitoring
---@private
---@return boolean success or not
function OwnershipManager:start()
    local info = self.info

    if info.hasRunningMonitor ~= false then
        utils:debugPrint("[OwnershipManager] Monitor is already running.")
        return false
    end

    -- Enable monitor command flag
    info.hasRunningMonitor = true

    -- Execute callback at start
    if info.onStart ~= nil then
        info.onStart(self)
    end

    -- Execute the loop
    Citizen.CreateThread(function (threadId)

        -- Store thread ID
        info.threadId = threadId

        -- start loop
        while next(info.playerToNetIds) ~= nil and info.hasRunningMonitor == true do

            -- Create a list of owners to process first
            local ownersToCheck = {}
            for ownerKey in pairs(info.playerToNetIds) do
                ownersToCheck[#ownersToCheck+1] = ownerKey
            end

            for _, owner in pairs(ownersToCheck) do
                local netIds = info.playerToNetIds[owner]
                if netIds ~= nil and next(netIds) then
                    self:checkOwnership(owner, netIds)
                end
            end
            Wait(info.waitTime or 1000)
        end

        -- Stop command at end
        self:stop()
    end)

    return true
end

---Stop monitoring
---@private
---@return boolean success or not
function OwnershipManager:stop()
    local info = self.info

    -- check if starting
    if info.hasRunningMonitor == false then
        utils:debugPrint("[OwnershipManager] Monitor is not running.")
        return false
    end

    -- lower monitoring flag
    info.hasRunningMonitor = false

    -- Discard thread information
    info.threadId = nil

    -- Execute stop callback
    if info.onStop ~= nil then
        info.onStop(self)
    end

    return true
end

---netId owner main management process
---@private
---@param oldOwner number Owner player's Src
---@param netIds number[] Owner managed by owner
---@return boolean success or not
function OwnershipManager:checkOwnership(oldOwner, netIds)
    local info = self.info

    -- Check if it's being monitored
    if info.hasRunningMonitor ~= true then
        utils:debugPrint("[OwnershipManager] Monitor is not running.")
        return false
    end

    -- Check server jurisdiction
    if oldOwner == -1 then

        local transferredFromSrv = {}
        for _, netId in pairs(netIds) do
            local entityHandle = NetworkGetEntityFromNetworkId(netId)

            if info.netIdsData[netId] ~= nil and (info.netIdsData[netId].isChecking or info.netIdsData[netId].isUnregisting) then
                utils:debugPrint("[OwnershipManager] NetId is already being checked or unregistered: " .. tostring(netId))
                goto continue_server
            end

            local newOwner = NetworkGetEntityOwner(entityHandle)

            -- If the owner is no longer the server
            if newOwner > 0 then

                -- Initialize array if it doesn't exist
                if not transferredFromSrv[newOwner] then
                    transferredFromSrv[newOwner] = {}
                end

                -- Stores a list of data to be transferred from the server to another owner
                transferredFromSrv[newOwner][netId] = netId

                -- Update owner information of management data
                if info.netIdsData[netId] then
                    info.netIdsData[netId].owner = newOwner
                end
            end

            -- Callback when checked
            if info.onCheckOwnership ~= nil then
                info.onCheckOwnership(self, entityHandle, netId, oldOwner, newOwner)
            end

            -- Execute ownership check callback
            if info.netIdsData[netId].callbacks.onCheckOwnership ~= nil then
                info.netIdsData[netId].callbacks.onCheckOwnership(self, entityHandle, netId, oldOwner, newOwner)
            end

            -- If the owner has changed
            if oldOwner ~= newOwner then

                -- Execute ownership update callback
                if info.onUpdateOwnership ~= nil then
                    info.onUpdateOwnership(self, entityHandle, netId, oldOwner, newOwner)
                end

                -- Execute any registered processing if there is one
                if info.netIdsData[netId].callbacks.onUpdateOwnership ~= nil then
                    info.netIdsData[netId].callbacks.onUpdateOwnership(self, entityHandle, netId, oldOwner, newOwner)
                end
            end

            ::continue_server::
        end

        -- Handle ownership transfer from server to player
        for newOwner, idsToTransfer in pairs(transferredFromSrv) do

            --Create a new owner list if it doesn't exist
            if not info.playerToNetIds[newOwner] then
                info.playerToNetIds[newOwner] = {}
            end

            -- Transfer NetId
            for id, _ in pairs(idsToTransfer) do
                info.playerToNetIds[newOwner][id] = id -- Add to new owner
                info.playerToNetIds[-1][id] = nil -- Delete from server jurisdiction
            end
            utils:debugPrint(("[OwnershipManager] NetIds transferred from Server to Player %s: %s"):format(tostring(newOwner), ""))
        end

        return true -- Server-related processing ends here
    end

    -- if the owner is online
    if GetPlayerEndpoint(tostring(oldOwner)) ~= nil then

        local owningNetIds = {}
        local transferredNetIds = {}
        for _, netId in pairs(netIds) do
            local entityHandle = nil
            local newOwner = nil

            -- Check if checking is in progress
            if self:getDataByNetId(netId) == nil or (info.netIdsData[netId].isChecking == true or info.netIdsData[netId].isUnregisting == true )then
                utils:debugPrint("[OwnershipManager] NetId is already being checked or unregistered: " .. tostring(netId))
                goto continue
            end

            -- flag as being updated
            info.netIdsData[netId].isChecking = true

            -- Get information
            entityHandle = NetworkGetEntityFromNetworkId(netId)
            newOwner = NetworkGetEntityOwner(entityHandle)

            -- Collect NetId of current owner
            if oldOwner == newOwner then
                owningNetIds[netId] = netId
            else
                if not transferredNetIds[newOwner] then
                    transferredNetIds[newOwner] = {}
                end
                transferredNetIds[newOwner][netId] = netId
            end

            -- Update information
            info.netIdsData[netId].handle = entityHandle
            info.netIdsData[netId].owner = newOwner

            -- flag as updating
            info.netIdsData[netId].isChecking = false

            -- Callback when checked
            if info.onCheckOwnership ~= nil then
                info.onCheckOwnership(self, entityHandle, netId, oldOwner, newOwner)
            end

            -- Execute ownership check callback
            if info.netIdsData[netId].callbacks.onCheckOwnership ~= nil then
                info.netIdsData[netId].callbacks.onCheckOwnership(self, entityHandle, netId, oldOwner, newOwner)
            end

            -- If the owner has changed
            if oldOwner ~= newOwner then

                -- Execute ownership update callback
                if info.onUpdateOwnership ~= nil then
                    info.onUpdateOwnership(self, entityHandle, netId, oldOwner, newOwner)
                end

                -- Execute any registered processing if there is one
                if info.netIdsData[netId].callbacks.onUpdateOwnership ~= nil then
                    info.netIdsData[netId].callbacks.onUpdateOwnership(self, entityHandle, netId, oldOwner, newOwner)
                end
            end

            ::continue::
        end

        -- Update of player-managed NetIds
        if next(owningNetIds) ~= nil then
            info.playerToNetIds[oldOwner] = owningNetIds
        else
            info.playerToNetIds[oldOwner] = nil
        end

        -- Transfer the NetId that needs to be transferred to the destination player
        for newOwner, newNetIds in pairs(transferredNetIds) do
            if newOwner ~= 0 then -- Ignore states where there is no owner
                if not info.playerToNetIds[newOwner] then
                    info.playerToNetIds[newOwner] = {}
                end
                for netId, _ in pairs(newNetIds) do
                    info.playerToNetIds[newOwner][netId] = netId
                end
            end
        end
    else

        ---[[
        --- Since the player is offline, reacquire the player who currently has ownership.
        ---]]

        -- NetId owned by an offline player
        for _, netId in pairs(netIds) do

            -- Get information
            local entityHandle = NetworkGetEntityFromNetworkId(netId)
            local newOwner = NetworkGetEntityOwner(entityHandle)

            -- whether a new owner exists
            if info.playerToNetIds[newOwner] == nil then
                info.playerToNetIds[newOwner] = {}
            end

            -- Add to owner
            info.playerToNetIds[newOwner][netId] = netId

            -- Update information
            info.netIdsData[netId].handle = entityHandle
            info.netIdsData[netId].owner = newOwner

            -- Callback when checked
            info.onCheckOwnership(self, entityHandle, netId, oldOwner, newOwner)

            -- Execute ownership check callback
            if info.netIdsData[netId].callbacks.onCheckOwnership ~= nil then
                info.netIdsData[netId].callbacks.onCheckOwnership(self, entityHandle, netId, oldOwner, newOwner)
            end

            -- If the owner has changed
            if oldOwner ~= newOwner then

                -- Execute ownership update callback
                if info.onUpdateOwnership ~= nil then
                    info.onUpdateOwnership(self, entityHandle, netId, oldOwner, newOwner)
                end

                -- Execute any registered processing if there is one
                if info.netIdsData[netId].callbacks.onUpdateOwnership ~= nil then
                    info.netIdsData[netId].callbacks.onUpdateOwnership(self, entityHandle, netId, oldOwner, newOwner)
                end
            end
        end

        -- Empty because it's offline
        info.playerToNetIds[oldOwner] = nil

        utils:debugPrint("[OwnershipManager] Player is offline, rechecking ownership for NetIds: ")
        return false
    end

    return true
end

---Get management information from NetId
---@param netId integer
---@return REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities|nil
function OwnershipManager:getDataByNetId(netId)
    local info = self.info
    local data = info.netIdsData[netId]

    -- Check if netId is registered
    if data == nil then
        utils:debugPrint("[OwnershipManager] NetId is not registered: " .. tostring(netId))
        return nil
    end

    return data
end

return OwnershipManager
