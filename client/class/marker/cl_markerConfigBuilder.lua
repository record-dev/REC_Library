
---@class REC_Library.Client.Class.Marker.MarkerConfigBuilder
---@field marker number Marker ID
---@field coords vector3 coordinates
---@field dir REC_Library.Shared.3DCoords direction
---@field rotation REC_Library.Shared.3DCoords rotation
---@field scale REC_Library.Shared.3DCoords scale
---@field height? number height
---@field rgba REC_Library.Shared.RGBA RGBA color
---@field bobUpAndDown boolean Shake up and down
---@field faceCamera boolean Camera tracking
---@field rotationOrder number 2 is standard
---@field rotate boolean Rotate
---@field textureDict string|nil
---@field textureName string|nil
---@field drawOnEnt boolean Draw below entity
local MarkerConfigBuilder = {}
MarkerConfigBuilder.__index = MarkerConfigBuilder

---instantiation
---@param markerType number Marker type (integer greater than or equal to 0)
---@return self
function MarkerConfigBuilder:new(markerType)
    assert(markerType and type(markerType) == "number" and markerType >= 0, "Marker type is required and must be a non-negative number.")
    -- assert(coords and type(coords) == "vector3", "Coordinates are required and must be a vector3.")
    local instance = setmetatable({}, self)
    instance.marker = markerType
    instance.coords = vector3(0.0, 0.0, 0.0)
    instance.dir = { x = 0.0, y = 0.0, z = 0.0 }
    instance.rotation = { x = 0.0, y = 0.0, z = 0.0 }
    instance.scale = { x = 1.0, y = 1.0, z = 1.0 }
    -- instance.height = 0.5
    instance.rgba = { r = 60, g = 255, b = 126, a = 50 }
    instance.bobUpAndDown = false
    instance.faceCamera = false
    instance.rotationOrder = 2
    instance.rotate = false
    instance.textureDict = nil
    instance.textureName = nil
    instance.drawOnEnt = false
    return instance
end

---Set coordinates.
---@param coords vector3|nil
---@return self chain method
function MarkerConfigBuilder:setCoords(coords)
    if coords == nil then return self end
    assert(type(coords) == "vector3")
    self.coords = coords return self
end

---Set direction.
---@param dir REC_Library.Shared.3DCoords|nil
---@return self chain method
function MarkerConfigBuilder:setDir(dir)
    if dir == nil then return self end
    assert(type(dir) == "table" and dir.x and dir.y and dir.z, "Direction must be a table with x, y, z coordinates.")
    self.dir = dir return self
end

---Set the rotation angle.
---@param rotation REC_Library.Shared.3DCoords|nil
---@return self chain method
function MarkerConfigBuilder:setRotation(rotation)
    if rotation == nil then return self end
    assert(type(rotation) == "table" and rotation.x and rotation.y and rotation.z, "Rotation must be a table with x, y, z coordinates.")
    self.rotation = rotation return self
end

---Set the overall scale.
---@param scale REC_Library.Shared.3DCoords|nil
---@return self chain method
function MarkerConfigBuilder:setScale(scale)
    if scale == nil then return self end
    assert(type(scale) == "table" and scale.x and scale.y and scale.z, "Scale must be a table with x, y, z coordinates.")
    self.scale = scale return self
end

-- ---Set the height.
-- ---@param height number
-- ---@return self chain method
-- function MarkerConfigBuilder:setHeight(height)
--     assert(type(height) == "number", "Height must be a number.")
--     self.height = height return self
-- end

---Set color and transparency.
---@param rgba REC_Library.Shared.RGBA|nil
---@return self chain method
function MarkerConfigBuilder:setRgba(rgba)
    if rgba == nil then return self end
    assert(type(rgba) == "table" and rgba.r and rgba.g and rgba.b and rgba.a, "RGBA must be a table with r, g, b, a values.")
    self.rgba = rgba return self
end

---Set only transparency.
---@param alpha number|nil
---@return self chain method
function MarkerConfigBuilder:setRgbaAlpha(alpha)
    if alpha == nil then return self end
    assert(type(alpha) == "number", "Alpha must be a number.")
    self.rgba.a = alpha return self
end

---Set up and down shaking.
---@param bob boolean|nil
---@return self chain method
function MarkerConfigBuilder:setBobUpAndDown(bob)
    if bob == nil then return self end
    assert(type(bob) == "boolean", "BobUpAndDown must be a boolean.")
    self.bobUpAndDown = bob return self
end

---Set camera tracking.
---@param face boolean|nil
---@return self chain method
function MarkerConfigBuilder:setFaceCamera(face)
    if face == nil then return self end
    assert(type(face) == "boolean", "FaceCamera must be a boolean.")
    self.faceCamera = face return self
end

---Set rotation order (usually 2).
---@param order number|nil
---@return self chain method
function MarkerConfigBuilder:setRotationOrder(order)
    if order == nil then return self end
    assert(type(order) == "number", "RotationOrder must be a number.")
    self.rotationOrder = order return self
end

---Set automatic rotation on the Y axis.
---@param shouldRotate boolean|nil
---@return self chain method
function MarkerConfigBuilder:setRotate(shouldRotate)
    if shouldRotate == nil then return self end
    assert(type(shouldRotate) == "boolean", "Rotate must be a boolean.")
    self.rotate = shouldRotate return self
end

---Set custom texture.
---@param dict string|nil texture dictionary name
---@param name string|nil texture name
---@return self chain method
function MarkerConfigBuilder:setTexture(dict, name)
    assert(type(dict) == "string" or dict == nil, "Texture dictionary must be a string or nil.")
    assert(type(name) == "string" or name == nil, "Texture name must be a string or nil.")
    self.textureDict = dict
    self.textureName = name
    return self
end

---Set whether to draw on the entity.
---@param draw boolean|nil
---@return self chain method
function MarkerConfigBuilder:setDrawOnEnt(draw)
    if draw == nil then return self end
    assert(type(draw) == "boolean", "DrawOnEnt must be a boolean.")
    self.drawOnEnt = draw return self
end

---Build and return in table format
---@return table 
function MarkerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return MarkerConfigBuilder
