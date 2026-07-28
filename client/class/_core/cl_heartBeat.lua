
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"


---@class REC_Library.Client.Class._Core.Heartbeat
---@field info REC_Library.Client.Class._Core.HeartbeatConfigBuilder
local Heartbeat = {}
Heartbeat.__index = Heartbeat

---instantiation
---@param config REC_Library.Client.Class._Core.HeartbeatConfigBuilder
---@return self
function Heartbeat:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Event registration
---@return boolean
function Heartbeat:init()
    local info = self.info

    -- start event
    RegisterNetEvent(info.startEvent, function (...)
        self:start()
    end)

    -- stop event
    RegisterNetEvent(info.stopEvent, function (...)
        self:stop()
    end)

    return true
end

---Start heartbeat
---@private
---@return boolean
function Heartbeat:start()
    local info = self.info

    -- Ongoing confirmation
    if info.isActive == true then
        utils:debugPrint("Heartbeat is already active.")
        return false
    end

    Citizen.CreateThread(function (threadId)

        -- Store thread ID
        info.threadId = threadId

        -- flag enabled
        info.isActive = true

        while info.isActive == true do

            -- trigger server event
            TriggerServerEvent(info.triggerEvent)

            -- If there is a callback on heartbeat
            if info.onHeatbeat ~= nil then
                info.onHeatbeat(self)
            end

            Citizen.Wait(info.waitTime)
        end
    end)

    -- if callback is registered
    if info.onStart ~= nil then
        info.onStart(self)
    end

    return true
end

---Heartbeat stopped
---@private
---@return boolean
function Heartbeat:stop()
    local info = self.info

    -- Ongoing confirmation
    if info.isActive == false then
        utils:debugPrint("Heartbeat is not active.")
        return false
    end

    -- disable
    info.isActive = false

    -- if callback is registered
    if info.onStop ~= nil then
        info.onStop(self)
    end

    return true
end

return Heartbeat
