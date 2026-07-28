
---@class REC_Library.Client.Class.Cutscene.CutsceneConfigBuilder
---@field name string Cutscene unique name or ID
---@field coords vector3
---@field finalCoords vector3
---@field finalHeading number
---@field ped number
---@field streamingEntities? table<number, string>
---@field createdStreamingEntities? table<number, REC_Library.Client.Class.Ped.Ped>
---@field canBeSkipped boolean|nil Skippable? (default: true)
---
---@field disablePlayerControl boolean
---@field hideHud boolean Hide HUD?
---
---@field fadeout boolean
---@field fadeoutDuration? number
---@field fadeinDuration? number
---
---@field onStart? fun(...) Callback function executed when cutscene starts
---@field onEnd? fun(...) Callback function executed when cutscene ends
---@field onSkip? fun(...) Callback function executed when cutscene is skipped
---
---@field isResolving boolean
local CutsceneConfigBuilder = {}
CutsceneConfigBuilder.__index = CutsceneConfigBuilder

---instantiation
---@param name string cutscene name
---@param ped number
---@param coords vector3 Cutscene execution point
---@param finalCoords vector3 Position after cutscene ends
---@param finalHeading number heading after cutscene ends
---@return self CutsceneConfigBuilder
function CutsceneConfigBuilder:new(name, ped, coords, finalCoords, finalHeading)
    assert(name ~= nil and type(name) == "string")
    assert(ped ~= nil and type(ped) == "number")
    assert(coords ~= nil and type(coords) == "vector3")
    assert(finalCoords ~= nil and type(finalCoords) == "vector3")
    assert(finalHeading ~= nil and type(finalHeading) == "number")

    local instance = setmetatable({}, self)
    instance.name = name
    instance.ped = ped
    instance.coords = coords
    instance.finalCoords = finalCoords
    instance.finalHeading = finalHeading
    instance.streamingEntities = {}
    instance.createdStreamingEntities = {}
    instance.disablePlayerControl = true
    instance.hideHud = true
    instance.fadeout = false
    instance.fadeoutDuration = 3000
    instance.fadeinDuration = 3000
    instance.isResolving = false
    return instance
end

---Build and return with table without table method
---@return table
function CutsceneConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return CutsceneConfigBuilder
