
---@class REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig
---@field pedActor integer
---@field objActor integer
---@field propActors table<string, REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig.PropActor>
---@field animDict string
---@field coords vector3
---@field rotation vector3
---@field animScenes table<string|REC_Library.Shared.Enums.AnimationSceneTypes, REC_Library.Client.Class.Animation.AnimationScene>
---@field currentAnimKey? string|REC_Library.Shared.Enums.AnimationSceneTypes
---@field camera? REC_Library.Client.Class.Camera.Camera
---@field isSetuped boolean
---@field isNetworked boolean

---@class REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfigBuilder: REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig
---@field info REC_Library.Client.Class.Animation.AnimationSceneConfig
local AnimationSceneManagerConfigBuilder = {}
AnimationSceneManagerConfigBuilder.__index = AnimationSceneManagerConfigBuilder

---@param pedActor integer
---@param objActor integer
---@param animDict string
---@param coords vector3
---@param rotation vector3
---@return self
function AnimationSceneManagerConfigBuilder:new(pedActor, objActor, animDict, coords, rotation)
    local instance = setmetatable({}, self)
    instance.pedActor = pedActor
    instance.objActor = objActor
    instance.propActors = {}
    instance.animDict = animDict
    instance.coords = coords
    instance.rotation = rotation
    instance.animScenes = {}
    -- instance.currentAnimKey = "idle"
    instance.isSetuped = false
    instance.isNetworked = false
    return instance
end

---@param animKey string|REC_Library.Shared.Enums.AnimationSceneTypes
---@param animScene REC_Library.Client.Class.Animation.AnimationScene
---@return self
function AnimationSceneManagerConfigBuilder:setAnimScene(animKey, animScene)
    if animKey == nil or animScene == nil then return self end
    self.animScenes[animKey] = animScene
    return self
end

---@param cam REC_Library.Client.Class.Camera.Camera|nil
---@return self
function AnimationSceneManagerConfigBuilder:setCamera(cam)
    if cam == nil then return self end
    self.camera = cam
    return self
end

---@param isNetworked boolean|nil
---@return self
function AnimationSceneManagerConfigBuilder:setIsNetworked(isNetworked)
    if isNetworked == nil then return self end
    self.isNetworked = isNetworked
    return self
end

return AnimationSceneManagerConfigBuilder

---@class REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig.PedActor
---@field handle integer

---@class REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig.ObjActor
---@field handle integer

---@class REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfig.PropActor
---@field handle integer