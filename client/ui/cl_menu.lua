
---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@type REC_Library.Client.Class.UI.MenuConfigBuilder
local MenuConfigBuilder = require "@REC_Library.client.class.ui.cl_menuConfigBuilder"

---@type REC_Library.Client.Class.UI.MenuItemConfigBuilder
local MenuItemConfigBuilder = require "@REC_Library.client.class.ui.cl_menuItemConfigBuilder"

---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"

---@class REC_Library.Client.UI.Menu.Entry
---@field config REC_Library.Client.Class.UI.MenuConfigBuilder
---@field selected? string

---@type table<string, table<string, REC_Library.Client.UI.Menu.Entry>>
local menus = {}

---@type { owner: string, entry: REC_Library.Client.UI.Menu.Entry, token: integer }|nil
local active = nil
---@type REC_Library.Client.UI.Menu.Entry[]
local history = {}
local sequence = 0
local controlsRunning = false

---@param key REC_Library.Shared.Config.MenuSound
local function playSound(key)
    local sound = shCfg.ui.menu.sounds[key]
    if sound == false or sound == nil then return end
    PlaySoundFrontend(-1, sound.name, sound.set, true)
end

local function startControls()
    if controlsRunning == true then return end
    controlsRunning = true
    CreateThread(function ()
        local controls = { [188] = "ArrowUp", [187] = "ArrowDown", [189] = "ArrowLeft", [190] = "ArrowRight", [201] = "Enter", [202] = "Escape", }
        -- pause menu, phone / frontend cancel, attack and melee: the keys and clicks the game would otherwise see while keepInput is on
        local blocked = { 24, 25, 140, 141, 142, 177, 194, 199, 200, 257, 263, 264, }
        while active ~= nil do
            if nui:isOnlyFocus("menu") == true then
                if shCfg.ui.menu.keepInput == true then
                    for _, control in ipairs(blocked) do
                        DisableControlAction(0, control, true)
                    end
                end
                -- keyboard keys reach the page directly, only the gamepad needs relaying
                local gamepad = IsInputDisabled(2) == false
                for control, key in pairs(controls) do
                    DisableControlAction(2, control, true)
                    if gamepad == true and IsDisabledControlJustPressed(2, control) ~= false then
                        nui:send("menuControl", { key = key, })
                    end
                end
            end
            Wait(0)
        end
        controlsRunning = false
    end)
end

---@return string
local function owner()
    return GetInvokingResource() or GetCurrentResourceName()
end

---@param callback? function
---@param ... any
local function invoke(callback, ...)
    if callback == nil then return end
    local ok, err = pcall(callback, ...)
    if ok == false then
        utils:debugPrint(("^1menu callback failed... %s^0"):format(tostring(err)))
    end
end

---@param item REC_Library.Client.Class.UI.MenuItemConfigBuilder
---@return boolean
local function selectable(item)
    return item.disabled ~= true and item.type ~= "label"
end

---@param entry REC_Library.Client.UI.Menu.Entry
local function ensureSelection(entry)
    for _, item in ipairs(entry.config.items) do
        if item.id == entry.selected and selectable(item) == true then return end
    end
    entry.selected = nil
    for _, item in ipairs(entry.config.items) do
        if selectable(item) == true then
            entry.selected = item.id
            return
        end
    end
end

local function send()
    if active == nil then return end
    local entry, config = active.entry, active.entry.config
    ensureSelection(entry)
    local items = {}
    for i, item in ipairs(config.items) do
        items[i] = {
            id = item.id, type = item.type, label = item.label, description = item.description,
            icon = item.icon, value = item.value, values = item.values,
            min = item.min, max = item.max, step = item.step, disabled = item.disabled,
        }
    end
    nui:send("showMenu", {
        id = config.id, token = active.token, title = config.title, subtitle = config.subtitle,
        position = config.position or "top-left", color = config.color or shCfg.ui.menu.color, banner = config.banner,
        width = config.width or 380, visibleItems = config.visibleItems or 8, canClose = config.canClose ~= false,
        canBack = #history > 0, selected = entry.selected, items = items,
    })
end

---@param reason string
---@param notify? boolean
local function close(reason, notify)
    if active == nil then return end
    local entry = active.entry
    active, history = nil, {}
    nui:send("hideMenu")
    nui:focus("menu", false)
    if notify ~= false then invoke(entry.config.onClose, reason) end
end

---@param resource string
---@param entry REC_Library.Client.UI.Menu.Entry
local function show(resource, entry)
    sequence = sequence + 1
    active = { owner = resource, entry = entry, token = sequence, }
    nui:focus("menu", true)
    send()
    startControls()
    invoke(entry.config.onOpen)
end

---@param config REC_Library.Client.Class.UI.MenuConfigBuilder
---@return boolean
function lib.registerMenu(config)
    local resource = owner()
    local normalized = MenuConfigBuilder.build(config)
    menus[resource] = menus[resource] or {}
    local entry = menus[resource][normalized.id]
    if entry == nil then
        entry = { config = normalized, }
        menus[resource][normalized.id] = entry
    else
        entry.config = normalized
    end
    if active ~= nil and active.entry == entry then
        sequence = sequence + 1
        active.token = sequence
        send()
    end
    return true
end

---@param id string
---@return boolean
function lib.showMenu(id)
    local resource = owner()
    local entry = menus[resource] ~= nil and menus[resource][id] or nil
    if entry == nil then return false end
    close("replaced")
    -- An onClose callback can open a different menu.
    if active ~= nil or menus[resource] == nil or menus[resource][id] ~= entry then return false end
    show(resource, entry)
    playSound("open")
    return true
end

---@return boolean
function lib.hideMenu()
    if active == nil or active.owner ~= owner() then return false end
    close("hidden")
    return true
end

---@return string|nil
function lib.getOpenMenu()
    if active ~= nil and active.owner == owner() then return active.entry.config.id end
end

---@param id string
---@return boolean
function lib.unregisterMenu(id)
    local resource = owner()
    local entry = menus[resource] ~= nil and menus[resource][id] or nil
    if entry == nil then return false end
    menus[resource][id] = nil
    for i = #history, 1, -1 do
        if history[i] == entry then table.remove(history, i) end
    end
    if active ~= nil and active.entry == entry then close("removed") end
    return true
end

---@param id string
---@param itemId string
---@return REC_Library.Lib.Menu.Value|nil
function lib.getMenuValue(id, itemId)
    local resource = owner()
    local entry = menus[resource] ~= nil and menus[resource][id] or nil
    if entry == nil then return end
    for _, item in ipairs(entry.config.items) do
        if item.id == itemId then return item.value end
    end
end

---@param id string
---@param itemId string
---@param patch table
---@return boolean
function lib.updateMenuItem(id, itemId, patch)
    assert(type(patch) == "table", "patch must be a table")
    assert(patch.id == nil or patch.id == itemId, "item id cannot change")
    local resource = owner()
    local entry = menus[resource] ~= nil and menus[resource][id] or nil
    if entry == nil then return false end
    for i, item in ipairs(entry.config.items) do
        if item.id == itemId then
            local config = {}
            for key, value in pairs(item) do config[key] = value end
            for key, value in pairs(patch) do config[key] = value end
            entry.config.items[i] = MenuItemConfigBuilder.build(config)
            if active ~= nil and active.entry == entry then
                sequence = sequence + 1
                active.token = sequence
                send()
            end
            return true
        end
    end
    return false
end

---@param item REC_Library.Client.Class.UI.MenuItemConfigBuilder
---@param direction integer
---@return REC_Library.Lib.Menu.Value|nil
local function nextValue(item, direction)
    if item.type == "checkbox" or item.type == "confirm" then
        return item.value == false
    end
    if item.type == "range" then
        return math.min(item.max, math.max(item.min, tonumber(("%.10g"):format(item.value + item.step * direction))))
    end
    if item.type == "slider" then
        for i, choice in ipairs(item.values) do
            if choice.value == item.value then
                return item.values[(i - 1 + direction) % #item.values + 1].value
            end
        end
    end
    return item.value
end

---@param data { token: integer, action: string, item?: string, direction?: integer }
RegisterNUICallback("menuAction", function (data, cb)
    cb(1)
    local current = active
    if current == nil or type(data) ~= "table" or data.token ~= current.token or nui:isOnlyFocus("menu") == false then return end
    local entry, config = current.entry, current.entry.config

    if data.action == "back" then
        if #history > 0 then
            local parent = table.remove(history)
            playSound("back")
            invoke(config.onBack)
            if active ~= current then return end
            if menus[current.owner] == nil or menus[current.owner][parent.config.id] ~= parent then
                close("removed")
                return
            end
            show(current.owner, parent)
        elseif config.canClose ~= false then
            playSound("close")
            close("exit")
        end
        return
    end
    if data.action == "close" then
        if config.canClose ~= false then
            playSound("close")
            close("exit")
        end
        return
    end

    local item = nil
    for _, candidate in ipairs(config.items) do
        if candidate.id == data.item then item = candidate break end
    end
    if item == nil or selectable(item) == false then return end

    if data.action == "hover" then
        local previous = entry.selected
        entry.selected = item.id
        if previous ~= item.id then
            playSound("navigate")
            invoke(config.onSwitch, item.id, previous)
        end
        return
    end
    if data.action ~= "select" and data.action ~= "change" then return end
    if data.action == "change" and data.direction ~= 1 and data.direction ~= -1 then return end
    entry.selected = item.id
    playSound(data.action)

    if data.action == "change" or (data.action == "select" and item.type == "checkbox") then
        local oldValue = item.value
        item.value = nextValue(item, data.direction or 1)
        send()
        if item.value ~= oldValue then invoke(item.onChange, item.value, oldValue, item.args, item.id) end
        if data.action == "change" or active ~= current then return end
    end

    if item.type == "submenu" then
        local child = menus[current.owner][item.menu]
        if child == nil or child == entry then return end
        for _, parent in ipairs(history) do
            if parent == child then return end
        end
        history[#history+1] = entry
        show(current.owner, child)
    elseif item.closeOnSelect == true then
        close("select")
    end
    invoke(item.onSelect, item.value, item.args, item.id)
end)

nui:onReady(function ()
    if active == nil then return end
    nui:focus("menu", true)
    send()
end)

---@param resource string
AddEventHandler("onClientResourceStop", function (resource)
    menus[resource] = nil
    if active ~= nil and (active.owner == resource or resource == GetCurrentResourceName()) then
        close("resourceStop", false)
    end
end)

exports("registerMenu", lib.registerMenu)
exports("showMenu", lib.showMenu)
exports("hideMenu", lib.hideMenu)
exports("getOpenMenu", lib.getOpenMenu)
exports("unregisterMenu", lib.unregisterMenu)
exports("getMenuValue", lib.getMenuValue)
exports("updateMenuItem", lib.updateMenuItem)
