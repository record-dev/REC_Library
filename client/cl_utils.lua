
---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"

---@class REC_Library.Client.Utils
local utils = {}

---@param ... any
function utils:debugPrint(...)
    if shCfg.debugMode == true then
        print("^6[debug]: ^0", ...)
    end
end

return utils