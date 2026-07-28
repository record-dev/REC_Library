
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class._Core.TickManager
---@field info REC_Library.Client.Class._Core.TickManagerConfigBuilder
local TickManager = {}
TickManager.__index = TickManager

---instantiation
---@param config REC_Library.Client.Class._Core.TickManagerConfigBuilder ConfigBuilder
---@return self
function TickManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Register the process
---@param key string Unique key used for unregistration
---@param func function Function called every frame
function TickManager:register(key, func)
    local info = self.info

    -- Register function as key
    info.tickFunctions[key] = func
    if info.isLoopActive == false then
        self:startLoop()
    end
end

---Cancel the registered function
---@param key string Unique key to cancel processing
function TickManager:unregister(key)
    local info = self.info
    if info.tickFunctions[key] ~= nil then
        info.tickFunctions[key] = nil
    else
        utils:debugPrint("[TickManager:unregister] Error: No function registered with key '" .. key .. "'.")
    end
end

function TickManager:startLoop()
    local info = self.info

    if info.isLoopActive then return end
    info.isLoopActive = true
    Citizen.CreateThread(function (threadId)

        -- Thread ID storage
        info.threadId = threadId

        -- start loop processing
        while next(info.tickFunctions) ~= nil do
            for _, func in pairs(info.tickFunctions) do
                if type(func) == "function" then
                    func()
                end
            end
            Citizen.Wait(info.waitTime)
        end

    end)
end

---Helper function to check if a particular key is registered
---@param key string key
---@return boolean
function TickManager:hasRegistered(key)
    local info = self.info
    return info.tickFunctions[key] ~= nil
end

return TickManager
