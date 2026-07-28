
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Server.Class.Ped.Ped
local Ped = require "@REC_Library.client.class.ped.cl_ped"

---@type REC_Library.Shared.Class.Ped.PedConfigBuilder
local PedConfigBuilder = require "@REC_Library.shared.class.ped.sh_pedConfigBuilder"

---@class REC_Library.Client.Class.Cutscene.Cutscene
---@field info REC_Library.Client.Class.Cutscene.CutsceneConfigBuilder
local Cutscene = {}
Cutscene.__index = Cutscene

---instantiation
---@param config REC_Library.Client.Class.Cutscene.CutsceneConfigBuilder
---@return self
function Cutscene:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Play cutscene
---@return boolean whether finished or not
function Cutscene:play()
    local info = self.info

    -- Check if it's in progress
    if info.isResolving then
        utils:debugPrint("[Cutscene:play]: Cutscene is already resolving.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Load cutscene
    if not self:requestCutscene(info.name) then
        utils:debugPrint("[Cutscene:play]: Failed to request cutscene with name " .. tostring(info.name))
        return false
    end

    -- if fade out is enabled
    if info.fadeout == true then
        DoScreenFadeOut(info.fadeoutDuration)
    end

    -- ==== Preparation before cutscene then ==== --

    -- First, make it transparent
    SetEntityVisible(info.ped, false, false)

    -- Move the player running the cutscene to the center point of the cutscene to prevent the terrain from melting.
    SetEntityCoords(
        info.ped,
        info.coords.x, info.coords.y, info.coords.z,
        false,
        false,
        false,
        false
    )

    -- Fixed to prevent falling
    FreezeEntityPosition(info.ped, true)

    -- Disable hit detection
    SetEntityCollision(info.ped, false, false)

    -- ==== Preparation before cutscene end ==== --

    -- Replacement of Ped used in cutscenes
    for key, entityName in pairs(info.streamingEntities) do

        -- Prepare a replacement ped
        local streamPedInstance = Ped:new(
            PedConfigBuilder:new(
                'mp_m_freemode_01',
                info.coords,
                90.0
            )
            :build()
        )

        if streamPedInstance:spawn() == false then
            utils:debugPrint("faled to spawn stream ped instance")
        end

        local streamPed = streamPedInstance.info.handle

        if streamPed == nil then
            utils:debugPrint("[Cutscene:play]: Failed to spawn streaming entity with name " .. tostring(entityName))
            return false
        end

        -- Replace by specifying the ped identifier of the replacement target cutscene.
        SetCutsceneEntityStreamingFlags(entityName, 0, 1)
        RegisterEntityForCutscene(streamPed, entityName, 0, 0, 64)

        -- Make clothes the same
        if key == 1 then
            for i = 0, 11 do
                local drawable = GetPedDrawableVariation(info.ped, i)
                local texture = GetPedTextureVariation(info.ped, i)
                local palette = GetPedPaletteVariation(info.ped, i)
                SetPedComponentVariation(streamPed, i, drawable, texture, palette)
            end
        end

        info.createdStreamingEntities[#info.createdStreamingEntities+1] = streamPedInstance
    end

    -- If it's a fade out, it's a fade in
    if IsScreenFadedOut() == true then
        DoScreenFadeIn(info.fadeinDuration)
    end

    -- Play cutscene
    StartCutsceneAtCoords(info.coords.x, info.coords.y, info.coords.z, 0)

    -- Force perspective to third person
    SetFollowPedCamViewMode(2)

    --Wait until the cutscene ends
    if not Cutscene:awaitEnd() then
       utils:debugPrint("[Cutscene:play]: awaitEnd error")
        return false
    end

    -- Items generated during cutscene playback and clearing work
    if not self:destroy() then
        utils:debugPrint("[Cutscene:play]: destroy error")
        return false
    end

    -- Force perspective to third person
    SetFollowPedCamViewMode(2)

    -- Move to last spawn point
    SetEntityCoords(
        info.ped,
        info.finalCoords.x,
        info.finalCoords.y,
        info.finalCoords.z,
        true,
        false,
        false,
        false
    )

    -- Return hit detection
    SetEntityCollision(info.ped, true, true)

    -- Fall prevention release
    FreezeEntityPosition(info.ped, false)

    -- Remove transparency
    SetEntityVisible(info.ped, true, false)

    -- lower flag in progress
    info.isResolving = false

    return true
end

---When you want to stop playing a cutscene
-- function Cutscene:stop()

-- end


---Processing when the cutscene ends
---@return boolean Completed?
function Cutscene:destroy()
    local info = self.info

    -- Delete
    for key, streamPedInstance in pairs(info.createdStreamingEntities) do
        if streamPedInstance:destroy() then
            info.createdStreamingEntities[key] = nil
        else
            utils:debugPrint("[Cutscene:destroy]: Failed to destroy streaming entity with ID " .. tostring(key))
            return false
        end
    end

    return true
end

---Object, vehicle model request
---@class REC_Library.Client.Functions.RequestCutscene
---@param cutscene string
---@param timeout? number
---@return boolean Completed?
function Cutscene:requestCutscene(cutscene, timeout)
    timeout = timeout or 2000 -- 2 seconds

    RequestCutscene(cutscene, 8)
    while not HasCutsceneLoaded() do
        timeout = timeout - 100
        if timeout <= 0 then
            utils:debugPrint("Cutscene loading timed out for object with cutscene " .. (cutscene or "N/A"))
            return false
        end
        Wait(100)
    end
    return true
end

---Helper function to wait until cutscene ends
---@param timeout? number Default cutscene length
---@param fadeOutStartTime? number How many milliseconds before timeout to start fadeout. Default is 2000ms.
---@return boolean Completed?
function Cutscene:awaitEnd(timeout, fadeOutStartTime)

    -- Initial settings of time and flags
    local startTime = GetGameTimer()
    local duration = timeout or GetCutsceneTotalDuration()
    local fadeTime = fadeOutStartTime or 2000
    local isFadeStarted = false

    -- Loop while cutscene is active
    while IsCutsceneActive() do
        local elapsedTime = GetGameTimer() - startTime
        local remainingTime = duration - elapsedTime

        -- timeout check
        if remainingTime <= 0 then
            utils:debugPrint("Cutscene:awaitEnd - Timed out.")
            return false
        end

        -- Fade out start check
        -- If the fade has not started yet and the remaining time is less than the fade start time
        if not isFadeStarted and remainingTime <= fadeTime then
            utils:debugPrint("Cutscene:awaitEnd - Starting fade out...")
            DoScreenFadeOut(fadeTime) -- Fade out over the same amount of time as the remaining time
            isFadeStarted = true      -- flag to avoid calling fade too many times
        end

        Wait(100)
    end

    -- If the loop terminates normally (doesn't time out)
    -- If it has started to fade out, bring the screen back to normal
    if isFadeStarted then
        DoScreenFadeIn(500)
    end

    return true
end

return Cutscene
