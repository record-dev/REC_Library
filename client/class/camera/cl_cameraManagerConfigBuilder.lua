
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

local Camera = require "@REC_Library.client.class.camera.cl_camera"

---@class REC_Library.Client.Class.Camera.CameraManagerConfig
---@field currentCameraIndex integer
---@field cameras table<integer, REC_Library.Client.Class.Camera.CameraManagerConfig.Camera>
---@field centerPosition vector3
---@field radius number
---@field isSetuped boolean
---@field isActive boolean

---@class REC_Library.Client.Class.Camera.CameraManagerConfigBuilder: REC_Library.Client.Class.Camera.CameraManagerConfig
local CameraManagerConfigBuilder = {}
CameraManagerConfigBuilder.__index = CameraManagerConfigBuilder

---instantiation
---@param centerPosition vector3
---@param radius number
---@return self
function CameraManagerConfigBuilder:new(centerPosition, radius)
    local instance = setmetatable({}, self)

    ---[[
    --- Type checking
    ---]]
    assert(
        centerPosition ~= nil and type(centerPosition) == "vector3",
        "centerPosition must be a vector3"
    )

    assert(
        radius ~= nil and type(radius) == "number",
        "radius must be a number"
    )

    instance.centerPosition = centerPosition
    instance.radius = radius
    instance.currentCameraIndex = 0
    instance.cameras = {}
    instance.isSetuped = false
    instance.isActive = false
    return instance
end

---Camera coordinate settings
---@param cameraConfigBuilder REC_Library.Client.Class.Camera.CameraConfigBuilder
---@param callbacks? REC_Library.Client.Class.Camera.CameraManagerConfig.Camera.Callbacks
---@return self
function CameraManagerConfigBuilder:setCamera(cameraConfigBuilder, callbacks)

    -- Argument check
    if cameraConfigBuilder == nil then
        utils:debugPrint("^3[CameraManagerConfigBuilder]: failed setCamera^0")
        return self
    end

    self.cameras[#self.cameras+1] = {
        instance = Camera:new(cameraConfigBuilder),
        callbacks = callbacks or {},
    }

    return self
end


---@class REC_Library.Client.Class.Camera.CameraManagerConfig.Camera
---@field instance REC_Library.Client.Class.Camera.Camera
---@field callbacks REC_Library.Client.Class.Camera.CameraManagerConfig.Camera.Callbacks

---@class REC_Library.Client.Class.Camera.CameraManagerConfig.Camera.Callbacks
---@field onSwitch? fun(self: REC_Library.Client.Class.Camera.CameraManager)
---@field onSwitching? fun(self: REC_Library.Client.Class.Camera.CameraManager)

return CameraManagerConfigBuilder
