
---[[
---     One config value a panel is allowed to change at runtime
---     The declaration is also the UI schema the panel renders its settings page from
---]]
---@class REC_Library.Server.Class.Web.WebSettingConfigBuilder
---@field path string dot separated path into the resource config ("alerts.anomaly.sigma")
---@field default any the shipped value, this file is where it lives (config/sv_config.lua no longer carries it)
---@field descriptionKey string locale key for the one line explanation the panel renders
---@field valueType REC_Library.Server.Class.Web.WebSettingConfigBuilder.ValueType
---@field area string permission area, the write needs "<area>:write"
---@field labelKey string locale key the panel renders, "" falls back to the path
---@field min? number
---@field max? number
---@field maxLength? integer for string and string[]
---@field choices? string[] when set, the value must be one of these
---@field needsRestart boolean the panel says so, the value is still stored
---@field critical boolean the panel asks for a confirmation before it writes
---@field group string page section the panel groups this under
local WebSettingConfigBuilder = {}
WebSettingConfigBuilder.__index = WebSettingConfigBuilder

---@enum REC_Library.Server.Class.Web.WebSettingConfigBuilder.ValueType
WebSettingConfigBuilder.valueTypes = {
    boolean = "boolean",
    integer = "integer",
    number = "number",
    string = "string",
    stringArray = "stringArray",
}

---instantiation
---@param path string
---@return self
function WebSettingConfigBuilder:new(path)
    local instance = setmetatable({}, self)

    assert(type(path) == "string" and path ~= "", "path must be a non empty string")

    instance.path = path
    instance.valueType = WebSettingConfigBuilder.valueTypes.number
    instance.area = "settings"
    instance.labelKey = ""
    instance.descriptionKey = ""
    instance.needsRestart = false
    instance.critical = false
    instance.group = "general"

    return instance
end

---@param valueType REC_Library.Server.Class.Web.WebSettingConfigBuilder.ValueType|nil
---@return self chain method
function WebSettingConfigBuilder:setType(valueType)
    if valueType == nil then return self end
    assert(WebSettingConfigBuilder.valueTypes[valueType] ~= nil, "valueType must be a valueTypes entry")
    self.valueType = valueType return self
end

---[[
---     Permission area the write is checked against, must be in config.web.areas
---]]
---@param area string|nil
---@return self chain method
function WebSettingConfigBuilder:setArea(area)
    if area == nil then return self end
    assert(type(area) == "string" and area ~= "", "area must be a non empty string")
    self.area = area return self
end

---@param labelKey string|nil
---@return self chain method
function WebSettingConfigBuilder:setLabelKey(labelKey)
    if labelKey == nil then return self end
    assert(type(labelKey) == "string", "labelKey must be a string")
    self.labelKey = labelKey return self
end

---[[
---     Locale key for the one or two lines that say what changing this does
---]]
---@param descriptionKey string|nil
---@return self chain method
function WebSettingConfigBuilder:setDescriptionKey(descriptionKey)
    if descriptionKey == nil then return self end
    assert(type(descriptionKey) == "string", "descriptionKey must be a string")
    self.descriptionKey = descriptionKey return self
end

---[[
---     The shipped value, this declaration is the only place it lives
---]]
---@param default any
---@return self chain method
function WebSettingConfigBuilder:setDefault(default)
    if default == nil then return self end
    self.default = default return self
end

---[[
---     Accepted range for integer and number, inclusive on both ends
---]]
---@param min number|nil
---@param max number|nil
---@return self chain method
function WebSettingConfigBuilder:setRange(min, max)
    if min == nil and max == nil then return self end
    assert(min == nil or type(min) == "number", "min must be a number")
    assert(max == nil or type(max) == "number", "max must be a number")
    assert(min == nil or max == nil or min <= max, "min must not be greater than max")
    self.min, self.max = min, max return self
end

---[[
---     Longest accepted string, and the most entries a stringArray may hold
---]]
---@param maxLength integer|nil
---@return self chain method
function WebSettingConfigBuilder:setMaxLength(maxLength)
    if maxLength == nil then return self end
    assert(type(maxLength) == "number" and maxLength > 0, "maxLength must be a positive number")
    self.maxLength = maxLength return self
end

---[[
---     Restrict a string to a fixed set, which the panel renders as a select
---]]
---@param choices string[]|nil
---@return self chain method
function WebSettingConfigBuilder:setChoices(choices)
    if choices == nil then return self end
    assert(type(choices) == "table", "choices must be a string[]")
    self.choices = choices return self
end

---[[
---     Whether the running server picks the value up, false only shows a restart hint
---]]
---@param needsRestart boolean|nil
---@return self chain method
function WebSettingConfigBuilder:setNeedsRestart(needsRestart)
    if needsRestart == nil then return self end
    assert(type(needsRestart) == "boolean", "needsRestart must be a boolean")
    self.needsRestart = needsRestart return self
end

---[[
---     Whether the panel asks before it writes
---]]
---@param critical boolean|nil
---@return self chain method
function WebSettingConfigBuilder:setCritical(critical)
    if critical == nil then return self end
    assert(type(critical) == "boolean", "critical must be a boolean")
    self.critical = critical return self
end

---@param group string|nil
---@return self chain method
function WebSettingConfigBuilder:setGroup(group)
    if group == nil then return self end
    assert(type(group) == "string" and group ~= "", "group must be a non empty string")
    self.group = group return self
end

---Build and return with table without table method
---@return REC_Library.Server.Class.Web.Setting
function WebSettingConfigBuilder:build()

    ---@type REC_Library.Server.Class.Web.Setting
    local finalOptions = {}

    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end

    return finalOptions
end

return WebSettingConfigBuilder

---@class REC_Library.Server.Class.Web.Setting
---@field path string
---@field default any
---@field descriptionKey string
---@field valueType REC_Library.Server.Class.Web.WebSettingConfigBuilder.ValueType
---@field area string
---@field labelKey string
---@field min? number
---@field max? number
---@field maxLength? integer
---@field choices? string[]
---@field needsRestart boolean
---@field critical boolean
---@field group string
