
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

---[[
---     Gauge
---]]
---@type boolean
local gaugeRunning = false

---@param value number 0 to 1
---@return string colour
---@return string label
local function gaugeLook(value)

    if value >= 1.0 then
        return "#d63031", "SPOTTED"
    end

    if value >= 0.6 then
        return "#e19822", "SEARCHING"
    end

    return "#ebebeb", "WATCHING"
end

---@param shape? string
---@param position? string
---@param variant? string
local function startGauge(shape, position, variant)

    local id = lib.showGauge({
        id            = "rl-test",
        value         = 0.0,
        label         = "WATCHING",
        icon          = "eye",
        color         = "#ebebeb",
        position      = position,
        shape         = shape == "ring" and "ring" or "bar",
        variant       = variant == "plain" and "plain" or "card",
        width         = variant == "plain" and "10vw" or nil,
        showValue     = variant ~= "plain",
        hideWhenEmpty = false,
    })

    if gaugeRunning == true then
        return
    end

    gaugeRunning = true

    CreateThread(function ()

        ---@type number
        local value, step = 0.0, 0.02

        while gaugeRunning == true do

            value = value + step

            if value >= 1.0 then
                value, step = 1.0, -step
            elseif value <= 0.0 then
                value, step = 0.0, -step
            end

            local colour, label = gaugeLook(value)
            lib.updateGauge(id, { value = value, color = colour, label = label, })

            Citizen.Wait(value >= 1.0 and 1500 or 150)
        end
    end)
end

lib.addCommand("rl-gauge", {
    help = "Show a test gauge that fills and drains (debug)",
    params = {
        { name = "shape", help = "bar / ring (default bar)", optional = true, },
        { name = "position", help = "top-left ... bottom-right (default config)", optional = true, },
        { name = "variant", help = "card / plain (default card, plain is the native look)", optional = true, },
    },
}, function (_, args)
    startGauge(args.shape, args.position, args.variant)
end)

lib.addCommand("rl-gaugestatic", {
    help = "Show a second, still gauge next to the animated one (debug)",
    params = {
        { name = "percent", help = "0 - 100 (default 75)", type = "number", optional = true, },
    },
}, function (_, args)

    lib.showGauge({
        id        = "rl-static",
        value     = args.percent or 75,
        max       = 100,
        label     = "Filter",
        icon      = "mask-ventilator",
        color     = "#00ff88",
        position  = "right-center",
        shape     = "ring",
        showValue = true,
    })
end)

lib.addCommand("rl-gaugehide", {
    help = "Stop and hide every test gauge (debug)",
}, function ()

    gaugeRunning = false
    lib.hideGauge()

    local isOpen, ids = lib.isGaugeOpen()
    utils:debugPrint(("^2gauges hidden... isOpen: %s, remaining: %d^0"):format(tostring(isOpen), #ids))
end)



---[[
---     Menu builder sample
---]]
---@type REC_Library.Client.Class.UI.Menu|nil, REC_Library.Client.Class.UI.Menu|nil
local sampleMenu, sampleDetailsMenu = nil, nil

---@return table<string, string>
local function menuSampleStrings()
    local strings = json.decode(LoadResourceFile(GetCurrentResourceName(), "locales/web/en.json"))
    local raw = LoadResourceFile(GetCurrentResourceName(), ("locales/web/%s.json"):format(shApi.Config.language))
    if raw ~= nil then
        for key, value in pairs(json.decode(raw)) do
            strings[key] = value
        end
    end
    return strings
end

local function createMenuSample()
    local ui = clApi.Class.UI
    local strings = menuSampleStrings()

    ---@param id string
    ---@param value? REC_Library.Lib.Menu.Value
    local function report(id, value)
        local displayValue = tostring(value)
        if type(value) == "boolean" then
            displayValue = value == true and strings.MENU_YES or strings.MENU_NO
        end
        local result = (strings.MENU_SAMPLE_RESULT):format(id, displayValue)
        sampleMenu:updateItem("result", { value = result, })
        lib.showSubtitle({ text = result, name = strings.MENU_SAMPLE_TITLE, duration = 3000, })
        utils:debugPrint(("^2menu sample... %s = %s^0"):format(id, tostring(value)))
    end

    local detailsConfig = ui.MenuConfigBuilder:new("rl-menu-sample-details", strings.MENU_SAMPLE_DETAILS)
        :setSubtitle(strings.MENU_SAMPLE_BACK_HINT)
        :setPosition("top-right")
        :addItem(ui.MenuItemConfigBuilder:new("enable", strings.MENU_SAMPLE_ENABLE)
            :setIcon("lightbulb")
            :setDescription(strings.MENU_SAMPLE_UPDATE_HINT)
            :setOnSelect(function ()
                sampleMenu:setValue("checkbox", true)
                report("checkbox", sampleMenu:getValue("checkbox"))
            end))
        :addItem(ui.MenuItemConfigBuilder:new("child-action", strings.MENU_SAMPLE_BUTTON)
            :setOnSelect(function ()
                report("child-action", strings.MENU_SAMPLE_SELECTED)
            end))

    sampleDetailsMenu = ui.Menu:new(detailsConfig)
    sampleDetailsMenu:register()

    local menuConfig = ui.MenuConfigBuilder:new("rl-menu-sample", strings.MENU_SAMPLE_TITLE)
        :setSubtitle(strings.MENU_SAMPLE_HINT)
        :setPosition("top-right")
        :setVisibleItems(6)
        :addItem(ui.MenuItemConfigBuilder:new("button", strings.MENU_SAMPLE_BUTTON)
            :setIcon("play")
            :setDescription(strings.MENU_SAMPLE_BUTTON_HINT)
            :setOnSelect(function ()
                report("button", strings.MENU_SAMPLE_SELECTED)
            end))
        :addItem(ui.MenuItemConfigBuilder:new("checkbox", strings.MENU_SAMPLE_CHECKBOX, "checkbox")
            :setValue(false)
            :setOnChange(function (value)
                report("checkbox", value)
            end))
        :addItem(ui.MenuItemConfigBuilder:new("slider", strings.MENU_SAMPLE_SLIDER, "slider")
            :setValues({
                { label = strings.MENU_SAMPLE_NORMAL, value = "normal", },
                { label = strings.MENU_SAMPLE_SPORT, value = "sport", },
            })
            :setValue("normal")
            :setOnChange(function (value)
                report("slider", value)
            end))
        :addItem(ui.MenuItemConfigBuilder:new("range", strings.MENU_SAMPLE_RANGE, "range")
            :setRange(0, 100, 5)
            :setValue(50)
            :setOnChange(function (value)
                report("range", value)
            end))
        :addItem(ui.MenuItemConfigBuilder:new("confirm", strings.MENU_SAMPLE_CONFIRM, "confirm")
            :setDescription(strings.MENU_SAMPLE_CONFIRM_HINT)
            :setValue(false)
            :setOnSelect(function (value)
                report("confirm", value)
            end))
        :addItem(ui.MenuItemConfigBuilder:new("details", strings.MENU_SAMPLE_DETAILS, "submenu")
            :setIcon("folder-open")
            :setMenu("rl-menu-sample-details"))
        :addItem(ui.MenuItemConfigBuilder:new("disabled", strings.MENU_SAMPLE_DISABLED)
            :setDisabled(true))
        :addItem(ui.MenuItemConfigBuilder:new("result", strings.MENU_SAMPLE_LAST_RESULT, "label")
            :setValue(strings.MENU_SAMPLE_WAITING))
        :addItem(ui.MenuItemConfigBuilder:new("close", strings.MENU_CLOSE)
            :setIcon("xmark")
            :setCloseOnSelect(true))

    sampleMenu = ui.Menu:new(menuConfig)
end

lib.addCommand("rl-menu", {
    help = "Open the builder-based menu sample (debug)",
}, function ()
    if sampleMenu == nil then createMenuSample() end
    sampleMenu:open()
end)

lib.addCommand("rl-menuclose", {
    help = "Close the menu sample, including its submenu (debug)",
}, function ()
    local id = lib.getOpenMenu()
    if id == "rl-menu-sample" or id == "rl-menu-sample-details" then
        lib.hideMenu()
    end
end)
