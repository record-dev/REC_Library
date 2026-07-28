
---@class REC_Library.Client.Class._Core.TickManagerConfig
---@field resourceName string
---@field tickFunctions table<string, function>
---@field isLoopActive boolean
---@field threadId? integer
---@field waitTime integer

---@class REC_Library.Client.Class._Core.TickManagerConfigBuilder: REC_Library.Client.Class._Core.TickManagerConfig
local TickManagerConfigBuilder = {}
TickManagerConfigBuilder.__index = TickManagerConfigBuilder

---instantiation
---@return self
function TickManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.resourceName = GetCurrentResourceName()
    instance.tickFunctions = {}
    instance.waitTime = 1000
    instance.isLoopActive = false
    return instance
end

---Set Wait time
---@param waitTime integer|nil Wait wait time
---@return self
function TickManagerConfigBuilder:setWaitTime(waitTime)
    if waitTime == nil then return self end
    assert(type(waitTime) == "number", "waitTime must be a number or integer")
    self.waitTime = waitTime
    return self
end

---Return table without method
---@return REC_Library.Client.Class._Core.TickManagerConfig
function TickManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil and type(v) == "function" then
            finalOptions[k] = v
        end
    end
    return finalOptions
end

return TickManagerConfigBuilder
