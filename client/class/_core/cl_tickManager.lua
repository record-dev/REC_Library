
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class._Core.TickManagerConfigBuilder
local TickManagerConfigBuilder = require "@REC_Library.client.class._core.cl_tickManagerConfigBuilder"

---@class REC_Library.Client.Class._Core.TickManager
---@field info REC_Library.Client.Class._Core.TickManagerConfigBuilder
---@field callbacks function[] flat copy of the registered functions, rebuilt only when the registry changes
local TickManager = {}
TickManager.__index = TickManager

---instantiation
---@param config REC_Library.Client.Class._Core.TickManagerConfigBuilder ConfigBuilder
---@return self
function TickManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    instance.callbacks = {}
    return instance
end

---[[
---     Flatten the registry into an array so the loop never walks a hash table
---]]
---@private
function TickManager:refresh()
    local callbacks = {}

    for _, func in pairs(self.info.tickFunctions) do
        callbacks[#callbacks+1] = func
    end

    self.callbacks = callbacks
end

---Register the process
---@param key string Unique key used for unregistration
---@param func function Function called every tick
function TickManager:register(key, func)
    local info = self.info

    assert(type(key) == "string", "key must be a string")
    assert(type(func) == "function", "func must be a function")

    -- Register function as key
    info.tickFunctions[key] = func
    self:refresh()

    if info.isLoopActive == false then
        self:startLoop()
    end
end

---Cancel the registered function
---@param key string Unique key to cancel processing
function TickManager:unregister(key)
    local info = self.info

    if info.tickFunctions[key] == nil then
        utils:debugPrint(("^3[TickManager:unregister] function is not founded... key: %s^0"):format(tostring(key)))
        return
    end

    info.tickFunctions[key] = nil
    self:refresh()
end

function TickManager:startLoop()
    local info = self.info

    if info.isLoopActive == true then return end
    info.isLoopActive = true

    Citizen.CreateThread(function (threadId)

        -- Thread ID storage
        info.threadId = threadId

        -- start loop processing
        local callbacks = self.callbacks
        while #callbacks > 0 do

            for i = 1, #callbacks do
                callbacks[i]()
            end

            Citizen.Wait(info.waitTime)

            -- pick up what register / unregister changed while we waited
            callbacks = self.callbacks
        end

        -- the registry drained, let the next register start a new loop
        info.isLoopActive = false
        info.threadId = nil
    end)
end

---Helper function to check if a particular key is registered
---@param key string key
---@return boolean
function TickManager:hasRegistered(key)
    local info = self.info
    return info.tickFunctions[key] ~= nil
end



---[[
---     Shared tick
---     The managers inside the library share one per frame loop instead of each of
---     them opening its own thread. The class above stays available for a resource
---     that wants its own interval through :new().
---]]
---@type REC_Library.Client.Class._Core.TickManager|nil
local sharedTick = nil

---@return REC_Library.Client.Class._Core.TickManager
function TickManager:getShared()

    if sharedTick == nil then
        sharedTick = TickManager:new(TickManagerConfigBuilder:new():setWaitTime(0))
    end

    return sharedTick
end

---Register a function called every frame on the shared loop
---@param key string Unique key used for unregistration
---@param func function
function TickManager:registerTick(key, func)
    TickManager:getShared():register(key, func)
end

---Cancel a function registered on the shared loop
---@param key string
function TickManager:unregisterTick(key)
    TickManager:getShared():unregister(key)
end

return TickManager
