
local validator = require "@REC_Library.shared.sh_validator"

---@class REC_Library.Server.Class.Simulator.TrackSimulatorConfig
---@field trackNodes table<integer, vector3>
---@field currentNodeIndex integer
---@field timeAtNode number
---@field trainHandle? integer
---@field carriagesHandles? table<integer, integer>
---@field onStartMonitor? fun(self: REC_Library.Server.Class.Simulator.TrackSimulator)
---@field onStopMonitor? fun(self: REC_Library.Server.Class.Simulator.TrackSimulator)
---@field onCurrentTrackNodeIndexChanged? fun(self: REC_Library.Server.Class.Simulator.TrackSimulator)
---@field waitTime number
---@field threadId? integer
---@field hasRunningMonitor boolean

---@class REC_Library.Server.Class.Simulator.TrackSimulatorConfigBuilder: REC_Library.Server.Class.Simulator.TrackSimulatorConfig
local TrainManagerConfigBuilder = {}
TrainManagerConfigBuilder.__index = TrainManagerConfigBuilder

---instantiation
---@param trackNodes table<integer, vector3>
---@return self
function TrainManagerConfigBuilder:new(trackNodes)
    assert(validator.isNull(trackNodes) == false, "")
    local instance = setmetatable({}, self)
    instance.trackNodes = trackNodes
    instance.currentNodeIndex = 1
    instance.hasRunningMonitor = false
    instance.waitTime = 1000
    return instance
end

---@param waitTime number|nil
---@return self
function TrainManagerConfigBuilder:setWaitTime(waitTime)
    if waitTime == nil then return self end
    assert(type(waitTime) == "number", "waitTime must be a number")
    self.waitTime = waitTime
    return self
end

---@param onStartMonitor fun(self: REC_Library.Server.Class.Simulator.TrackSimulator)|nil
---@return self
function TrainManagerConfigBuilder:setOnStartMonitor(onStartMonitor)
    if onStartMonitor == nil then return self end
    self.onStartMonitor = onStartMonitor
    return self
end

---@param onStopMonitor fun(self: REC_Library.Server.Class.Simulator.TrackSimulator)|nil
---@return self
function TrainManagerConfigBuilder:setOnStopMonitor(onStopMonitor)
    if onStopMonitor == nil then return self end
    self.onStopMonitor = onStopMonitor
    return self
end

---@param onCurrentTrackNodeIndexChanged fun(self: REC_Library.Server.Class.Simulator.TrackSimulator)|nil
---@return self
function TrainManagerConfigBuilder:setOnCurrentTrackNodeIndexChanged(onCurrentTrackNodeIndexChanged)
    if onCurrentTrackNodeIndexChanged == nil then return self end
    assert(type(onCurrentTrackNodeIndexChanged) == "function", "")
    self.onCurrentTrackNodeIndexChanged = onCurrentTrackNodeIndexChanged
    return self
end

---@return REC_Library.Server.Class.Simulator.TrackSimulatorConfig
function TrainManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return TrainManagerConfigBuilder
