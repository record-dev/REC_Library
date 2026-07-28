
---@class REC_Library.Client.Class.Marker.Marker
---@field info REC_Library.Client.Class.Marker.MarkerConfigBuilder
local Marker = {}
Marker.__index = Marker

---instantiation
---@param config REC_Library.Client.Class.Marker.MarkerConfigBuilder
---@return self
function Marker:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Draw (1 frame only)
---@return boolean Was drawing successful?
function Marker:draw()
    local info = self.info

    DrawMarker(
        info.marker,
        info.coords.x, info.coords.y, info.coords.z,
        info.dir.x, info.dir.y, info.dir.z,
        info.rotation.x, info.rotation.y, info.rotation.z,
        info.scale.x, info.scale.y, info.scale.z,
        info.rgba.r, info.rgba.g, info.rgba.b, info.rgba.a,
        info.bobUpAndDown,
        info.faceCamera,
        info.rotationOrder,
        info.rotate,
        info.textureDict,
        info.textureName,
        info.drawOnEnt
    )

    return true
end

-- New drawAt method intended to be called from BindManager
---@param position vector3
function Marker:drawAt(position)
    if not position or type(position) ~= "vector3" then
        error("Invalid position provided for Marker:drawAt")
    end
    local info = self.info
    DrawMarker(
        info.marker,
        position.x, position.y, position.z,
        info.dir.x, info.dir.y, info.dir.z,
        info.rotation.x, info.rotation.y, info.rotation.z,
        info.scale.x, info.scale.y, info.scale.z,
        info.rgba.r, info.rgba.g, info.rgba.b, info.rgba.a,
        info.bobUpAndDown,
        info.faceCamera,
        info.rotationOrder,
        info.rotate,
        info.textureDict,
        info.textureName,
        info.drawOnEnt
    )
end

return Marker
