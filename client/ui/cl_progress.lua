
---[[
---     Progress bar / circle
---     Blocks for data.duration, true when it ran through, false when cancelled.
---]]

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@class REC_Library.Lib.Progress.Anim
---@field dict? string
---@field clip? string
---@field flag? integer
---@field blendIn? number
---@field blendOut? number
---@field duration? integer
---@field playbackRate? number
---@field lockX? boolean
---@field lockY? boolean
---@field lockZ? boolean
---@field scenario? string
---@field playEnter? boolean

---@class REC_Library.Lib.Progress.Prop
---@field model string | integer
---@field bone? integer
---@field pos? vector3
---@field rot? vector3
---@field rotOrder? integer

---@class REC_Library.Lib.Progress.Data
---@field duration integer ms
---@field label? string
---@field position? "bottom" | "middle"
---@field useWhileDead? boolean
---@field allowRagdoll? boolean
---@field allowSwimming? boolean
---@field allowCuffed? boolean
---@field allowFalling? boolean
---@field canCancel? boolean
---@field anim? REC_Library.Lib.Progress.Anim
---@field prop? REC_Library.Lib.Progress.Prop | REC_Library.Lib.Progress.Prop[]
---@field disable? { move?: boolean, car?: boolean, combat?: boolean, mouse?: boolean, sprint?: boolean }

---@type REC_Library.Lib.Progress.Data|nil
local progress = nil

---@type promise|nil
local active = nil

---@type integer[]
local props = {}

---@type table<string, integer[]>
local controls = {
    move = { 30, 31, 36, 21, 22, },
    car = { 63, 64, 71, 72, 75, },
    combat = { 24, 25, 37, 47, 58, 140, 141, 142, 257, 263, 264, },
    mouse = { 1, 2, 106, },
    sprint = { 21, },
}

---@param data REC_Library.Lib.Progress.Data
local function playAnimation(data)

    local anim = data.anim
    if anim == nil then
        return
    end

    if anim.scenario ~= nil then
        TaskStartScenarioInPlace(cache.ped, anim.scenario, 0, anim.playEnter ~= false)
        return
    end

    if anim.dict == nil or anim.clip == nil then
        return
    end

    if lib.requestAnimDict(anim.dict, 2000) == nil then
        return
    end

    TaskPlayAnim(
        cache.ped, anim.dict, anim.clip,
        anim.blendIn or 3.0, anim.blendOut or 1.0, anim.duration or -1,
        anim.flag or 49, anim.playbackRate or 0.0,
        anim.lockX == true, anim.lockY == true, anim.lockZ == true
    )

    RemoveAnimDict(anim.dict)
end

---@param prop REC_Library.Lib.Progress.Prop
local function attachProp(prop)

    local model = lib.requestModel(prop.model, 2000)
    if model == nil then
        return
    end

    local coords = GetEntityCoords(cache.ped)
    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    local pos = prop.pos or vector3(0.0, 0.0, 0.0)
    local rot = prop.rot or vector3(0.0, 0.0, 0.0)

    AttachEntityToEntity(
        object, cache.ped, GetPedBoneIndex(cache.ped, prop.bone or 60309),
        pos.x, pos.y, pos.z, rot.x, rot.y, rot.z,
        true, true, false, true, prop.rotOrder or 0, true
    )

    SetModelAsNoLongerNeeded(model)
    props[#props+1] = object
end

---@param data REC_Library.Lib.Progress.Data
local function attachProps(data)

    if data.prop == nil then
        return
    end

    if data.prop.model ~= nil then
        attachProp(data.prop --[[@as REC_Library.Lib.Progress.Prop]])
        return
    end

    for _, prop in ipairs(data.prop --[[@as REC_Library.Lib.Progress.Prop[] ]]) do
        attachProp(prop)
    end
end

local function cleanup()

    for _, object in ipairs(props) do
        if DoesEntityExist(object) ~= false then
            DeleteEntity(object)
        end
    end

    props = {}

    if progress ~= nil and progress.anim ~= nil then
        if progress.anim.scenario ~= nil then
            ClearPedTasks(cache.ped)
        elseif progress.anim.dict ~= nil then
            StopAnimTask(cache.ped, progress.anim.dict, progress.anim.clip, 1.0)
        end
    end

    progress = nil
end

---@param data REC_Library.Lib.Progress.Data
---@return boolean cancel
local function shouldCancel(data)

    local ped = cache.ped

    if data.useWhileDead ~= true and IsEntityDead(ped) ~= false then
        return true
    end

    if data.allowRagdoll ~= true and IsPedRagdoll(ped) ~= false then
        return true
    end

    if data.allowCuffed ~= true and IsPedCuffed(ped) ~= false then
        return true
    end

    if data.allowFalling ~= true and IsPedFalling(ped) ~= false then
        return true
    end

    if data.allowSwimming ~= true and IsPedSwimming(ped) ~= false then
        return true
    end

    return false
end

---@param data REC_Library.Lib.Progress.Data
local function watch(data)

    CreateThread(function ()
        while progress == data do

            if data.disable ~= nil then
                for key, list in pairs(controls) do
                    if data.disable[key] == true then
                        for _, control in ipairs(list) do
                            DisableControlAction(0, control, true)
                        end
                    end
                end
            end

            if shouldCancel(data) == true then
                lib.cancelProgress()
            end

            Wait(0)
        end
    end)
end

---@param data REC_Library.Lib.Progress.Data
---@param circle boolean
---@return boolean
local function run(data, circle)

    assert(type(data) == "table", "data must be a table")
    assert(type(data.duration) == "number", "data.duration must be a number")

    -- one at a time
    if progress ~= nil then
        return false
    end

    progress = data

    local p = promise.new()
    active = p

    playAnimation(data)
    attachProps(data)
    watch(data)

    nui:send("progress", {
        duration = data.duration,
        label = data.label,
        position = data.position,
        circle = circle,
    })

    ---@type boolean
    local completed = Citizen.Await(p)

    cleanup()

    return completed
end

---@param data REC_Library.Lib.Progress.Data
---@return boolean
function lib.progressBar(data)
    return run(data, false)
end

---@param data REC_Library.Lib.Progress.Data
---@return boolean
function lib.progressCircle(data)
    return run(data, true)
end

---@return boolean
function lib.progressActive()
    return progress ~= nil
end

function lib.cancelProgress()

    local p = active
    if p == nil then
        return
    end

    active = nil
    nui:send("progressCancel")
    p:resolve(false)
end

RegisterNUICallback("progressComplete", function (_, cb)
    cb(1)

    local p = active
    if p == nil then
        return
    end

    active = nil
    p:resolve(true)
end)

lib.addKeybind({
    name = "rec_cancelprogress",
    description = "Cancel the current progress bar",
    defaultKey = "x",
    onPressed = function ()
        if progress ~= nil and progress.canCancel == true then
            lib.cancelProgress()
        end
    end,
})

exports("progressBar", lib.progressBar)
exports("progressCircle", lib.progressCircle)
exports("progressActive", lib.progressActive)
exports("cancelProgress", lib.cancelProgress)
