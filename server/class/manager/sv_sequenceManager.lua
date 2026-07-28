
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
--- Class responsible for playing in sequence
---]]

---@class REC_Library.Server.Class.Manager.SequenceManager
---@field info REC_Library.Server.Class.Manager.SequenceManagerConfigBuilder
local SequenceManager = {}
SequenceManager.__index = SequenceManager

---instantiation
---@param config REC_Library.Server.Class.Manager.SequenceManagerConfigBuilder
---@return self
function SequenceManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Execute the next sequence of the current sequence
---@return boolean
function SequenceManager:executeNext()
    local info = self.info

    -- Check if the last callback has been executed
    if info.hasFinallyCallbackCalled == true then
        utils:debugPrint("The final callback has already been executed.")
        return false
    end



    -- check if it is executable
    if info.sequenceFunctions[info.currentId + 1].canExecute(self) == true then
        -- execute next sequence
        if info.sequenceFunctions[info.currentId + 1].main(self) == true then
            info.currentId = info.currentId + 1

            -- If the next index is greater than the number of arrays, execute the last callback
            if #info.sequenceFunctions < info.currentId then
                if info.onFinallyCallback ~= nil then
                    info.onFinallyCallback(self)
                end
                info.hasFinallyCallbackCalled = true
            end

        else
            info.onError(self, "Failed to execute the sequence")
            return false
        end
    else
        info.onError(self, "The sequence main function does not meet the executable conditions")
        return false
    end

    return true
end

return SequenceManager
