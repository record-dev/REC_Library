
---[[
---     Help text (control hint)
---     The NUI version of the GTA help text, one on screen at a time.
---     The NUI owns the timer, Lua only remembers what is up so isHelpTextOpen and a NUI reboot work.
---]]

---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"
local helpTextCfg = shCfg.ui.helpText

---@type REC_Library.Shared.Enums
local shEnums = require "@REC_Library.shared.sh_enums"

---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@type REC_Library.Client.UI.Text
local text = require "@REC_Library.client.ui.cl_text"

---@class REC_Library.Lib.HelpText.Data
---@field text string|string[] one string per line, "~INPUT_CONTEXT~" tokens become keycaps, "[E]" too, ~y~ ~s~ ~n~ colour codes are drawn
---@field icon? string font awesome class
---@field color? string icon and keycap colour (defaults to config.ui.helpText.color)
---@field position? REC_Library.Shared.Enums.HelpTextPosition
---@field duration? integer ms, nil or 0 keeps it until lib.hideHelpText
---@field id? string same id updates the help text in place

---@class REC_Library.Lib.HelpText.Entry
---@field id string
---@field text string
---@field icon string|nil
---@field color string
---@field position REC_Library.Shared.Enums.HelpTextPosition
---@field duration integer 0 stays until hidden

---@type table<string, true>
local validPositions = (function ()
    local positions = {}
    for _, position in pairs(shEnums.HelpTextPosition) do
        positions[position] = true
    end
    return positions
end)()

---@type { entry: REC_Library.Lib.HelpText.Entry, expiresAt: integer|nil }|nil
local current = nil

---[[
---     drop the remembered help text once its time is up
---]]
local function expire()

    if current == nil or current.expiresAt == nil then
        return
    end

    if GetGameTimer() >= current.expiresAt then
        current = nil
    end
end

---[[
---     shape the data into what the NUI expects
---]]
---@param data REC_Library.Lib.HelpText.Data
---@return REC_Library.Lib.HelpText.Entry|nil
local function build(data)

    assert(type(data) == "table", "data must be a table")

    local joined = text:join(data.text)
    if joined == nil or joined == "" then
        utils:debugPrint("^3help text is empty...^0")
        return nil
    end

    return {
        id       = type(data.id) == "string" and data.id or text:generateId(),
        text     = text:formatControls(joined),
        icon     = type(data.icon) == "string" and data.icon or nil,
        color    = type(data.color) == "string" and data.color or helpTextCfg.color,
        position = validPositions[data.position] == true and data.position or helpTextCfg.position,
        duration = text:duration(data.duration, 0),
    }
end



---[[
---     show a help text (replaces the one on screen)
---]]
---@param data REC_Library.Lib.HelpText.Data
---@return string|nil id
function lib.showHelpText(data)

    local entry = build(data)
    if entry == nil then
        return nil
    end

    current = {
        entry     = entry,
        expiresAt = text:expiresAt(entry.duration),
    }

    nui:send("helpText", entry)

    return entry.id
end

---[[
---     dismiss the help text
---     with an id only that one is dismissed, so a late hide cannot remove a newer text
---]]
---@param id? string
---@return boolean
function lib.hideHelpText(id)

    expire()

    if current == nil then
        return false
    end

    if id ~= nil and id ~= current.entry.id then
        utils:debugPrint(("^3help text id does not match... id: %s^0"):format(tostring(id)))
        return false
    end

    current = nil
    nui:send("hideHelpText", { id = id, })

    return true
end

---[[
---     whether a help text is on screen
---]]
---@return boolean isOpen
---@return string|nil id
function lib.isHelpTextOpen()

    expire()

    if current == nil then
        return false, nil
    end

    return true, current.entry.id
end

-- the NUI just booted, send the help text again with the time it has left
nui:onReady(function ()

    expire()

    if current == nil then
        return
    end

    nui:send("helpText", text:remaining(current.entry, current.expiresAt))
end)

RegisterNetEvent("REC_Library:showHelpText", lib.showHelpText)
RegisterNetEvent("REC_Library:hideHelpText", lib.hideHelpText)

exports("showHelpText", lib.showHelpText)
exports("hideHelpText", lib.hideHelpText)
exports("isHelpTextOpen", lib.isHelpTextOpen)
