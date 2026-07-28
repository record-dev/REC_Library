
---@class REC_Library.Server.Class.Manager.HeartbeatManagerConfig
---@field playerStatus table<string, REC_Library.Server.Class.Manager.HeartbeatManagerConfigBuilder.PlayerStatus>
---@field registerEvent string
---@field startHeartBeatEvent string
---@field stopHeartBeatEvent string
---@field playerJoinedEvent string
---@field playerLeftEvent string
---@field waitTime integer
---@field maxbeat integer
---@field thredId integer
---@field onPlayerJoined? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, ...)
---@field onPlayerLeft? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, ...)
---@field onHeartbeat? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, oldBeat: integer, newBeat: integer)
---@field onMissingBeat? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, beat: integer)
---@field hasInitialized boolean
---@field hasRunningMonitor boolean
---@field isEnableDropWhenMissingBeat boolean

---@class REC_Library.Server.Class.Manager.HeartbeatManagerConfigBuilder: REC_Library.Server.Class.Manager.HeartbeatManagerConfig
local HeartbeatManagerConfigBuilder = {}
HeartbeatManagerConfigBuilder.__index = HeartbeatManagerConfigBuilder

---instantiation
---@param registerEvent string Survival confirmation event name
---@param startHeartBeatEvent string Heartbeat start command
---@param stopHeartBeatEvent string Heartbeat stop command
---@return self
function HeartbeatManagerConfigBuilder:new(registerEvent, startHeartBeatEvent, stopHeartBeatEvent)
    assert(registerEvent ~= nil and type(registerEvent) == "string", "eventName must be a string")
    assert(startHeartBeatEvent ~= nil and type(startHeartBeatEvent) == "string", "startHeartBeatEvent must be a string")
    assert(stopHeartBeatEvent ~= nil and type(stopHeartBeatEvent) == "string", "stopHeartBeatEvent must be a string")
    local instance = setmetatable({}, self)
    instance.registerEvent = registerEvent
    instance.startHeartBeatEvent = startHeartBeatEvent
    instance.stopHeartBeatEvent = stopHeartBeatEvent
    instance.playerJoinedEvent = "playerJoining"
    instance.playerLeftEvent = "playerDropped"
    instance.playerStatus = {}
    instance.waitTime = 500
    instance.maxbeat = 2
    instance.hasInitialized = false
    instance.hasRunningMonitor = false
    instance.isEnableDropWhenMissingBeat = false
    return instance
end

---Event registration when a player joins the server
---@param playerJoinedEvent? string To override the joined event name on the server
---@param onPlayerJoined? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, ...) Processing when a player joins
---@return self
function HeartbeatManagerConfigBuilder:setPlayerJoinedEvent(playerJoinedEvent, onPlayerJoined)
    if playerJoinedEvent ~= nil then
        assert(type(playerJoinedEvent) == "string", "playerJoinedEvent must be a  string")
        self.playerJoinedEvent = playerJoinedEvent
    end
    if onPlayerJoined ~= nil then
        assert(type(onPlayerJoined) == "function", "onPlayerJoined must be a function")
        self.onPlayerJoined = onPlayerJoined
    end
    return self
end

---Event registration when a player leaves the server
---@param playerLeftEvent? string To overwrite the event name left from the server
---@param onPlayerLeft? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, ...) Processing when a player leaves
---@return self
function HeartbeatManagerConfigBuilder:setPlayerLeftEvent(playerLeftEvent, onPlayerLeft)
    if playerLeftEvent ~= nil then
        assert(type(playerLeftEvent) == "string", "playerLeftEvent must be a string")
        self.playerLeftEvent = playerLeftEvent
    end
    if onPlayerLeft ~= nil then
        assert(type(onPlayerLeft) == "function", "onPlayerLeft must be a function")
        self.onPlayerLeft = onPlayerLeft
    end
    return self
end

---@param waitTime integer|nil
---@return self
function HeartbeatManagerConfigBuilder:setWaitTime(waitTime)
    if waitTime == nil then return self end
    assert(type(waitTime) == "number", "waitTime must be a number")
    self.waitTime = waitTime
    return self
end

---`Upper limit on the number of times survival confirmation could not be obtained`
---Default: 2
---@param maxbeat integer|nil
---@return self
function HeartbeatManagerConfigBuilder:setMaxMissedBeats(maxbeat)
    if maxbeat == nil then return self end
    assert(type(maxbeat) == "number", "maxbeat must be a number")
    self.maxbeat = maxbeat
    return self
end

---`Determine whether to kick from server`
---@param bool boolean|nil
---@return self
function HeartbeatManagerConfigBuilder:setEnableDropWhenMissingBeat(bool)
    if bool == nil then return self end
    assert(type(bool) == "boolean", "bool must be a number")
    self.isEnableDropWhenMissingBeat = bool
    return self
end

---When someone's existence check event comes
---@param onHeartbeat fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, oldBeat: integer, newBeat: integer)
---@return self
function HeartbeatManagerConfigBuilder:setOnHeartbeat(onHeartbeat)
    if onHeartbeat == nil then return self end
    assert(type(onHeartbeat) == "function", "onHeatbeat must be a function")
    self.onHeartbeat = onHeartbeat
    return self
end

---If someone's presence check stops
---@param onMissingBeat fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, beat: integer)|nil
---@return self
function HeartbeatManagerConfigBuilder:setOnMissingBeat(onMissingBeat)
    if onMissingBeat == nil then return self end
    assert(type(onMissingBeat) == "function", "onMissingBeat must be a function")
    self.onMissingBeat = onMissingBeat
    return self
end

---@class REC_Library.Server.Class.Manager.HeartbeatManagerConfigBuilder.PlayerStatus
---@field missingBeat integer
---@field onPlayerMissingBeat? fun(self: REC_Library.Server.Class.Manager.HeartbeatManager, playerSrc: integer, beat: integer)

return HeartbeatManagerConfigBuilder
