
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Shared.Config
local sh_config = require "@REC_Library.shared.sh_config"

---@class REC_Library.Client.Functions
local functions = {}

--[[
    --        _____  __       ________       ________       ______        ________
    --        __  / / /       ___  __/       ____  _/       ___  /        __  ___/
    --        _  / / /        __  /           __  /         __  /         _____ \ 
    --        / /_/ /         _  /           __/ /          _  /___       ____/ / 
    --        \____/          /_/            /___/          /_____/       /____/  
    --                                                                            
--]]

---Request ownership of an entity
---@class REC_Library.Client.Functions.RequestOwnership
---@param entity number
---@param timeout? number default 5000
---@return boolean Completed?
function functions.requestOwnership(entity, timeout)
    timeout = timeout or 5000

    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and timeout > 0 do
        Wait(50)
        timeout = timeout - 50
    end

    -- Check if ownership was finally obtained
    if not NetworkHasControlOfEntity(entity) then
        utils:debugPrint("Failed to gain control of entity with ID " .. tostring(entity))
        return false
    end
    return true
end

---Object, vehicle model request
---@class REC_Library.Client.Functions.RequestModel
---@param modelHash number
---@param timeout? number
---@return boolean Completed?
function functions.requestModel(modelHash, timeout)
    timeout = timeout or 2000 -- 2 seconds

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        timeout = timeout - 100
        if timeout <= 0 then
            utils:debugPrint("Model loading timed out for object with modelHash " .. (modelHash or "N/A"))
            return false
        end
        Wait(100)
    end
    return true
end

---Object, vehicle model request
---@class REC_Library.Client.Functions.RequestAnimDict
---@param dict string
---@param timeout? number
---@return boolean Completed?
function functions.requestAnimDict(dict, timeout)
    timeout = timeout or 2000 -- 2 seconds

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        timeout = timeout - 100
        if timeout <= 0 then
            utils:debugPrint("Dict loading timed out for object with dict " .. (dict or "N/A"))
            return false
        end
        Wait(100)
    end
    return true
end

---Loading particles
---@class REC_Library.Client.Functions.RequestNamedPtfxAsset
---@param asset string Effect asset name
---@param timeout? number Default is 2000 milliseconds (2 seconds)
---@return boolean Completed?
function functions.requestNamedPtfxAsset(asset, timeout)
    timeout = timeout or 2000 -- 2 seconds

    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        timeout = timeout - 100
        if timeout <= 0 then
            utils:debugPrint("Ptfx asset loading timed out for asset " .. (asset or "N/A"))
            return false
        end
        Wait(100)
    end
    return true
end

--[[
    --                      _______ ________________________________ _____   __________               
    --                      ___    |__  ____/___  __/____  _/__  __ \___  | / /__  ___/               
    --       ________       __  /| |_  /     __  /    __  /  _  / / /__   |/ / _____ \        ________
    --       _/_____/       _  ___ |/ /___   _  /    __/ /   / /_/ / _  /|  /  ____/ /        _/_____/
    --                      /_/  |_|\____/   /_/     /___/   \____/  /_/ |_/   /____/                 
    --                                                                                                
--]]

---Grant interaction
---@param entity number
---@param targetConfig REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder|REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder
---@param distance? number
---@return boolean
function functions.addTargetEntity(entity, targetConfig, distance)
    distance = distance or 2.0

    -- Check if the destination object exists
    if not entity or DoesEntityExist(entity) == false then
        utils:debugPrint("Entity does not exist or is invalid.")
        return false
    end

    if sh_config.target == "ox" then

        exports[sh_config.resources.target.ox_target]:addLocalEntity(entity, {targetConfig})

    elseif sh_config.target == "qb" then

        exports[sh_config.resources.target.qb_target]:AddTargetEntity(entity, {
            options = {targetConfig},
            distance = distance
        })

    else
        utils:debugPrint("Unsupported target system: " .. sh_config.target)
        return false
    end

    return true
end

return functions
