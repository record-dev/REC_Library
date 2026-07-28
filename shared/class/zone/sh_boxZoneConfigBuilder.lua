
---@class REC_Library.Shared.Class.Zone.BoxZoneConfigBuilder
---@field coords vector3
---@field size? vector3
---@field rotation? number
---@field onEnter? fun(...)
---@field onExit? fun(...)
---@field inside? fun(...)
---@field debug? boolean
---@field debugColour REC_Library.Shared.RGBA
local BoxZoneConfigBuilder = {}
BoxZoneConfigBuilder.__index = BoxZoneConfigBuilder

---instantiation
---@param coords vector3 coordinates
---@return self
function BoxZoneConfigBuilder:new(coords)
    local instance = setmetatable({}, self)
    instance.coords = coords
    instance.size = vec3(2, 2, 2)
    instance.rotation = 0
    instance.onEnter = nil
    instance.onExit = nil
    instance.inside = nil
    instance.debug = false
    instance.debugColour = { r = 60, g = 255, b = 126, a = 50 }
    return instance
end

---@param size vector3|nil
---@return self chain method
function BoxZoneConfigBuilder:setSize(size)
    if size == nil then return self end
    assert(type(size) == "vector3")
    self.size = size return self
end

---@param rotation number|nil
---@return self chain method
function BoxZoneConfigBuilder:setRotation(rotation)
    if rotation == nil then return self end
    assert(type(rotation) == "number")
    self.rotation = rotation return self
end

---@param onEnter fun(self: REC_Library.Shared.Zone.Self)|nil
---@return self chain method
function BoxZoneConfigBuilder:setOnEnter(onEnter)
    if onEnter == nil then return self end
    assert(type(onEnter) == "function")
    self.onEnter = onEnter return self
end

---@param onExit fun(self: REC_Library.Shared.Zone.Self)|nil
---@return self chain method
function BoxZoneConfigBuilder:setOnExit(onExit)
    if onExit == nil then return self end
    assert(type(onExit) == "function")
    self.onExit = onExit return self
end

---@param onInside fun(self: REC_Library.Shared.Zone.Self)|nil
---@return self chain method
function BoxZoneConfigBuilder:setOnInside(onInside)
    if onInside == nil then return self end
    assert(type(onInside) == "function")
    self.inside = onInside return self
end

---@param debug boolean|nil
---@return self chain method
function BoxZoneConfigBuilder:setDebug(debug)
    if debug == nil then return self end
    assert(type(debug) == "boolean")
    self.debug = debug return self
end

---Set Zone color when debug == true (RGBA)
---@param debugColour REC_Library.Shared.RGBA|nil
---@return self chain method
function BoxZoneConfigBuilder:setDebugColour(debugColour)
    if debugColour == nil then return self end
    assert(type(debugColour) == "table")
    self.debugColour = debugColour return self
end

---When you want to change only the transparency of the Zone color when debug == true
---@param alpha number|nil
---@return self chain method
function BoxZoneConfigBuilder:setDebugColourAlpha(alpha)
    if alpha == nil then return self end
    assert(type(alpha) == "number")
    self.debugColour.a = alpha return self
end

---@return table
function BoxZoneConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return BoxZoneConfigBuilder
