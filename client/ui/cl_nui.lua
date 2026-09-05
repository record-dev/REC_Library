
---[[
---     NUI bridge
---     One place that talks to web/, keeps the focus owners, and pushes the
---     locales/web/<language>.json strings once the page is ready.
---]]

---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"

---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.UI.Nui
local nui = {}

---@type table<string, boolean>
local focusOwners = {}

---@type boolean
local isReady = false

---@type fun()[]
local readyHandlers = {}

---@param action string
---@param data? any
function nui:send(action, data)
    SendNUIMessage({ action = action, data = data, })
end

---[[
---     Focus stays on while any owner holds it
---]]
---@param owner string
---@param toggle boolean
function nui:focus(owner, toggle)

    focusOwners[owner] = toggle == true and true or nil

    local hasFocus = next(focusOwners) ~= nil
    SetNuiFocus(hasFocus, hasFocus)
end

---@param owner string
---@return boolean
function nui:hasFocus(owner)
    return focusOwners[owner] == true
end

---@return boolean
function nui:isReady()
    return isReady
end

---[[
---     Runs every time the page reports ready, so an overlay can send its state again after a NUI reboot
---]]
---@param handler fun()
function nui:onReady(handler)
    readyHandlers[#readyHandlers+1] = handler
end

---@param name string
---@return table<string, string>|nil
local function loadStrings(name)

    local raw = LoadResourceFile(GetCurrentResourceName(), ("locales/web/%s.json"):format(name))
    if raw == nil then
        return nil
    end

    local decoded = json.decode(raw)
    if type(decoded) ~= "table" then
        utils:debugPrint(("^1failed to decode locales/web/%s.json...^0"):format(name))
        return nil
    end

    return decoded
end

---[[
---     Theme
---     web/ picks the skin by name, the options are the per theme knobs from sh_config
---]]
---@return REC_Library.Client.UI.Nui.Theme
function lib.getTheme()
    return {
        name = shCfg.theme,
        options = shCfg.themeOptions[shCfg.theme],
    }
end

exports("getTheme", lib.getTheme)

---[[
---     Layout of the HUD text, the per widget knobs from sh_config
---]]
---@return table
local function uiConfig()

    local helpTextCfg, subtitleCfg = shCfg.ui.helpText, shCfg.ui.subtitle

    return {
        helpText = {
            position          = helpTextCfg.position,
            offsetX           = helpTextCfg.offset.x,
            offsetY           = helpTextCfg.offset.y,
            maxWidth          = helpTextCfg.maxWidth,
            fontScale         = helpTextCfg.fontScale,
            animationDuration = helpTextCfg.animationDuration,
        },
        subtitle = {
            offsetY           = subtitleCfg.offset.y,
            maxWidth          = subtitleCfg.maxWidth,
            background        = subtitleCfg.background,
            fontScale         = subtitleCfg.fontScale,
            animationDuration = subtitleCfg.animationDuration,
        },
    }
end

RegisterNUICallback("ready", function (_, cb)
    cb(1)

    isReady = true
    nui:send("setTheme", lib.getTheme())
    nui:send("setLocale", loadStrings(shCfg.language) or loadStrings("en"))
    nui:send("setUiConfig", uiConfig())

    for _, handler in ipairs(readyHandlers) do
        handler()
    end
end)



---[[
---     Clipboard
---]]
---@param text string
function lib.setClipboard(text)
    nui:send("clipboard", { text = tostring(text), })
end

exports("setClipboard", lib.setClipboard)

return nui

---@class REC_Library.Client.UI.Nui.Theme
---@field name REC_Library.Shared.Enums.Theme
---@field options table|nil
