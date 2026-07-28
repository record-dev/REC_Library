
---@type REC_Library.Server.Config
local svCfg = require "@REC_Library.server.sv_config"

---@class REC_Library.Server.Utils
local utils = {}

---@param ... any
function utils:debugPrint(...)
    if svCfg.debugMode == true then
        print("^6[debug]: ^0", ...)
    end
end

return utils