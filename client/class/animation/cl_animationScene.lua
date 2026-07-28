
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"


---@type REC_Library.Client.Class.Camera.Camera, REC_Library.Client.Class.Camera.CameraConfigBuilder
local Camera, CameraConfigBuilder = require "@REC_Library.client.class.camera.cl_camera", require "@REC_Library.client.class.camera.cl_cameraConfigBuilder"

---@class REC_Library.Client.Class.Animation.AnimationScene
---@field info REC_Library.Client.Class.Animation.AnimationSceneConfig
local AnimationScene = {}
AnimationScene.__index = AnimationScene

---instantiation
---@param config REC_Library.Client.Class.Animation.AnimationSceneConfigBuilder
---@return self
function AnimationScene:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---@return boolean
function AnimationScene:setup()
    local info = self.info

    if info.isSetuped == true then
        utils:debugPrint("^3[AnimationScene:setup]: already setuped...^0")
        return false
    end

    info.scene = NetworkCreateSynchronisedScene(
        info.coords.x, info.coords.y, info.coords.z,
        info.rotation.x, info.rotation.y, info.rotation.z,
        2,
        false,
        info.isLooped,
        1.0,
        0.0,
        1.0
    )


    -- flag
    info.isSetuped = true

    return true
end

---@param pedActor integer
---@param objActor integer
---@param propActors table<string, { handle: integer, animName: string, dict?: string, }>
---@param goToObjActor boolean
---@param camera? REC_Library.Client.Class.Camera.Camera
---@param startPhase? number
---@return boolean
function AnimationScene:play(pedActor, objActor, propActors, goToObjActor, camera, startPhase)
    local info = self.info

    if info.isSetuped == false then
        utils:debugPrint("^3[AnimationScene:play]: not setuped...^0")
        return false
    end

    if info.isRunning == true then
        utils:debugPrint("^3[AnimationScene:play]: scene is running...^0")
        return false
    end

    -- state initialization
    info.isRunning = true
    info.stopRequested = false

    if goToObjActor == true then
        self:goToEntityForward(pedActor, objActor)
        ClearPedTasksImmediately(pedActor)
        Wait(500)
    end

    PlaySynchronizedAudioEvent(info.scene)

    -- if startPhase ~= nil then
    --     SetSynchronizedScenePhase(info.scene, startPhase)
    -- end

    if camera ~= nil then
        -- SetCamActive(camera:getHandle(), true)
        -- RenderScriptCams(true, false, 0, true, false)
        -- PlaySynchronizedCamAnim(camera:getHandle(), info.scene, info.pedAnim, info.animDict)
        -- NetworkAddSynchronisedSceneCamera(
        --     info.scene,
        --     info.animDict,
        --     info.pedAnim
        -- )
    end

    NetworkAddPedToSynchronisedScene(
        pedActor,
        info.scene,
        info.animDict,
        info.pedAnim,
        1.5,
        -4.0, 1, 16,
        1148846080, 0
    )

    -- Play main OBJECT
    if info.objAnim ~= "" then
        NetworkAddEntityToSynchronisedScene(
            objActor,
            info.scene,
            info.animDict,
            info.objAnim,
            1.0,
            4.0,
            791560
        )
    end


    for propActorModel, propActor in pairs(propActors) do
        NetworkAddEntityToSynchronisedScene(
            propActor.handle,
            info.scene,
            propActor.dict or info.animDict,
            propActor.animName,
            1.0, 1.0, 1
        )
    end

    if info.firstCallback ~= nil then
        info.firstCallback(self)
    end

    -- Play
    NetworkStartSynchronisedScene(info.scene)

    info.localScene = NetworkGetLocalSceneFromNetworkId(info.scene)

    -- wait
    local timeout = 1200
    while info.localScene == -1 do
        Wait(100)

        info.localScene = NetworkGetLocalSceneFromNetworkId(info.scene)

        if timeout <= 0 then
            utils:debugPrint("^1failed to get local scene from network id...^0")
            return false
        end

        timeout -= 100
    end

    CreateThread(function()
        local scene = info.localScene
        local lastPhase = -1

        while info.isRunning and not info.stopRequested do
            if info.isLooped == false then
                local currentPhase = GetSynchronizedScenePhase(scene)
                if currentPhase >= 0.988 then
                    break
                end

                -- Phase Callback
                if info.phaseCallbacks ~= nil then
                    for phase, cb in pairs(info.phaseCallbacks) do
                        if lastPhase < phase and currentPhase >= phase then
                            cb(self)
                        end
                    end
                end
                lastPhase = currentPhase
            end

            if info.tickCallback ~= nil then
                info.tickCallback(self)
            end

            Wait(0)
        end

        -- Termination processing
        NetworkStopSynchronisedScene(info.scene)
        info.isRunning = false

        -- if info.finallyCallback ~= nil then
        --     info.finallyCallback(self)
        -- end
    end)

    if info.isLooped == false then
        local durationMs = math.floor(GetAnimDuration(info.animDict, info.pedAnim) * 1000)
        Citizen.Wait(math.floor(durationMs * 0.98))
    end

    if info.finallyCallback ~= nil then
        info.finallyCallback(self)
    end

    return true
end

---@return boolean
function AnimationScene:stop()
    if self:getIsRunning() == false then
        utils:debugPrint("^3scene is not running...^0")
        return false
    end
    self.info.stopRequested = true
    return true
end

---@return boolean
function AnimationScene:destroy()
    local info = self.info

    if info.isSetuped == false then
        utils:debugPrint("^3[AnimationScene:destroy]: not setuped...^0")
        return false
    end

    -- Fold the flag
    info.isSetuped = false

    return true
end

---@param pedActor integer
---@param objActor integer
---@return boolean
---@param timeout? integer
function AnimationScene:goToEntityForward(pedActor, objActor, timeout)
    timeout = timeout or 4000

    local objActorCoords = GetEntityCoords(objActor)
    local forwardOffset = GetEntityForwardVector(pedActor)
    local forwardCoords = objActorCoords + forwardOffset
    local dx = objActorCoords.x - forwardCoords.x
    local dy = objActorCoords.y - forwardCoords.y
    local targetHeading = math.deg(math.atan(dy, dx)) % 360

    TaskGoStraightToCoord(pedActor, forwardCoords.x, forwardCoords.y, forwardCoords.z, 1.0, timeout, targetHeading, 1.0)
    Wait(timeout)

    -- TaskTurnPedToFaceCoord(pedActor, objActorCoords.x, objActorCoords.y, objActorCoords.z, 1000)
    TaskTurnPedToFaceEntity(pedActor, objActor, 1200)
    Wait(800)
    return true
end

---@param propAnims table<string, { name: string, dict?: string, }>
---@return self
function AnimationScene:setPropAnims(propAnims)
    if propAnims == nil or type(propAnims) ~= "table" or next(propAnims) == nil then
        return self
    end
    self.info.propAnims = propAnims
    return self
end

---@return table<string, { name: string, dict?: string, }>
function AnimationScene:getPropAnims()
    return self.info.propAnims
end

---@return integer
function AnimationScene:getScene()
    return self.info.scene
end

---@return number
function AnimationScene:getCurrentPhase()
    return GetSynchronizedScenePhase(self:getScene())
end

function AnimationScene:getIsRunning()
    return self.info.isRunning
end

---@param rate number
function AnimationScene:setRate(rate)
    local info = self.info

    SetSynchronizedSceneRate(info.scene, rate)

    info.currentRate = rate
end

return AnimationScene
