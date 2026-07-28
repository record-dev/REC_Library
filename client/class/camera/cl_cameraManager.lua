
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Camera.CameraManager
---@field info REC_Library.Client.Class.Camera.CameraManagerConfigBuilder
local CameraManager = {}
CameraManager.__index = CameraManager

---instantiation
---@return self
function CameraManager:new(config)

    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Preparation
---@return boolean
function CameraManager:setup()
    local info = self.info

    -- Check if active
    if self:getIsActive() == true then
        utils:debugPrint("[CameraManager]: already active")
        return false
    end

    for index, cameraInfo in ipairs(info.cameras) do

        -- Camera generation
        if cameraInfo.instance:create() == false then
            utils:debugPrint("failed to create camera:", index)
        end

        -- Texture loading
        local success = NewLoadSceneStartSphere(
            cameraInfo.instance.info.position.x,
            cameraInfo.instance.info.position.y,
            cameraInfo.instance.info.position.z,
            50.0,
            2
        )

        while not IsNewLoadSceneLoaded() do
            Citizen.Wait(10)
        end
    end

    -- -- Texture loading
    NewLoadSceneStartSphere(
        info.centerPosition.x,
        info.centerPosition.y,
        info.centerPosition.z,
        info.radius
    )

    while not IsNewLoadSceneLoaded() do
        Citizen.Wait(10)
    end

    -- Fold the flag
    info.isSetuped = true

    return true
end

---Activate
---@param camIndex? integer
---@param duration? integer
---@param inteval? integer
---@return boolean
function CameraManager:active(camIndex, duration, inteval)
    local info = self.info
    camIndex = camIndex or 1
    duration = duration or 0
    inteval = inteval or 1000

    -- Check if active
    if self:getIsActive() == true then
        utils:debugPrint("[CameraManager]: already active")
        return false
    end

    -- Get the camera for the first drawing target
    local camera = self:getCameraByIndex(camIndex)
    if camera == nil then
        utils:debugPrint("[CameraManager]: firstCam is not founded")
        return false
    end

    if camera.instance:lookIn() == false then
        utils:debugPrint("failed to lookIn camera:", camIndex)
    end

    RenderScriptCams(true, true, duration, true, false)

    info.currentCameraIndex = camIndex

    -- flag
    info.isActive = true

    Wait(duration + inteval)

    return true
end

---Camera switching
---@param camIndex integer
---@param duration? integer 
---@param inteval? integer
---@return boolean
function CameraManager:switchTo(camIndex, duration, inteval)
    local info = self.info
    duration = duration or 0
    inteval = inteval or 1000

    -- Argument check
    if camIndex == nil then
        utils:debugPrint("[CameraManager]: camIndex is nil")
        return false
    end

    if duration == nil then
        utils:debugPrint("[CameraManager]: duration is nil")
        return false
    end

    -- Check if active
    if self:getIsActive() == false then
        utils:debugPrint("[CameraManager]: not active")
        return false
    end

    -- Get current camera
    local currentCam = self:getCurrentCamera()
    if currentCam == nil then
        return false
    end

    -- Get the camera to switch to
    local targetCam = self:getCameraByIndex(camIndex)
    if targetCam == nil then
        utils:debugPrint("[CameraManager:switchTo] failed to get target Cam")
        return false
    end

    -- Switch
    SetCamActiveWithInterp(
        targetCam.instance.info.handle,
        currentCam.instance.info.handle,
        duration,
        1,
        1
    )

    -- 
    if targetCam.callbacks.onSwitch ~= nil then
        targetCam.callbacks.onSwitch(self)
    end

    -- Wait until switching is complete
    local totalDuration = duration + inteval
    local currentTime = GetGameTimer()
    local endTime = currentTime + totalDuration
    while currentTime <= endTime do
        Wait(5)

        if targetCam.callbacks.onSwitching ~= nil then
            targetCam.callbacks.onSwitching(self)
        end

        currentTime = GetGameTimer()
    end

    -- Update current camera number
    info.currentCameraIndex = camIndex

    return true
end

---stop watching
---@return boolean
function CameraManager:quit(duration)
    local info = self.info
    duration = duration or 0

    -- Check if active
    if self:getIsActive() == false then
        utils:debugPrint("[CameraManager]: not active")
        return false
    end

    RenderScriptCams(false, true, duration, true, false)

    -- Fold the flag
    info.isActive = false

    return true
end

---Discard
---@param duration? integer Time to return to player screen after discarding camera
---@param inteval? integer
---@return boolean
function CameraManager:cleanup(duration, inteval)
    local info = self.info
    duration = duration or 0
    inteval = inteval or 1000

    -- Check if active
    if self:getIsActive() == true then
        utils:debugPrint("[CameraManager]: already active")
        return false
    end

    Wait(duration + inteval)

    -- Destroy all cameras
    for index, cameraInfo in ipairs(info.cameras) do

        -- Discard
        if cameraInfo.instance:destroy() == false then
            utils:debugPrint("failed to destroy camera:", index)
        end
    end

    -- Texture loading discarded
    NewLoadSceneStop()

    return true
end

---Return the current camera number
---@return integer|nil
function CameraManager:getCurrentCameraIndex()
    local info = self.info

    -- Check if active
    if self:getIsActive() == false then
        utils:debugPrint("[CameraManager]: not active")
        return nil
    end

    return info.currentCameraIndex
end

---@param cameraIndex integer
---@return REC_Library.Client.Class.Camera.CameraManagerConfig.Camera|nil
function CameraManager:getCameraByIndex(cameraIndex)
    local info = self.info

    -- Check if active
    if self:getIsSetuped() == false then
        utils:debugPrint("[CameraManager]: not setuped")
        return nil
    end

    -- Existence confirmation
    local camera = info.cameras[cameraIndex]
    if camera == nil then
        utils:debugPrint("[CameraManaer]: camera is not founded")
        return nil
    end

    return camera
end

---Get current camera object
---@return REC_Library.Client.Class.Camera.CameraManagerConfig.Camera|nil
function CameraManager:getCurrentCamera()
    local info = self.info

    -- Check if active
    if self:getIsActive() == false then
        utils:debugPrint("[CameraManager]: not active")
        return nil
    end

    -- Get current camera number
    local currentCamIndex = self:getCurrentCameraIndex()
    if currentCamIndex == nil then
        utils:debugPrint("[CameraManager]: cameraIndex is nil")
        return nil
    end

    return self:getCameraByIndex(currentCamIndex)
end

---@return boolean
function CameraManager:getIsSetuped()
    local info = self.info
    return info.isSetuped
end

---@return boolean
function CameraManager:getIsActive()
    local info = self.info
    return info.isActive
end

return CameraManager
