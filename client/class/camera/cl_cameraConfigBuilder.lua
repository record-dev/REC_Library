
---@class REC_Library.Client.Class.Camera.CameraConfig
---@field handle? integer
---@field name string
---@field position vector3
---@field rotation vector3
---@field fov number
---@field isActive boolean

---@class REC_Library.Client.Class.Camera.CameraConfigBuilder: REC_Library.Client.Class.Camera.CameraConfig
local CameraConfigBuilder = {}
CameraConfigBuilder.__index = CameraConfigBuilder

---instantiation
---@param name string
---@param position vector3
---@param rotation vector3
---@param fov number
---@param isActive boolean
---@return self
function CameraConfigBuilder:new(name, position, rotation, fov, isActive)
    isActive = isActive or false

    -- Argument check
    assert(
        name ~= nil and type(name) == "string",
        "name must be a string"
    )

    assert(
        position ~= nil and type(position) == "vector3",
        "position must be a vector3"
    )

    assert(
        rotation ~= nil and type(rotation) == "vector3",
        "rotation must be a vector3"
    )

    assert(
        fov ~= nil and type(fov) == "number",
        "fov must be a number"
    )

    local instance = setmetatable({}, self)
    instance.name = name
    instance.position = position
    instance.rotation = rotation
    instance.fov = fov * 1.0
    instance.isActive = isActive
    return instance
end



return CameraConfigBuilder
