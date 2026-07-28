
local Scaleform = {}
-- Scaleform.__index = Scaleform

---instantiation
function Scaleform:new()
    local instance = setmetatable({}, self)
    return instance
end

---scaleform playback
---@return boolean Completed?
function Scaleform:play()
    
end

