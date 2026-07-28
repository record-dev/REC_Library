
---@class REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder
---@field resourceName string
---@field waitTime number
---@field threadId? number thread ID
---@field playerToNetIds table<number, number[]> Array for linking owner and net ID
---@field netIdsData table<number, REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities> Array for linking net IDs to owners
---@field onRegister? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, netId: number)
---@field onUnregister? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, netId: number)
---@field onStart? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, ...)
---@field onStop? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, ...)
---@field onCheckOwnership? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number)
---@field onUpdateOwnership? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number, reason?: string)
---@field hasRunningMonitor boolean
local OwnershipManagerConfigBuilder = {}
OwnershipManagerConfigBuilder.__index = OwnershipManagerConfigBuilder

---instantiation
---@return self
function OwnershipManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.resourceName = GetCurrentResourceName()
    instance.waitTime = 1000
    instance.playerToNetIds = {}
    instance.netIdsData = {}
    instance.hasRunningMonitor = false
    return instance
end

---@param waitTime number|nil Default 1000 (1 second)
---@return self chain method
function OwnershipManagerConfigBuilder:setWaitTime(waitTime)
    if waitTime == nil then return self end
    assert(type(waitTime) == "number")
    self.waitTime = waitTime
    return self
end

---Callback when registering
---@param onRegister fun(self: REC_Library.Server.Class.Manager.OwnershipManager, netId: number)|nil
---@return self callback
function OwnershipManagerConfigBuilder:setOnRegister(onRegister)
    if onRegister == nil then return self end
    assert(onRegister ~= nil and type(onRegister) == "function")
    self.onRegister = onRegister
    return self
end

---Callback when unregistering
---@param onUnregister fun(self: REC_Library.Server.Class.Manager.OwnershipManager, netId: number)|nil
---@return self callback
function OwnershipManagerConfigBuilder:setOnUnregister(onUnregister)
    if onUnregister == nil then return self end
    assert(onUnregister ~= nil and type(onUnregister) == "function")
    self.onUnregister = onUnregister
    return self
end

---Callback at start
---@param onStart fun(self: REC_Library.Server.Class.Manager.OwnershipManager, ...)|nil
---@return self callback
function OwnershipManagerConfigBuilder:setOnStart(onStart)
    if onStart == nil then return self end
    assert(onStart ~= nil and type(onStart) == "function")
    self.onStart = onStart
    return self
end

---Callback on exit
---@param onStop fun(self: REC_Library.Server.Class.Manager.OwnershipManager, ...)|nil
---@return self callback
function OwnershipManagerConfigBuilder:setOnStop(onStop)
    if onStop == nil then return self end
    assert(onStop ~= nil and type(onStop) == "function")
    self.onStop = onStop
    return self
end

---Callback during ownership confirmation
---@param onCheckOwnership fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number)|nil
---@return self callback
function OwnershipManagerConfigBuilder:setOnCheckOwnership(onCheckOwnership)
    if onCheckOwnership == nil then return self end
    assert(onCheckOwnership ~= nil and type(onCheckOwnership) == "function")
    self.onCheckOwnership = onCheckOwnership
    return self
end

---Callback when updating ownership
---@param onUpdateOwnership fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number, reason?: string)|nil
---@return self callback
function OwnershipManagerConfigBuilder:setOnUpdateOwnership(onUpdateOwnership)
    if onUpdateOwnership == nil then return self end
    assert(onUpdateOwnership ~= nil and type(onUpdateOwnership) == "function")
    self.onUpdateOwnership = onUpdateOwnership
    return self
end

---Build and return with table without table method
---@return table
function OwnershipManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

---@class REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities
---@field handle number Entity handle
---@field owner number ID of the player who has ownership
---@field callbacks REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities.Callbacks
---@field isChecking boolean Flag whether checking is in progress
---@field isUnregisting boolean Is it being canceled?

---@class REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities.Callbacks
---@field [string] fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number)
---@field onUnregister? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, newOwner: number)
---@field onCheckOwnership? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number)
---@field onUpdateOwnership? fun(self: REC_Library.Server.Class.Manager.OwnershipManager, handle: number, netId: number, oldOwner: number, newOwner: number)

return OwnershipManagerConfigBuilder
