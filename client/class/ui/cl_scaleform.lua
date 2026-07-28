
---@class REC_Library.Client.Class.UI.Scaleform
---@field info REC_Library.Client.Class.UI.ScaleformConfigBuilder
local Scaleform = {}
Scaleform.__index = Scaleform

---instantiation
function Scaleform:new()
    local instance = setmetatable({}, self)
    return instance
end

---Drawing per frame
---@return boolean Completed?
function Scaleform:play()
    local info = self.info

    

    return true
end

return Scaleform
