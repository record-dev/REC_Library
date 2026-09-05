
---[[
---     Subtitle (objective text at the bottom of the screen)
---     The NUI version of the GTA subtitle, one on screen at a time.
---     The NUI owns the timer, Lua only remembers what is up so isSubtitleOpen and a NUI reboot work.
---]]

---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"
local subtitleCfg = shCfg.ui.subtitle

---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@type REC_Library.Client.UI.Text
local text = require "@REC_Library.client.ui.cl_text"

---@class REC_Library.Lib.Subtitle.Data
---@field text string|string[] one string per line, ~y~ ~s~ ~n~ colour codes and "[E]" keycaps are drawn
---@field name? string speaker name drawn above the text
---@field color? string name colour (defaults to config.ui.subtitle.color)
---@field duration? integer ms, nil falls back to config.ui.subtitle.defaultDuration, 0 keeps it until lib.hideSubtitle
---@field id? string same id updates the subtitle in place

---@class REC_Library.Lib.Subtitle.Entry
---@field id string
---@field text string
---@field name string|nil
---@field color string
---@field duration integer 0 stays until hidden

---@type { entry: REC_Library.Lib.Subtitle.Entry, expiresAt: integer|nil }|nil
local current = nil

---[[
---     drop the remembered subtitle once its time is up
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
---@param data REC_Library.Lib.Subtitle.Data
---@return REC_Library.Lib.Subtitle.Entry|nil
local function build(data)

    assert(type(data) == "table", "data must be a table")

    local joined = text:join(data.text)
    if joined == nil or joined == "" then
        utils:debugPrint("^3subtitle text is empty...^0")
        return nil
    end

    return {
        id       = type(data.id) == "string" and data.id or text:generateId(),
        text     = text:formatControls(joined),
        name     = type(data.name) == "string" and data.name or nil,
        color    = type(data.color) == "string" and data.color or subtitleCfg.color,
        duration = text:duration(data.duration, subtitleCfg.defaultDuration),
    }
end



---[[
---     show a subtitle (replaces the one on screen)
---]]
---@param data REC_Library.Lib.Subtitle.Data
---@return string|nil id
function lib.showSubtitle(data)

    local entry = build(data)
    if entry == nil then
        return nil
    end

    current = {
        entry     = entry,
        expiresAt = text:expiresAt(entry.duration),
    }

    nui:send("subtitle", entry)

    return entry.id
end

---[[
---     dismiss the subtitle
---     with an id only that one is dismissed, so a late hide cannot remove a newer subtitle
---]]
---@param id? string
---@return boolean
function lib.hideSubtitle(id)

    expire()

    if current == nil then
        return false
    end

    if id ~= nil and id ~= current.entry.id then
        utils:debugPrint(("^3subtitle id does not match... id: %s^0"):format(tostring(id)))
        return false
    end

    current = nil
    nui:send("hideSubtitle", { id = id, })

    return true
end

---[[
---     whether a subtitle is on screen
---]]
---@return boolean isOpen
---@return string|nil id
function lib.isSubtitleOpen()

    expire()

    if current == nil then
        return false, nil
    end

    return true, current.entry.id
end

-- the NUI just booted, send the subtitle again with the time it has left
nui:onReady(function ()

    expire()

    if current == nil then
        return
    end

    nui:send("subtitle", text:remaining(current.entry, current.expiresAt))
end)

RegisterNetEvent("REC_Library:showSubtitle", lib.showSubtitle)
RegisterNetEvent("REC_Library:hideSubtitle", lib.hideSubtitle)

exports("showSubtitle", lib.showSubtitle)
exports("hideSubtitle", lib.hideSubtitle)
exports("isSubtitleOpen", lib.isSubtitleOpen)
