
---@class REC_Library.Client.Class.UI.Managers.HelpTextManager
---@field info REC_Library.Client.Class.UI.HelpTextConfigBuilder
local HelpTextManager = {}
HelpTextManager.__index = HelpTextManager

---instantiation
---@param config REC_Library.Client.Class.UI.HelpTextConfigBuilder
---@return self
function HelpTextManager:new(config)
    local instance = setmetatable({}, self)
    return instance
end

return HelpTextManager
