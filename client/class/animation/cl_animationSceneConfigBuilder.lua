
---@class REC_Library.Client.Class.Animation.AnimationSceneConfig
---@field scene integer
---@field localScene integer
---@field coords vector3
---@field rotation vector3
---@field animDict string
---@field pedAnim string
---@field objAnim string
---@field propAnims table<string, { name: string, dict?: string, }>
---@field currentRate number
---@field currentPhase number
---@field firstCallback? fun(self: REC_Library.Client.Class.Animation.AnimationScene)
---@field tickCallback? fun(self: REC_Library.Client.Class.Animation.AnimationScene)
---@field phaseCallbacks table<integer, fun(self: REC_Library.Client.Class.Animation.AnimationScene)>
---@field finallyCallback? fun(self: REC_Library.Client.Class.Animation.AnimationScene)
---@field goToForward boolean
---@field stopRequested boolean
---@field isLooped boolean
---@field isRunning boolean
---@field isSetuped boolean

---@class REC_Library.Client.Class.Animation.AnimationSceneConfigBuilder: REC_Library.Client.Class.Animation.AnimationSceneConfig
local AnimationSceneConfigBuilder = {}
AnimationSceneConfigBuilder.__index = AnimationSceneConfigBuilder

---@param coords vector3
---@param rotation vector3
---@param animDict string
---@param pedAnim string
---@param objAnim string
function AnimationSceneConfigBuilder:new(coords, rotation, animDict, pedAnim, objAnim)
    local instance = setmetatable({}, self)
    instance.scene = 0
    instance.localScene = -1
    instance.coords = coords
    instance.rotation = rotation
    instance.animDict = animDict
    instance.pedAnim = pedAnim
    instance.objAnim = objAnim
    instance.propAnims = {}
    instance.currentRate = 1.0
    instance.currentPhase = 0.0
    instance.phaseCallbacks = {}
    instance.goToForward = false
    instance.stopRequested = false
    instance.isLooped = false
    instance.isRunning = false
    instance.isSetuped = false
    return instance
end

---@param goToForward? boolean
---@return self
function AnimationSceneConfigBuilder:setGoToForward(goToForward)
    if goToForward == nil then return self end
    self.goToForward = goToForward
    return self
end

---@param cb fun(self: REC_Library.Client.Class.Animation.AnimationScene)|nil
---@return self
function AnimationSceneConfigBuilder:setTickCallback(cb)
    if cb == nil then return self end
    self.tickCallback = cb
    return self
end

---@param cb fun(self: REC_Library.Client.Class.Animation.AnimationScene)|nil
---@return self
function AnimationSceneConfigBuilder:setFirstCallback(cb)
    if cb == nil then return self end
    self.firstCallback = cb
    return self
end

---@param phase number|nil
---@param cb fun(self: REC_Library.Client.Class.Animation.AnimationScene)|nil
---@return self
function AnimationSceneConfigBuilder:setPhaseCallback(phase, cb)
    if phase == nil or cb == nil then return self end
    self.phaseCallbacks[phase] = cb
    return self
end

---@param cb fun(self: REC_Library.Client.Class.Animation.AnimationScene)|nil
---@return self
function AnimationSceneConfigBuilder:setFinallyCallback(cb)
    if cb == nil then return self end
    self.finallyCallback = cb
    return self
end

---@param isLooped? boolean
---@return self
function AnimationSceneConfigBuilder:setIsLooped(isLooped)
    if isLooped == nil then return self end
    self.isLooped = isLooped
    return self
end

return AnimationSceneConfigBuilder