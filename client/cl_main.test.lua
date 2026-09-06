
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



---[[
---     input dialog
---     /rl-input          every row type at once
---     /rl-input simple   string rows only
---]]
lib.addCommand("rl-input", {
    help = "Show a test input dialog (debug)",
    params = {
        { name = "mode", help = "simple / full (default full)", optional = true, },
    },
}, function (_, args)

    local rows = (function ()
        if args.mode == "simple" then
            return { "Name", "Comment", }
        end

        return {
            { type = "input",        label = "Name",        description = "plain text",       placeholder = "Nazu",       icon = "user",      required = true, },
            { type = "input",        label = "Password",    password = true,                  icon = "lock", },
            { type = "number",       label = "Amount",      description = "min 0 / max 100",  min = 0, max = 100, step = 1, default = 10, icon = "coins", },
            { type = "checkbox",     label = "Agree",       default = true, },
            { type = "select",       label = "Job",         options = { { value = "police", label = "Police", }, { value = "ambulance", label = "Ambulance", }, { value = "mechanic", label = "Mechanic", }, }, default = "police", clearable = true, searchable = true, },
            { type = "multi-select", label = "Tags",        options = { { value = "a", label = "Alpha", }, { value = "b", label = "Bravo", }, { value = "c", label = "Charlie", }, }, default = { "a", "c", }, },
            { type = "slider",       label = "Volume",      min = 0, max = 100, step = 5, default = 50, },
            { type = "color",        label = "Color",       default = "#33cc99", },
            { type = "date",         label = "Date",        format = "DD/MM/YYYY", returnString = true, },
            { type = "time",         label = "Time", },
            { type = "textarea",     label = "Memo",        autosize = true, placeholder = "free text", },
        }
    end)()

    local values = lib.inputDialog("REC_Library input", rows, { allowCancel = true, })
    if values == nil then
        utils:debugPrint("^3input dialog is cancelled...^0")
        return
    end

    for i, row in ipairs(rows) do
        local label = type(row) == "string" and row or row.label
        utils:debugPrint(("^2[%d] %s = %s^0"):format(i, label, json.encode(values[i])))
    end
end)

lib.addCommand("rl-inputclose", {
    help = "Close the input dialog from Lua (debug)",
}, function ()
    lib.closeInputDialog()
end)



---[[
---     progress bar / circle
---     /rl-progress [duration] [position]   bar with anim + prop + disabled controls
---     /rl-progresscircle [duration]
---]]
---@param duration? number
---@param position? string
---@return REC_Library.Lib.Progress.Data
local function buildProgressData(duration, position)
    return {
        duration    = duration or 5000,
        label       = "REC_Library progress",
        position    = position == "middle" and "middle" or "bottom",
        canCancel   = true,
        useWhileDead = false,
        disable     = { move = true, car = true, combat = true, },
        anim        = { dict = "mp_common", clip = "givetake1_a", flag = 49, },
        prop        = { model = `prop_cs_burger_01`, bone = 60309, pos = vector3(0.02, 0.02, -0.02), rot = vector3(0.0, 0.0, 0.0), },
    }
end

lib.addCommand("rl-progress", {
    help = "Show a test progress bar (debug)",
    params = {
        { name = "duration", help = "ms (default 5000)", type = "number", optional = true, },
        { name = "position", help = "bottom / middle (default bottom)", optional = true, },
    },
}, function (_, args)

    local completed = lib.progressBar(buildProgressData(args.duration, args.position))
    utils:debugPrint(("^2progress bar is finished... completed: %s^0"):format(tostring(completed)))
end)

lib.addCommand("rl-progresscircle", {
    help = "Show a test progress circle (debug)",
    params = {
        { name = "duration", help = "ms (default 5000)", type = "number", optional = true, },
        { name = "position", help = "bottom / middle (default bottom)", optional = true, },
    },
}, function (_, args)

    local completed = lib.progressCircle(buildProgressData(args.duration, args.position))
    utils:debugPrint(("^2progress circle is finished... completed: %s^0"):format(tostring(completed)))
end)

lib.addCommand("rl-progresscancel", {
    help = "Cancel the running progress from Lua (debug)",
}, function ()
    lib.cancelProgress()
end)
