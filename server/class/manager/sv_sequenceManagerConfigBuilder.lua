
---@class REC_Library.Server.Class.Manager.SequenceManagerConfigBuilder
---@field currentId integer
---@field sequenceFunctions table<integer, REC_Library.Server.Class.Manager.SequenceManagerConfigBuilder.SequenceFunctions>
---@field onError? fun(self: REC_Library.Server.Class.Manager.SequenceManager, error: string)
---@field onFinallyCallback? function
---@field hasFinallyCallbackCalled boolean
local SequenceManagerConfigBuilder = {}
SequenceManagerConfigBuilder.__index = SequenceManagerConfigBuilder

---instantiation
---@return self
function SequenceManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.currentId = 0
    instance.sequenceFunctions = {}
    instance.hasFinallyCallbackCalled = false
    return instance
end

---Function registration in sequence-by-sequence order
---@param canExecute fun(self: REC_Library.Server.Class.Manager.SequenceManager): boolean A function that determines whether the function specified as the first argument can be executed.
---@param main fun(self: REC_Library.Server.Class.Manager.SequenceManager): boolean Main processing
---@return self
function SequenceManagerConfigBuilder:setSequenceFunction(canExecute, main)
    if main == nil then return self end
    self.sequenceFunctions[#self.sequenceFunctions+1] = {
        canExecute = canExecute,
        main = main,
    }
    return self
end

---Callback function when sequence function execution returns false
---@param onError fun(self: REC_Library.Server.Class.Manager.SequenceManager, error: string)|nil error callback
---@return self
function SequenceManagerConfigBuilder:setOnErrorCallback(onError)
    if onError == nil then return self end
    self.onError = onError
    return self
end

---Callback function after the last sequence has finished executing
---@param onFinallyCallback fun(self: REC_Library.Server.Class.Manager.SequenceManager)|nil
---@return self
function SequenceManagerConfigBuilder:setOnFinallyCallback(onFinallyCallback)
    if onFinallyCallback == nil then return self end
    self.onFinallyCallback = onFinallyCallback
    return self
end

---Build and return in table format
---@return table
function SequenceManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

---@class REC_Library.Server.Class.Manager.SequenceManagerConfigBuilder.SequenceFunctions
---@field main fun(self: REC_Library.Server.Class.Manager.SequenceManager)
---@field canExecute fun(self: REC_Library.Server.Class.Manager.SequenceManager): boolean

return SequenceManagerConfigBuilder
