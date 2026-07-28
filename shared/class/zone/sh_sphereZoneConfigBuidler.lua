
---@class REC_Library.Shared.Class.Zone.SphereZoneConfigBuilder
---@field coords vector3
---@field radius? number
---@field onEnter? fun(...)
---@field onExit? fun(...)
---@field inside? fun(...)
---@field debug? boolean
---@field debugColour REC_Library.Shared.RGBA
local SphereZoneConfigBuilder = {}
SphereZoneConfigBuilder.__index = SphereZoneConfigBuilder

---instantiation
---@param coords vector3 coordinates
---@return self
function SphereZoneConfigBuilder:new(coords)
    local instance = setmetatable({}, self)
    instance.coords = coords
    instance.radius = 2
    instance.onEnter = nil
    instance.onExit = nil
    instance.inside = nil
    instance.debug = false
    instance.debugColour = { r = 60, g = 255, b = 126, a = 50 }
    return instance
end

---@param radius number|nil
---@return self chain method
function SphereZoneConfigBuilder:setRadius(radius)
    if radius == nil then return self end
    assert(type(radius) == "number")
    self.radius = radius return self
end

---@param onEnter fun(self: REC_Library.Shared.Zone.Self)|nil
---@return self chain method
function SphereZoneConfigBuilder:setOnEnter(onEnter)
    if onEnter == nil then return self end
    assert(type(onEnter) == "function")
    self.onEnter = onEnter return self
end

---@param onExit fun(self: REC_Library.Shared.Zone.Self)|nil
---@return self chain method
function SphereZoneConfigBuilder:setOnExit(onExit)
    if onExit == nil then return self end
    assert(type(onExit) == "function")
    self.onExit = onExit return self
end

---@param onInside fun(self: REC_Library.Shared.Zone.Self)|nil
---@return self chain method
function SphereZoneConfigBuilder:setOnInside(onInside)
    if onInside == nil then return self end
    assert(type(onInside) == "function")
    self.inside = onInside return self
end

---@param debug boolean|nil
---@return self chain method
function SphereZoneConfigBuilder:setDebug(debug)
    if debug == nil then return self end
    assert(type(debug) == "boolean")
    self.debug = debug return self
end

---Set Zone color when debug == true (RGBA)
---@param debugColour REC_Library.Shared.RGBA|nil
---@return self chain method
function SphereZoneConfigBuilder:setDebugColour(debugColour)
    if debugColour == nil then return self end
    assert(type(debugColour) == "table")
    self.debugColour = debugColour return self
end

---When you want to change only the transparency of the Zone color when debug == true
---@param alpha number|nil
---@return self chain method
function SphereZoneConfigBuilder:setDebugColourAlpha(alpha)
    if alpha == nil then return self end
    assert(type(alpha) == "number")
    self.debugColour.a = alpha return self
end

---@return table
function SphereZoneConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return SphereZoneConfigBuilder
