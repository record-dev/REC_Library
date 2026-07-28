
---@class REC_Library.Client.Class._Core.HeartbeatConfig
---@field triggerEvent string
---@field startEvent string
---@field stopEvent string
---@field onStart? fun(self: REC_Library.Client.Class._Core.Heartbeat)
---@field onStop? fun(self: REC_Library.Client.Class._Core.Heartbeat)
---@field onHeatbeat? fun(self: REC_Library.Client.Class._Core.Heartbeat)
---@field threadId? integer
---@field waitTime integer
---@field isActive boolean

---@class REC_Library.Client.Class._Core.HeartbeatConfigBuilder: REC_Library.Client.Class._Core.HeartbeatConfig
local HeartbeatConfigBuilder = {}
HeartbeatConfigBuilder.__index = HeartbeatConfigBuilder

---instantiation
---@param triggerEvent string Server event name for beetroot trigger
---@param startEvent string Name of the event that receives the heartbead start command
---@param stopEvent string Event name to receive heartbeat stop command
---@return self
function HeartbeatConfigBuilder:new(triggerEvent, startEvent, stopEvent)
    assert(triggerEvent ~= nil and type(triggerEvent) == "string", "triggerEvent must be a string")
    assert(startEvent ~= nil and type(startEvent) == "string", "startEvent must be a string")
    assert(stopEvent ~= nil and type(stopEvent) == "string", "stopEvent must be a string")
    local instance = setmetatable({}, self)
    instance.triggerEvent = triggerEvent
    instance.startEvent = startEvent
    instance.stopEvent = stopEvent
    instance.waitTime = 1000
    instance.isActive = false
    return instance
end

---Callback when start command is issued
---@param onStart fun(self: REC_Library.Client.Class._Core.Heartbeat)|nil
---@return self
function HeartbeatConfigBuilder:setOnStart(onStart)
    if onStart == nil then return self end
    assert(type(onStart) == "function", "onStart must be a function")
    self.onStart = onStart
    return self
end

---Callback when a stop command is issued
---@param onStop fun(self: REC_Library.Client.Class._Core.Heartbeat)|nil
---@return self
function HeartbeatConfigBuilder:setOnStop(onStop)
    if onStop == nil then return self end
    assert(type(onStop) == "function", "onStart must be a function")
    self.onStop = onStop
    return self
end

---Callback on heartbeat
---@param onHeatbeat fun(self: REC_Library.Client.Class._Core.Heartbeat)|nil
---@return self
function HeartbeatConfigBuilder:setHeartBeat(onHeatbeat)
    if onHeatbeat == nil then return self end
    assert(type(onHeatbeat) == "function", "onHeatbeat must be a function")
    self.onHeatbeat = onHeatbeat
    return self
end

---Definition of waiting time
---@param waitTime integer|nil
---@return self
function HeartbeatConfigBuilder:setWaitTime(waitTime)
    if waitTime == nil then return self end
    assert(type(waitTime) == "number", "waitTime must be a number")
    self.waitTime = waitTime
    return self
end

return HeartbeatConfigBuilder
