
---[[
---     keybind (client)
---]]

---@class REC_Library.Lib.Keybind.Data
---@field name string
---@field description string
---@field defaultKey? string
---@field defaultMapper? string
---@field secondaryKey? string
---@field secondaryMapper? string
---@field disabled? boolean
---@field onPressed? fun(self: REC_Library.Lib.Keybind)
---@field onReleased? fun(self: REC_Library.Lib.Keybind)

---@class REC_Library.Lib.Keybind: REC_Library.Lib.Keybind.Data
---@field hash integer
---@field isPressed boolean
local Keybind = {}
Keybind.__index = Keybind

---@type table<string, REC_Library.Lib.Keybind>
local keybinds = {}

---@param toggle boolean
function Keybind:disable(toggle)
    self.disabled = toggle
end

---@return string
function Keybind:getCurrentKey()
    return GetControlInstructionalButton(0, self.hash, true):sub(3)
end

---@param data REC_Library.Lib.Keybind.Data
---@return REC_Library.Lib.Keybind
function lib.addKeybind(data)

    assert(type(data) == "table", "data must be a table")
    assert(type(data.name) == "string", "data.name must be a string")
    assert(type(data.description) == "string", "data.description must be a string")

    local keybind = setmetatable(data, Keybind) --[[@as REC_Library.Lib.Keybind]]
    keybind.hash = joaat("+" .. data.name) | 0x80000000
    keybind.isPressed = false
    keybinds[data.name] = keybind

    RegisterCommand("+" .. data.name, function ()

        if keybind.disabled == true then
            return
        end

        keybind.isPressed = true

        if keybind.onPressed ~= nil then
            keybind:onPressed()
        end
    end, false)

    RegisterCommand("-" .. data.name, function ()

        keybind.isPressed = false

        if keybind.disabled == true then
            return
        end

        if keybind.onReleased ~= nil then
            keybind:onReleased()
        end
    end, false)

    RegisterKeyMapping("+" .. data.name, data.description, data.defaultMapper or "keyboard", data.defaultKey or "")

    if data.secondaryKey ~= nil then
        RegisterKeyMapping("~!+" .. data.name, data.description, data.secondaryMapper or "keyboard", data.secondaryKey)
    end

    SetTimeout(500, function ()
        TriggerEvent("chat:removeSuggestion", "/+" .. data.name)
        TriggerEvent("chat:removeSuggestion", "/-" .. data.name)
    end)

    return keybind
end
