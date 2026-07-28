
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class.Object.Object, REC_Library.Shared.Class.Object.ObjectConfigBuilder
local Object, ObjectConfigBuilder = require "@REC_Library.client.class.object.cl_object", require "@REC_Library.shared.class.object.sh_objectConfigBuilder"

---@class REC_Library.Client.Class.Animation.Manager.AnimationSceneManager
---@field info REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig
local AnimationSceneManager = {}
AnimationSceneManager.__index = AnimationSceneManager

---@param config REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig
---@return self
function AnimationSceneManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---@return boolean
function AnimationSceneManager:setup()
    local info = self.info

    if DoesAnimDictExist(info.animDict) == false then
        utils:debugPrint(("^1animDict is not exist... animDict: %s^0"):format(info.animDict))
        return false
    end

    RequestAnimDict(info.animDict)

    local loadTimeout = 3000
    while loadTimeout > 0 and HasAnimDictLoaded(info.animDict) == false do
        Wait(100)
        loadTimeout -= 100
    end

    if HasAnimDictLoaded(info.animDict) == false then
        utils:debugPrint(("^1animation dictionary is can not load... animDict: %s^0"):format(info.animDict))
        return false
    end

    if info.camera ~= nil then
        if info.camera:create() == false then
            utils:debugPrint("^1failed to create camera...^0")
            return false
        end
    end

    if info.isNetworked == true then
        NetworkRegisterEntityAsNetworked(info.objActor)
        local timeout = 1200
        while NetworkGetEntityIsNetworked(info.objActor) == false do
            Wait(100)
            if timeout <= 0 then
                utils:debugPrint("^1failed to register objActor as networked...^0")
                return false
            end
            timeout -= 100
        end
        if NetworkGetEntityIsNetworked(info.objActor) == false then
            utils:debugPrint("^1failed to register objActor as networked...^0")
            return false
        end
    end

    -- Object setup
    for animSceneKey, animScene in pairs(info.animScenes) do
        for propActorModel, _ in pairs(animScene:getPropAnims()) do
            if info.propActors[propActorModel] == nil then
                info.propActors[propActorModel] = {
                    handle = (function ()
                        local prop = Object:new(
                            ObjectConfigBuilder:new(
                                propActorModel,
                                info.coords - vector(0.0, 0.0, -2.0),
                                0.0
                            )
                            :setIsNetworked(true)
                        )

                        if prop:spawn() == false then
                            utils:debugPrint(("^3failed to spawn prop... propActorModel: %s^0"):format(propActorModel))
                        end

                        SetEntityCompletelyDisableCollision(prop:getHandle(), true, false)

                        return prop:getHandle()
                    end)(),
                }
            end
        end
    end

    info.isSetuped = true

    return true
end

---@param animKey string|REC_Library.Shared.Enums.AnimationSceneTypes
---@param goToObjActor boolean
---@param phase? number
---@return boolean
function AnimationSceneManager:playAnimSceneByKey(animKey, goToObjActor, phase)
    local info = self.info

    if info.isSetuped == false then
        utils:debugPrint("^1not setuped yet...^0")
        return false
    end

    local animScene = info.animScenes[animKey]
    if animScene == nil then
        utils:debugPrint(("^1animScene is not founded... animKey: %s^0"):format(animKey))
        return false
    end

    if animScene:setup() == false then
        utils:debugPrint(("^1failed to setup animScene... animKey: %s^0"):format(animKey))
        return false
    end

    ---@type table<string, { handle: integer, animName: string, animDict?: string, }>
    local propActors = {}
    for propActorModel, propActorAnim in pairs(animScene:getPropAnims()) do
        local propActor = info.propActors[propActorModel]
        if propActor ~= nil then
            propActors[propActorModel] = {
                handle = propActor.handle,
                animName = propActorAnim.name,
                animDict = propActorAnim.dict,
            }
        end
    end

    if animScene:play(info.pedActor, info.objActor, propActors, goToObjActor, info.camera, phase) == false then
        utils:debugPrint(("^1failed to play animScene... animKey: %s^0"):format(animKey))
        return false
    end

    info.currentAnimKey = animKey

    return true
end

---@return boolean
function AnimationSceneManager:clear()
    local info = self.info

    ClearPedTasksImmediately(info.pedActor)

    for _, propActor in pairs(info.propActors) do
        DeleteEntity(propActor.handle)
    end

    info.currentAnimKey = nil

    return true
end

---@return string|REC_Library.Shared.Enums.AnimationSceneTypes|nil
function AnimationSceneManager:getCurrentAnimKey()
    return self.info.currentAnimKey
end

---@return REC_Library.Client.Class.Camera.Camera|nil
function AnimationSceneManager:getCamera()
    return self.info.camera
end

return AnimationSceneManager
