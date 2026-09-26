
---@alias REC_Library.Lib.Menu.ItemType "button" | "checkbox" | "slider" | "range" | "confirm" | "submenu" | "label"
---@alias REC_Library.Lib.Menu.Value string | number | boolean

---@class REC_Library.Lib.Menu.Choice
---@field label string
---@field value REC_Library.Lib.Menu.Value
---@field description? string

---@class REC_Library.Client.Class.UI.MenuItemConfigBuilder
---@field id string
---@field label string
---@field type REC_Library.Lib.Menu.ItemType
---@field description? string
---@field icon? string
---@field value? REC_Library.Lib.Menu.Value
---@field values? REC_Library.Lib.Menu.Choice[]
---@field min? number
---@field max? number
---@field step? number
---@field menu? string
---@field disabled? boolean
---@field closeOnSelect? boolean
---@field args? any
---@field onSelect? fun(value: REC_Library.Lib.Menu.Value|nil, args: any, id: string)
---@field onChange? fun(value: REC_Library.Lib.Menu.Value, oldValue: REC_Library.Lib.Menu.Value, args: any, id: string)
local MenuItemConfigBuilder = {}
MenuItemConfigBuilder.__index = MenuItemConfigBuilder

---@param id string
---@param label string
---@param itemType? REC_Library.Lib.Menu.ItemType
---@return self
function MenuItemConfigBuilder:new(id, label, itemType)
    assert(type(id) == "string" and id ~= "", "item.id must be a non-empty string")
    assert(type(label) == "string", "item.label must be a string")
    local instance = setmetatable({}, self)
    instance.id, instance.label = id, label
    instance:setType(itemType or "button")
    return instance
end

---@param value? REC_Library.Lib.Menu.ItemType
---@return self
function MenuItemConfigBuilder:setType(value)
    if value == nil then return self end
    assert(({ button = true, checkbox = true, slider = true, range = true, confirm = true, submenu = true, label = true, })[value] == true, "invalid type")
    self.type = value
    return self
end

---@param value? string
---@return self
function MenuItemConfigBuilder:setLabel(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid label")
    self.label = value
    return self
end

---@param value? string
---@return self
function MenuItemConfigBuilder:setDescription(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid description")
    self.description = value
    return self
end

---@param value? string
---@return self
function MenuItemConfigBuilder:setIcon(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid icon")
    self.icon = value
    return self
end

---@param value? REC_Library.Lib.Menu.Value
---@return self
function MenuItemConfigBuilder:setValue(value)
    if value == nil then return self end
    assert(type(value) == "string" or type(value) == "boolean" or (type(value) == "number" and value == value and math.abs(value) < math.huge), "invalid value")
    self.value = value
    return self
end

---@param value? REC_Library.Lib.Menu.Choice[]
---@return self
function MenuItemConfigBuilder:setValues(value)
    if value == nil then return self end
    assert(type(value) == "table", "invalid values")
    self.values = value
    return self
end

---@param value? string
---@return self
function MenuItemConfigBuilder:setMenu(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid menu")
    self.menu = value
    return self
end

---@param value? boolean
---@return self
function MenuItemConfigBuilder:setDisabled(value)
    if value == nil then return self end
    assert(type(value) == "boolean", "invalid disabled")
    self.disabled = value
    return self
end

---@param value? boolean
---@return self
function MenuItemConfigBuilder:setCloseOnSelect(value)
    if value == nil then return self end
    assert(type(value) == "boolean", "invalid closeOnSelect")
    self.closeOnSelect = value
    return self
end

---@param value? any
---@return self
function MenuItemConfigBuilder:setArgs(value)
    if value == nil then return self end
    assert(true, "invalid args")
    self.args = value
    return self
end

---@param value? fun(value: REC_Library.Lib.Menu.Value|nil, args: any, id: string)
---@return self
function MenuItemConfigBuilder:setOnSelect(value)
    if value == nil then return self end
    assert(type(value) == "function" or (type(value) == "table" and type(rawget(value, "__cfx_functionReference")) == "string"), "invalid onSelect")
    self.onSelect = value
    return self
end

---@param value? fun(value: REC_Library.Lib.Menu.Value, oldValue: REC_Library.Lib.Menu.Value, args: any, id: string)
---@return self
function MenuItemConfigBuilder:setOnChange(value)
    if value == nil then return self end
    assert(type(value) == "function" or (type(value) == "table" and type(rawget(value, "__cfx_functionReference")) == "string"), "invalid onChange")
    self.onChange = value
    return self
end

---@param min number
---@param max number
---@param step? number
---@return self
function MenuItemConfigBuilder:setRange(min, max, step)
    step = step or 1
    assert(type(min) == "number" and math.abs(min) < math.huge, "min must be finite")
    assert(type(max) == "number" and math.abs(max) < math.huge and max >= min, "max must be finite and >= min")
    assert(type(step) == "number" and step > 0 and step < math.huge, "step must be positive and finite")
    self.min, self.max, self.step = min, max, step
    return self
end

---[[
---     Validate and copy before crossing the resource boundary
---]]
---@return REC_Library.Client.Class.UI.MenuItemConfigBuilder
function MenuItemConfigBuilder:build()
    local result = MenuItemConfigBuilder:new(self.id, self.label, self.type)
    result:setDescription(self.description):setIcon(self.icon):setValue(self.value)
        :setMenu(self.menu):setDisabled(self.disabled):setCloseOnSelect(self.closeOnSelect)
        :setArgs(self.args):setOnSelect(self.onSelect):setOnChange(self.onChange)

    if result.type == "checkbox" or result.type == "confirm" then
        if result.value == nil then result.value = false end
        assert(type(result.value) == "boolean", "checkbox/confirm value must be a boolean")
    elseif result.type == "range" then
        result:setRange(self.min or 0, self.max or 100, self.step)
        if result.value == nil then result.value = result.min end
        assert(type(result.value) == "number", "range value must be a number")
        result.value = math.min(result.max, math.max(result.min, result.min + math.floor((result.value - result.min) / result.step + 0.5) * result.step))
    elseif result.type == "slider" then
        assert(type(self.values) == "table" and #self.values > 0, "slider needs at least one choice")
        result.values = {}
        local found = false
        for i, choice in ipairs(self.values) do
            assert(type(choice) == "table" and type(choice.label) == "string", "choice.label must be a string")
            assert(type(choice.value) == "string" or type(choice.value) == "boolean" or (type(choice.value) == "number" and math.abs(choice.value) < math.huge), "invalid choice.value")
            assert(choice.description == nil or type(choice.description) == "string", "invalid choice.description")
            for j = 1, i - 1 do
                assert(self.values[j].value ~= choice.value, "choice values must be unique")
            end
            result.values[i] = { label = choice.label, value = choice.value, description = choice.description, }
            if result.value == choice.value then found = true end
        end
        if result.value == nil then
            result.value = result.values[1].value
        else
            assert(found == true, "slider value must match a choice")
        end
    elseif result.type == "submenu" then
        assert(type(result.menu) == "string" and result.menu ~= "", "submenu needs a menu id")
    end

    local config = {}
    for key, value in pairs(result) do config[key] = value end
    return config
end

return MenuItemConfigBuilder
