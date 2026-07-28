
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Camera.Camera
---@field info REC_Library.Client.Class.Camera.CameraConfigBuilder
local Camera = {}
Camera.__index = Camera

---instantiation
---@param config REC_Library.Client.Class.Camera.CameraConfigBuilder
---@return self
function Camera:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Create camera
---@return boolean
function Camera:create()
    local info = self.info

    -- Check if it has already been created
    if info.handle ~= nil and DoesCamExist(info.handle) then
        utils:debugPrint("camera is exist")
        return false
    end

    -- create
    info.handle = CreateCameraWithParams(
        info.name,
        info.position.x,
        info.position.y,
        info.position.z,
        info.rotation.x,
        info.rotation.y,
        info.rotation.z,
        info.fov,
        info.isActive,
        2
    )

    local createTimeout = 3000
    while createTimeout > 0 and DoesCamExist(info.handle) == false do
        Wait(100)
        createTimeout -= 100
    end

    -- Existence confirmation
    if info.handle == 0 or DoesCamExist(info.handle) == false then
        utils:debugPrint("^1camera is not created.^0")
        return false
    end

    return true
end

---See camera perspective
---@return boolean
function Camera:lookIn()
    local info = self.info

    -- Check if it has been created
    if info.handle == 0 or DoesCamExist(info.handle) == false then
        utils:debugPrint("camera is not founded")
        return false
    end

    -- Texture loading
    NewLoadSceneStartSphere(
        info.position.x,
        info.position.y,
        info.position.z,
        50.0,
        2
    )

    while not IsNewLoadSceneLoaded() do
        Citizen.Wait(10)
    end


    SetCamActive(info.handle, true)

    -- set active flag
    info.isActive = true

    return true
end

---Stop looking at the camera's perspective
---@return boolean
function Camera:lookOut()
    local info = self.info

    -- Check if it has been created
    if info.handle == 0 or DoesCamExist(info.handle) == false then
        utils:debugPrint("camera is not founded")
        return false
    end

    SetCamActive(info.handle, false)

    -- set active flag
    info.isActive = false

    return true
end

---@return boolean
function Camera:shake()
    local info = self.info

    -- Check if it has been created
    if info.handle == 0 or DoesCamExist(info.handle) == false then
        utils:debugPrint("camera is not founded")
        return false
    end

    SetCamShakeAmplitude(info.handle, 100.0)

    return true
end

---Camera discarded
---@return boolean
function Camera:destroy()
    local info = self.info

    -- Check if it has been created
    if info.handle == 0 or DoesCamExist(info.handle) == false then
        utils:debugPrint("camera is not founded")
        return false
    end

    -- deactivate
    SetCamActive(info.handle, false)

    -- Discard
    DestroyCam(info.handle, true)

    -- Destruction confirmation
    if DoesCamExist(info.handle) == true then
        utils:debugPrint("failed to destroy cam.")
        return false
    end

    -- initialization
    info.handle = 0
    info.isActive = false

    return true
end

---@return integer
function Camera:getHandle()
    return self.info.handle
end

return Camera
