
---[[
--- Class with haste management responsibilities
---]]

local ServerManager = require "@REC_Library.server.class.manager.sv_serverManager"

---@class REC_Library.Server.Class.Manager.HeistManager: REC_Library.Server.Class.Manager.ServerManager
---@field info REC_Library.Server.Class.Manager.HeistManagerConfigBuilder
local HeistManager = {}
setmetatable(HeistManager, { __index = ServerManager })
HeistManager.__index = HeistManager

---instantiation
---@param config REC_Library.Server.Class.Manager.HeistManagerConfigBuilder
---@return self
function HeistManager:new(config)
    local instance = ServerManager:new(config)
    ---@cast instance REC_Library.Server.Class.Manager.HeistManager

    setmetatable(instance, self)
    instance.info = config
    return instance
end

---Check if Haste orders can be accepted
---@param ... any
---@return boolean, string?
function HeistManager:init(...)
    return self.info.onInit(self, ...)
end

---Check if Haste orders can be accepted
---@param ... any
---@return boolean, string?
function HeistManager:canOrder(...)
    return self.info.onCanOrder(self, ...)
end

---Haste order
---@param ... any
---@return boolean, string?
function HeistManager:order(...)
    return self.info.onOrder(self, ...)
end

---Check if haste setup is possible
---@param ... any
---@return boolean, string?
function HeistManager:canSetup(...)
    return self.info.onCanSetup(self, ...)
end

---Haste setup
---@return boolean, string?
function HeistManager:setup(...)
    return self.info.onSetup(self, ...)
end

---Check if it is possible to start haste
---@return boolean, string?
function HeistManager:canStart(...)
    return self.info.onCanStart(self, ...)
end

---Start of Haste
---@return boolean, string?
function HeistManager:start(...)
    return self.info.onStart(self, ...)
end

---Check whether it is possible to move to the next phase
---@return boolean, string?
function HeistManager:canNextPhase(...)
    return self.info.onCanNextPhase(self, ...)
end

---Move to next phase
---@return boolean, string?
function HeistManager:nextPhase(...)
    return self.info.onNextPhase(self, ...)
end


---Check if it is possible to end the haste
---@return boolean, string?
function HeistManager:canComplete(...)
    return self.info.onCanComplete(self, ...)
end

---End of haste
---@return boolean, string?
function HeistManager:complete(...)
    return self.info.onComplete(self, ...)
end

---Check if haste can be reset
---@return boolean, string?
function HeistManager:canReset(...)
    return self.info.onCanReset(self, ...)
end

---Haste reset
---@return boolean, string?
function HeistManager:reset(...)
    return self.info.onReset(self, ...)
end

return HeistManager
