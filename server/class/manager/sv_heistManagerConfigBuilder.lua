

-- Parent class
---@type REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
local ServerManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_serverManagerConfigBuilder"

---@class REC_Library.Server.Class.Manager.HeistManagerConfigBuilder: REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
---@field onInit? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean
---@field onCanOrder? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onOrder? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onCanSetup? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onSetup? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onCanStart? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onStart? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onCanNextPhase fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onNextPhase? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onCanComplete? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onComplete? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onCanReset? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field onReset? fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@field isActive boolean
local HeistManagerConfigBuilder = {}
setmetatable(HeistManagerConfigBuilder, { __index = ServerManagerConfigBuilder })
HeistManagerConfigBuilder.__index = HeistManagerConfigBuilder

---Generation of instance
---@return self
function HeistManagerConfigBuilder:new()
    local instance = ServerManagerConfigBuilder:new()
    ---@cast instance REC_Library.Server.Class.Manager.HeistManagerConfigBuilder

    setmetatable(instance, self)
    instance.isActive = false
    return instance
end

---@param onInit fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean
---@return self
function HeistManagerConfigBuilder:setOnInit(onInit, ...)
    if onInit == nil then return self end
    assert(type(onInit) == "function", "onInit must be a function")
    self.onInit = onInit
    return self
end

---Setter chain method
---@param onCanOrder fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnCanOrder(onCanOrder)
    if onCanOrder == nil then return self end
    assert(type(onCanOrder) == "function", "onCanOrder must be a function")
    self.onCanOrder = onCanOrder
    return self
end

---Setter chain method
---@param onOrder fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self
function HeistManagerConfigBuilder:setOnOrder(onOrder)
    if onOrder == nil then return self end
    assert(type(onOrder) == "function", "onOrder must be a function")
    self.onOrder = onOrder
    return self
end

---Setter chain method
---@param onCanSetup fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnCanSetup(onCanSetup)
    if onCanSetup == nil then return self end
    assert(type(onCanSetup) == "function", "onCanSetup must be a function")
    self.onCanSetup = onCanSetup
    return self
end

---Setter chain method
---@param onSetup fun( self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnSetup(onSetup)
    if onSetup == nil then return self end
    assert(type(onSetup) == "function", "onSetup must be a function")
    self.onSetup = onSetup
    return self
end

---Setter chain method
---@param onCanStart fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnCanStart(onCanStart)
    if onCanStart == nil then return self end
    assert(type(onCanStart) == "function", "onCanStart must be a function")
    self.onCanStart = onCanStart
    return self
end

---Setter chain method
---@param onStart fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self
function HeistManagerConfigBuilder:setOnStart(onStart)
    if onStart == nil then return self end
    assert(type(onStart) == "function", "onStart must be a function")
    self.onStart = onStart
    return self
end

---Setter chain method
---@param onCanNextPhase fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self
function HeistManagerConfigBuilder:setOnCanNextPhase(onCanNextPhase)
    if onCanNextPhase == nil then return self end
    assert(type(onCanNextPhase) == "function", "onCanNextPhase must be a function")
    self.onCanNextPhase = onCanNextPhase
    return self
end

---Setter chain method
---@param onNextPhase fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self
function HeistManagerConfigBuilder:setOnNextPhase(onNextPhase)
    if onNextPhase == nil then return self end
    assert(type(onNextPhase) == "function", "onNextPhase must be a function")
    self.onNextPhase = onNextPhase
    return self
end

---Setter chain method
---@param onCanComplete fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnCanComplete(onCanComplete)
    if onCanComplete == nil then return self end
    assert(type(onCanComplete) == "function", "onCanComplete must be a function")
    self.onCanComplete = onCanComplete
    return self
end

---Setter chain method
---@param onComplete fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnComplete(onComplete)
    if onComplete == nil then return self end
    assert(type(onComplete) == "function", "onComplete must be a function")
    self.onComplete = onComplete
    return self
end

---Setter chain method
---@param onCanReset fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnCanReset(onCanReset)
    if onCanReset == nil then return self end
    assert(type(onCanReset) == "function", "onCanReset must be a function")
    self.onCanReset = onCanReset
    return self
end

---Setter chain method
---@param onReset fun(self: REC_Library.Server.Class.Manager.HeistManager, ...): boolean, string?
---@return self chain method
function HeistManagerConfigBuilder:setOnReset(onReset)
    if onReset == nil then return self end
    assert(type(onReset) == "function", "onReset must be a function")
    self.onReset = onReset
    return self
end

---@return table Built table format
function HeistManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return HeistManagerConfigBuilder
