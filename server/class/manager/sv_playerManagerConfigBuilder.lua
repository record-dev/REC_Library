
---@class REC_Library.Server.Class.Manager.PlayerManagerConfig
---@field threadId? integer
---@field sendMessageEvent? string
---@field wazitTime integer
---@field players table<string, REC_Library.Server.Class.Player.Player>
---@field onStart? fun(self: REC_Library.Server.Class.Manager.PlayerManager)
---@field onStop? fun(self: REC_Library.Server.Class.Manager.PlayerManager)
---@field onRegistered? fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player)
---@field onUnregistered? fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player)
---@field onUpdated? fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player)
---@field onRoutingBucketChanged? fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player, oldBucket: integer, newBucket: integer)
---@field onPlayerConnecting? fun(self: REC_Library.Server.Class.Manager.PlayerManager, playerSrc: integer, playerName: string, setKickReason: fun(reason: string), deferrals: { defer: any, done: any, handover: any, presentCard: any, update: any })
---@field onPlayerJoined? fun(self: REC_Library.Server.Class.Manager.PlayerManager, playerSrc: string, ...)
---@field onPlayerDropped? fun(self: REC_Library.Server.Class.Manager.PlayerManager, playerSrc: string, ...)
---@field hasInitialized boolean
---@field isMonitorActive boolean

---@class REC_Library.Server.Class.Manager.PlayerManagerConfigBuilder: REC_Library.Server.Class.Manager.PlayerManagerConfig
local PlayerManagerConfigBuilder = {}
PlayerManagerConfigBuilder.__index = PlayerManagerConfigBuilder

---instantiation
---@return self
function PlayerManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.players = {}
    instance.waitTime = 1000
    instance.hasInitialized = false
    instance.isMonitorActive = false
    return instance
end

---Setting standby time
---@param waitTime integer|nil Default: 1200
---@return self
function PlayerManagerConfigBuilder:setWaitTime(waitTime)
    if waitTime == nil then return self end
    assert(type(waitTime) == "number", "waitTime must be a number")
    self.waitTime = waitTime
    return self
end

---@param sendMessageEvent string|nil
---@return self
function PlayerManagerConfigBuilder:setSendMessageEvent(sendMessageEvent)
    if sendMessageEvent == nil then return self end
    assert(type(sendMessageEvent) == "string", "sendMessageEvent must be a string")
    self.sendMessageEvent = sendMessageEvent
    return self
end

---Callback when monitoring starts
---@param onStart fun(self: REC_Library.Server.Class.Manager.PlayerManager)|nil
---@return self
function PlayerManagerConfigBuilder:setOnStart(onStart)
    if onStart == nil then return self end
    assert(type(onStart) == "function", "onStart must be a function")
    self.onStart = onStart
    return self
end

---Callback when monitoring stops
---@param onStop fun(self: REC_Library.Server.Class.Manager.PlayerManager)|nil
---@return self
function PlayerManagerConfigBuilder:setOnStop(onStop)
    if onStop == nil then return self end
    assert(type(onStop) == "function", "onStop must be a function")
    self.onStop = onStop
    return self
end

---Callback when registering a player
---@param onRegistered fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player)|nil
---@return self
function PlayerManagerConfigBuilder:setOnRegistered(onRegistered)
    if onRegistered == nil then return self end
    assert(type(onRegistered) == "function", "onRegistered must be a function")
    self.onRegistered = onRegistered
    return self
end

---Callback when updating player
---@param onUpdated fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player)|nil
---@return self
function PlayerManagerConfigBuilder:setOnUpdate(onUpdated)
    if onUpdated == nil then return self end
    assert(type(onUpdated) == "function", "onUpdated must be a function")
    self.onUpdated = onUpdated
    return self
end

---Callback when routing bucket changes
---@param onRoutingBucketChanged fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player, oldBucket: integer, newBucket: integer)|nil
---@return self
function PlayerManagerConfigBuilder:setOnRoutingBucketChanged(onRoutingBucketChanged)
    if onRoutingBucketChanged == nil then return self end
    assert(type(onRoutingBucketChanged) == "function", "onRoutingBucketChanged must be a function")
    self.onRoutingBucketChanged = onRoutingBucketChanged
    return self
end

---Callback when canceling player registration
---@param onUnregistered fun(self: REC_Library.Server.Class.Manager.PlayerManager, player: REC_Library.Server.Class.Player.Player)|nil
---@return self
function PlayerManagerConfigBuilder:setOnUnregistered(onUnregistered)
    if onUnregistered == nil then return self end
    assert(type(onUnregistered) == "function", "onUnregistered must be a function")
    self.onUnregistered = onUnregistered
    return self
end

---Corback when connecting player
---@param onPlayerConnecting fun(self: REC_Library.Server.Class.Manager.PlayerManager, playerSrc: integer, playerName: string, setKickReason: fun(reason: string), deferrals: { defer: any, done: any, handover: any, presentCard: any, update: any })|nil
---@return self
function PlayerManagerConfigBuilder:setOnPlayerConnecting(onPlayerConnecting)
    if onPlayerConnecting == nil then return self end
    assert(type(onPlayerConnecting) == "function", "onPlayerConnecting must be a function")
    self.onPlayerConnecting = onPlayerConnecting
    return self
end

---Corback when player joins
---@param onPlayerJoined fun(self: REC_Library.Server.Class.Manager.PlayerManager, playerSrc: string, ...)|nil
---@return self
function PlayerManagerConfigBuilder:setOnPlayerJoined(onPlayerJoined)
    if onPlayerJoined == nil then return self end
    assert(type(onPlayerJoined) == "function", "onPlayerJoined must be a function")
    self.onPlayerJoined = onPlayerJoined
    return self
end


---Corback when player disconnects
---@param onPlayerDropped fun(self: REC_Library.Server.Class.Manager.PlayerManager, playerSrc: string, ...)|nil
---@return self
function PlayerManagerConfigBuilder:setOnPlayerDropped(onPlayerDropped)
    if onPlayerDropped == nil then return self end
    assert(type(onPlayerDropped) == "function", "onPlayerDropped must be a function")
    self.onPlayerDropped = onPlayerDropped
    return self
end

---Configure custom properties
---@param properties table<string, any>[]|nil
---@return self
function PlayerManagerConfigBuilder:setCustomProperties(properties)
    if properties == nil then return self end
    for k, v in pairs(properties) do
        if v ~= nil then self[k] = v end
    end
    return self
end

return PlayerManagerConfigBuilder
