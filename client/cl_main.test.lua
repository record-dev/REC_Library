
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.API, REC_Library.Shared.API
local clApi, shApi = require "@REC_Library.client.cl_api", require "@REC_Library.shared.sh_api"
local animations = shApi.Animations

RegisterCommand("rl-logout", function()
    -- SetGameplayCamRelativeHeading(0)
 
    -- while GetPlayerSwitchState() ~= 5 do
    --     Wait(0)
    -- end
SwitchOutPlayer(cache.ped, 0, 1)
end, false)

RegisterCommand("rl-login", function()


    SwitchInPlayer(cache.ped)
end, false)

RegisterCommand("rl-rotation", function()
    local rot = GetGameplayCamRot(0)
    lib.setClipboard(("vector3(%s, %s, %s)"):format(
        tostring(rot.x),
        tostring(rot.y),
        tostring(rot.z)
    ))
    utils:debugPrint("rot", rot)
end, false)

RegisterCommand("testAnim", function(_, args)

    if args == nil then
        utils:debugPrint("^1args is nil...^0")
        return
    end

    local animKey = args[1] --[[@as string]]
    if animKey == nil or type(animKey) ~= "string" then
        utils:debugPrint("^3animKey is invalid value...^0")
        return
    end

    local anim = animations[animKey]
    if anim == nil then
        utils:debugPrint(("^3anim is not founded... animKey: %s^0"):format(animKey))
        return
    end

    local animModelHash = joaat(anim.model)

    local objHandle = 0 --[[@as integer]]

    ---@type { object: number, coords: vector3 }[]
    local nearbyObjects = lib.getNearbyObjects(GetEntityCoords(cache.ped), 5.0)
    for _, nearbyObject in ipairs(nearbyObjects) do
        if animModelHash == GetEntityModel(nearbyObject.object) then
            objHandle = nearbyObject.object
            break
        end
    end

    if objHandle == 0 then
        utils:debugPrint("^3objHandle is not founded...^0")
        return
    end

    local coords = GetEntityCoords(objHandle)
    local rotation = GetEntityRotation(objHandle)

    local animationSceneManagerConfigBuilder = clApi.Class.Animation.Manager.AnimationSceneManagerConfigBuilder:new(
        cache.ped --[[@as integer]],
        objHandle,
        anim.dict,
        coords,
        rotation
    )
    :setCamera((function ()
        if anim.needCamera == true then
            return clApi.Class.Camera.Camera:new(
                clApi.Class.Camera.CameraConfigBuilder:new(
                    "DEFAULT_SCRIPTED_CAMERA",
                    coords,
                    rotation,
                    60.0,
                    false
                )
            )
        else
            return nil
        end
    end)())

    for sceneKey, sceneCfg in pairs(anim.scenes) do

        local animSceneConfigBuilder = clApi.Class.Animation.AnimationSceneConfigBuilder:new(
            coords,
            rotation,
            anim.dict,
            sceneCfg.pedAnim,
            sceneCfg.objAnim
        )

        animSceneConfigBuilder:setTickCallback(function (self)
            if IsControlJustPressed(0, 51) then -- E
                utils:debugPrint(self:getCurrentPhase())
            end
        end)

        if sceneCfg.phaseEvents ~= nil then
            for _, phase in ipairs(sceneCfg.phaseEvents) do
                animSceneConfigBuilder:setPhaseCallback(phase, function (self)
                    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end)
            end
        end

        animationSceneManagerConfigBuilder:setAnimScene(
            sceneKey,
            clApi.Class.Animation.AnimationScene:new(animSceneConfigBuilder)
                :setPropAnims((function ()
                    local propAnims = {} --[[@as table<string, { name: string, dict?: string, }>]]
                    for propAnimKey, propAnim in pairs(sceneCfg.propAnims) do
                        propAnims[propAnimKey] = {
                            name = propAnim.name,
                            dict = propAnim.dict,
                        }
                    end
                    return propAnims
                end)())
        )
    end

    local animatioSceneManager = clApi.Class.Animation.Manager.AnimationSceneManager:new(animationSceneManagerConfigBuilder)

    if animatioSceneManager:setup() == false then
        utils:debugPrint(("^3failed to setup anim... animKey: %s^0"):format(animKey))
        return
    end

    if animatioSceneManager:playAnimSceneByKey("enter", false) == false then
        return
    end

    -- if animatioSceneManager:playAnimSceneByKey("idle") == false then
    --     return
    -- end

    if animatioSceneManager:playAnimSceneByKey("simple", false) == false then
        return
    end

    if animatioSceneManager:playAnimSceneByKey("exit", false) == false then
        return
    end

    if animatioSceneManager:clear() == false then
        return
    end
end, false)

local interialIdMonitorThread = false --[[@as boolean]]
RegisterCommand("monitorInterial", function ()

    if interialIdMonitorThread == false then

        interialIdMonitorThread = true
        CreateThread(function (threadId)
            while interialIdMonitorThread == true do
                Citizen.Wait(500)
                local interialId = GetInteriorFromEntity(cache.ped) --[[@as integer]]
                utils:debugPrint("interialId", interialId)
            end
        end)
    else
        interialIdMonitorThread = false
    end
end, false)
RegisterCommand("rl-helptext", function (_, args)
    lib.showHelpText({
        text     = { "~INPUT_CONTEXT~ Interact", "~INPUT_FRONTEND_CANCEL~ ~r~Cancel~s~", },
        icon     = "circle-info",
        duration = tonumber(args[1]),
    })
end, false)

RegisterCommand("rl-helptextclear", function ()
    lib.hideHelpText()
end, false)

RegisterCommand("rl-subtitle", function (_, args)
    lib.showSubtitle({
        text     = "Get to the ~y~marked location~s~ before the timer runs out.",
        name     = "REC_Library",
        duration = tonumber(args[1]),
    })
end, false)

RegisterCommand("rl-subtitleclear", function ()
    lib.hideSubtitle()
end, false)
