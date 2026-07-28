
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---@class REC_Library.Server.Class.Manager.HeartbeatManager
---@field info REC_Library.Server.Class.Manager.HeartbeatManagerConfigBuilder
local HeartbeatManager = {}
HeartbeatManager.__index = HeartbeatManager

---instantiation
---@param config REC_Library.Server.Class.Manager.HeartbeatManagerConfigBuilder
---@return self
function HeartbeatManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Register handlers for various events
---@return boolean
function HeartbeatManager:init()
    local info = self.info

    -- Confirm event name existence
    if info.registerEvent == nil then
        utils:debugPrint("HeartbeatManager eventName is not set.")
        return false
    end

    -- Check if it has already been initialized
    if info.hasInitialized == true then
        utils:debugPrint("HeartbeatManager is already initialized.")
        return false
    end

    -- Event registration for heartbeat window
    RegisterNetEvent(info.registerEvent, function()
        local src = source

        -- Check if monitoring is in progress
        if info.hasRunningMonitor == false then
            utils:debugPrint("^2HeartbeatManager is not running.^0")
            return
        end

        -- Check if it is monitored
        if info.playerStatus[src] == nil then
            utils:debugPrint("^1HeartbeatManager: Player " .. src .. " is not registered.^0")
            return
        end

        local currentBeat = info.playerStatus[src].missingBeat

        -- Initialize if exists
        info.playerStatus[src].missingBeat = 0

        -- Heartbead Callback
        if info.onHeartbeat ~= nil then
            info.onHeartbeat(self, src, currentBeat, info.playerStatus[src].missingBeat)
        end
    end)

    if info.onPlayerJoined ~= nil then
        AddEventHandler(info.playerJoinedEvent, function (...)
            info.onPlayerJoined(self, source, ...)
        end)
    end

    if info.onPlayerLeft ~= nil then
        AddEventHandler(info.playerLeftEvent, function (...)
            info.onPlayerLeft(self, source, ...)
        end)
    end

    info.hasInitialized = true

    return true
end

---Check existence
---@param src integer player ID
---@param onPlayerMissingBeat? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, beat: integer) Optional processing when determining timeout
---@return boolean
function HeartbeatManager:register(src, onPlayerMissingBeat)
    local info = self.info

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("HeartbeatManager is not initialized.")
        return false
    end

    -- Check if registered
    if info.playerStatus[src] ~= nil then
        utils:debugPrint("HeartbeatManager is already registered for player: " .. src)
        return false
    end

    -- onPlayerMissingBeat confirmation
    if onPlayerMissingBeat ~= nil then
        assert(type(onPlayerMissingBeat) == "function", "onPlayerMissingBeat must be a function")
    end

    -- Heartbeat start command
    TriggerClientEvent(info.startHeartBeatEvent, src)

    -- Registration
    info.playerStatus[src] = {
        missingBeat = 0,
        onPlayerMissingBeat = onPlayerMissingBeat or nil
    }

    utils:debugPrint("HeartbeatManager: Registered player " .. src)

    return true
end

---Check existence
---@param src integer
---@return boolean
function HeartbeatManager:unregister(src)
    local info = self.info

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("HeartbeatManager is not initialized.")
        return false
    end

    -- Check if registered
    if info.playerStatus[src] == nil then
        utils:debugPrint("HeartbeatManager is not registered for player: " .. src)
        return false
    end

    -- Heartbeat stop command
    TriggerClientEvent(info.stopHeartBeatEvent, src)

    -- Unregister
    info.playerStatus[src] = nil

    utils:debugPrint("HeartbeatManager: Unregistered player " .. src)

    return true
end

---Start monitoring
---@return boolean
function HeartbeatManager:start()
    local info = self.info

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("HeartbeatManager is not initialized.")
        return false
    end

    -- Whether loop monitoring is already in progress
    if info.hasRunningMonitor == true then
        utils:debugPrint("HeartbeatManager is already running.")
        return false
    end

    -- Disable monitoring flag
    info.hasRunningMonitor = true

    Citizen.CreateThread(function (threadId)

        -- Store thread ID
        info.thredId = threadId

        -- pure loop
        while info.hasRunningMonitor == true do

            -- Checking the existence information of registered players
            for src, status in pairs(info.playerStatus) do

                -- Counter addition
                info.playerStatus[src].missingBeat = status.missingBeat + 1

                -- If the existence confirmation limit is exceeded
                if info.playerStatus[src].missingBeat > info.maxbeat then

                    -- If any process is registered
                    if info.playerStatus[src].onPlayerMissingBeat ~= nil then
                        info.playerStatus[src].onPlayerMissingBeat(
                            self,
                            src,
                            info.playerStatus[src].missingBeat
                        )
                    end

                    -- if kicking players is enabled
                    if info.isEnableDropWhenMissingBeat == true then
                        DropPlayer(src, "Connection timed out (Heartbeat lost).")
                    end
                end
            end

            Citizen.Wait(info.waitTime)
        end

        -- Stop command
        -- self:stop()
    end)

    return true
end

---Loop monitoring stop command
---@return boolean
function HeartbeatManager:stop()
    local info = self.info

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("HeartbeatManager is not initialized.")
        return false
    end

    -- Whether loop monitoring is already in progress
    if info.hasRunningMonitor == false then
        utils:debugPrint("HeartbeatManager is not running.")
        return false
    end

    utils:debugPrint(("HeartbeatManager was stopped. Thread ID: %d"):format(info.thredId))

    info.hasRunningMonitor = false
    info.thredId = nil

    return true
end

return HeartbeatManager
