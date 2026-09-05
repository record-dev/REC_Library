
---[[
---     Context menu
---     Menus are registered by id and shown on demand. A menu keeps its option
---     callbacks here, the NUI only gets what it draws and answers with an index.
---]]

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Lib.Context.Option
---@field title? string
---@field description? string
---@field icon? string font awesome class, "fa-solid fa-gear" or just "gear"
---@field iconColor? string
---@field iconAnimation? string
---@field image? string
---@field progress? number 0-100
---@field colorScheme? string
---@field arrow? boolean
---@field disabled? boolean
---@field readOnly? boolean
---@field metadata? string[] | { label: string, value: any, progress?: number }[] | table<string, any>
---@field menu? string opens this menu on select
---@field onSelect? fun(args: any)
---@field event? string
---@field serverEvent? string
---@field args? any

---@class REC_Library.Lib.Context.Menu
---@field id string
---@field title string
---@field menu? string the menu the back button opens
---@field canClose? boolean default true
---@field onBack? fun()
---@field onExit? fun()
---@field options REC_Library.Lib.Context.Option[] | table<string, REC_Library.Lib.Context.Option>

---@type table<string, REC_Library.Lib.Context.Menu>
local menus = {}

---@type string|nil
local openMenu = nil

---[[
---     A menu can list options as an array or keyed by title
---]]
---@param options REC_Library.Lib.Context.Option[] | table<string, REC_Library.Lib.Context.Option>
---@return REC_Library.Lib.Context.Option[]
local function normalizeOptions(options)

    if options[1] ~= nil or next(options) == nil then
        return options --[[@as REC_Library.Lib.Context.Option[] ]]
    end

    local list = {}
    for title, option in pairs(options) do
        option.title = option.title or title
        list[#list+1] = option
    end

    table.sort(list, function (a, b)
        return a.title < b.title
    end)

    return list
end

---@param metadata any
---@return { label: string, value: any, progress?: number }[]|nil
local function normalizeMetadata(metadata)

    if type(metadata) ~= "table" then
        return nil
    end

    local list = {}

    if metadata[1] ~= nil then
        for _, entry in ipairs(metadata) do
            if type(entry) == "table" then
                list[#list+1] = { label = entry.label, value = entry.value, progress = entry.progress, }
            else
                list[#list+1] = { label = tostring(entry), }
            end
        end
    else
        for label, value in pairs(metadata) do
            list[#list+1] = { label = tostring(label), value = value, }
        end
    end

    return list
end

---@param menu REC_Library.Lib.Context.Menu
---@return table
local function toNuiMenu(menu)

    local options = {}

    for i, option in ipairs(menu.options) do
        options[i] = {
            title = option.title,
            description = option.description,
            icon = option.icon,
            iconColor = option.iconColor,
            iconAnimation = option.iconAnimation,
            image = option.image,
            progress = option.progress,
            colorScheme = option.colorScheme,
            arrow = option.arrow,
            disabled = option.disabled,
            readOnly = option.readOnly,
            metadata = normalizeMetadata(option.metadata),
            hasMenu = option.menu ~= nil,
        }
    end

    return {
        id = menu.id,
        title = menu.title,
        menu = menu.menu,
        canClose = menu.canClose,
        options = options,
    }
end

---@param context REC_Library.Lib.Context.Menu | REC_Library.Lib.Context.Menu[]
function lib.registerContext(context)

    assert(type(context) == "table", "context must be a table")

    if context[1] ~= nil then
        for _, menu in ipairs(context) do
            lib.registerContext(menu)
        end
        return
    end

    assert(type(context.id) == "string", "context.id must be a string")
    assert(type(context.options) == "table", "context.options must be a table")

    context.options = normalizeOptions(context.options)
    menus[context.id] = context
end

---@param id string
function lib.showContext(id)

    local menu = menus[id]
    if menu == nil then
        utils:debugPrint(("^3context menu is not registered... id: %s^0"):format(tostring(id)))
        return
    end

    openMenu = id
    nui:focus("context", true)
    nui:send("showContext", toNuiMenu(menu))
end

---@param onExit? boolean run the menu's onExit
function lib.hideContext(onExit)

    local menu = openMenu ~= nil and menus[openMenu] or nil
    openMenu = nil

    nui:focus("context", false)
    nui:send("hideContext")

    if onExit == true and menu ~= nil and menu.onExit ~= nil then
        menu.onExit()
    end
end

---@return string|nil
function lib.getOpenContextMenu()
    return openMenu
end

---@param data { id: string, index: integer }
RegisterNUICallback("contextSelect", function (data, cb)
    cb(1)

    local menu = menus[data.id]
    local option = menu ~= nil and menu.options[data.index] or nil
    if option == nil then
        return
    end

    if option.menu ~= nil then
        lib.showContext(option.menu)
    else
        lib.hideContext(false)
    end

    if option.onSelect ~= nil then
        option.onSelect(option.args)
    end

    if option.event ~= nil then
        TriggerEvent(option.event, option.args)
    end

    if option.serverEvent ~= nil then
        TriggerServerEvent(option.serverEvent, option.args)
    end
end)

---@param data { id: string }
RegisterNUICallback("contextBack", function (data, cb)
    cb(1)

    local menu = menus[data.id]
    if menu == nil then
        return
    end

    if menu.onBack ~= nil then
        menu.onBack()
    end

    if menu.menu ~= nil then
        lib.showContext(menu.menu)
    else
        lib.hideContext(true)
    end
end)

RegisterNUICallback("contextClose", function (_, cb)
    cb(1)
    lib.hideContext(true)
end)

exports("registerContext", lib.registerContext)
exports("showContext", lib.showContext)
exports("hideContext", lib.hideContext)
exports("getOpenContextMenu", lib.getOpenContextMenu)
