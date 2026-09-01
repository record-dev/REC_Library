
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
---     Runtime config overrides for the REC_* admin panels
---     Only paths declared through WebSettingConfigBuilder can be written
---]]
---@class REC_Library.Server.Class.Web.WebConfigStore
---@field resourceName string
---@field config table the resource config table, mutated in place
---@field settings table<string, REC_Library.Server.Class.Web.Setting> keyed by path
---@field defaults table<string, any> as declared, which is what a reset puts back
---@field order table<string, integer> declaration order, which is the order the panel renders
---@field overrides table<string, any> what the DB currently says
---@field onChange? fun(self: REC_Library.Server.Class.Web.WebConfigStore, path: string, value: any)
---@field persistent boolean false keeps the overrides in memory only
---@field debug boolean
local WebConfigStore = {}
WebConfigStore.__index = WebConfigStore

---@type string
local TABLE_NAME = "rec_config_overrides"

---@type integer
local EXPORT_VERSION = 1

---[[
---     Walk a dot separated path down a table
---]]
---@param root table
---@param path string
---@param create? boolean build the tables the path walks through when they are missing
---@return table|nil owner, string|nil key
local function resolvePath(root, path, create)

    ---@type table
    local node = root

    ---@type string|nil
    local lastKey = nil

    for segment in path:gmatch("[^%.]+") do

        if lastKey ~= nil then
            if node[lastKey] == nil and create == true then
                node[lastKey] = {}
            end
            node = node[lastKey]
            if type(node) ~= "table" then
                return nil, nil
            end
        end

        lastKey = segment
    end

    if lastKey == nil then
        return nil, nil
    end

    return node, lastKey
end

---@param root table
---@param path string
---@return any
local function readPath(root, path)

    local owner, key = resolvePath(root, path)
    if owner == nil or key == nil then
        return nil
    end

    return owner[key]
end

---[[
---     Deep copy, so a captured default is never the table the config still holds
---]]
---@param value any
---@return any
local function copyValue(value)

    if type(value) ~= "table" then
        return value
    end

    ---@type table
    local copy = {}

    for k, v in pairs(value) do
        copy[k] = copyValue(v)
    end

    return copy
end

---[[
---     Write the declared defaults into a config table
---     config/sv_config.lua calls this on itself, before anything reads the values
---]]
---@param config table
---@param settings REC_Library.Server.Class.Web.Setting[]|nil
---@return integer count of seeded settings
function WebConfigStore.seed(config, settings)

    assert(type(config) == "table", "config must be a table")

    if type(settings) ~= "table" then
        return 0
    end

    ---@type integer
    local count = 0

    for _, setting in ipairs(settings) do

        if type(setting) ~= "table" or type(setting.path) ~= "string" or setting.default == nil then
            goto continue
        end

        local owner, key = resolvePath(config, setting.path, true)
        if owner == nil or key == nil then
            goto continue
        end

        owner[key] = copyValue(setting.default)
        count = count + 1

        ::continue::
    end

    return count
end

---instantiation
---@param config REC_Library.Server.Class.Web.WebConfigStore.Config
---@return REC_Library.Server.Class.Web.WebConfigStore
function WebConfigStore:new(config)
    local instance = setmetatable({}, self)

    assert(type(config) == "table", "config must be a table")
    assert(type(config.config) == "table", "config.config must be the resource config table")

    instance.resourceName = config.resourceName or GetCurrentResourceName()
    instance.config = config.config
    instance.onChange = config.onChange
    instance.persistent = config.persistent ~= false
    instance.debug = config.debug == true
    instance.settings = {}
    instance.defaults = {}
    instance.overrides = {}
    instance.order = {}

    instance:setSettings(config.settings)

    return instance
end

---[[
---     Register the writable paths and seed the config table with their defaults
---]]
---@param settings REC_Library.Server.Class.Web.Setting[]|nil
---@return integer count of usable settings
function WebConfigStore:setSettings(settings)

    self.settings = {}
    self.defaults = {}
    self.order = {}

    if type(settings) ~= "table" then
        return 0
    end

    ---@type integer
    local count = 0

    for _, setting in ipairs(settings) do

        if type(setting) ~= "table" or type(setting.path) ~= "string" then
            print(("^3[%s] setting entry is not a table and was ignored^0"):format(self.resourceName))
            goto continue
        end

        if setting.default == nil then
            print(("^3[%s] setting has no default and was ignored: %s^0"):format(self.resourceName, setting.path))
            goto continue
        end

        local isValid, reason = self:validate(setting, setting.default)
        if isValid == false then
            print(("^3[%s] the declared default for %s is not usable: %s^0"):format(self.resourceName, setting.path, tostring(reason)))
            goto continue
        end

        local owner, key = resolvePath(self.config, setting.path, true)
        if owner == nil or key == nil then
            print(("^3[%s] setting path collides with a non table value and was ignored: %s^0"):format(self.resourceName, setting.path))
            goto continue
        end

        owner[key] = copyValue(setting.default)

        count = count + 1

        self.settings[setting.path] = setting
        self.defaults[setting.path] = copyValue(setting.default)
        self.order[setting.path] = count

        ::continue::
    end

    return count
end

---[[
---     Whether a value fits what the setting declared
---]]
---@param setting REC_Library.Server.Class.Web.Setting
---@param value any
---@return boolean, string|nil reason
function WebConfigStore:validate(setting, value)

    if setting.valueType == "boolean" then
        if type(value) ~= "boolean" then
            return false, "expected a boolean"
        end
        return true
    end

    if setting.valueType == "integer" or setting.valueType == "number" then

        if type(value) ~= "number" then
            return false, "expected a number"
        end

        if setting.valueType == "integer" and math.floor(value) ~= value then
            return false, "expected a whole number"
        end

        if setting.min ~= nil and value < setting.min then
            return false, ("must not be below %s"):format(setting.min)
        end

        if setting.max ~= nil and value > setting.max then
            return false, ("must not be above %s"):format(setting.max)
        end

        return true
    end

    if setting.valueType == "string" then

        if type(value) ~= "string" then
            return false, "expected a string"
        end

        if setting.maxLength ~= nil and #value > setting.maxLength then
            return false, ("must not be longer than %d characters"):format(setting.maxLength)
        end

        if setting.choices ~= nil and self:isChoice(setting, value) == false then
            return false, "is not one of the accepted values"
        end

        return true
    end

    if setting.valueType == "stringArray" then

        if type(value) ~= "table" then
            return false, "expected an array of strings"
        end

        if setting.maxLength ~= nil and #value > setting.maxLength then
            return false, ("must not hold more than %d entries"):format(setting.maxLength)
        end

        for _, entry in ipairs(value) do
            if type(entry) ~= "string" then
                return false, "every entry must be a string"
            end
            if setting.choices ~= nil and self:isChoice(setting, entry) == false then
                return false, "holds a value that is not accepted"
            end
        end

        return true
    end

    return false, "unknown value type"
end

---@param setting REC_Library.Server.Class.Web.Setting
---@param value string
---@return boolean
function WebConfigStore:isChoice(setting, value)

    for _, choice in ipairs(setting.choices or {}) do
        if choice == value then
            return true
        end
    end

    return false
end

---[[
---     Write a value into the config table the resource already holds
---]]
---@param path string
---@param value any
---@return boolean
function WebConfigStore:apply(path, value)

    local owner, key = resolvePath(self.config, path)
    if owner == nil or key == nil then
        return false
    end

    owner[key] = copyValue(value)

    return true
end

---[[
---     Load the stored overrides and apply them
---     Call this before anything caches a config value into a local
---]]
---@return integer count of applied overrides
function WebConfigStore:load()

    self.overrides = {}

    if self.persistent == false then
        return 0
    end

    if GetResourceState("oxmysql") ~= "started" then
        print(("^3[%s] oxmysql is not started, config overrides stay in memory only^0"):format(self.resourceName))
        self.persistent = false
        return 0
    end

    ---@type table[]|nil
    local rows = MySQL.query.await(("SELECT `path`, `value` FROM `%s` WHERE `resource` = ?"):format(TABLE_NAME), {
        self.resourceName,
    })

    if type(rows) ~= "table" then
        return 0
    end

    ---@type integer
    local count = 0

    for _, row in ipairs(rows) do

        local setting = self.settings[row.path]
        if setting == nil then
            self:debugPrint(("^3stored override is not a declared setting... path: %s^0"):format(tostring(row.path)))
            goto continue
        end

        ---@type any
        local value = json.decode(row.value)

        local isValid, reason = self:validate(setting, value)
        if isValid == false then
            print(("^3[%s] stored override for %s was refused: %s^0"):format(self.resourceName, row.path, tostring(reason)))
            goto continue
        end

        if self:apply(row.path, value) == false then
            goto continue
        end

        self.overrides[row.path] = value
        count = count + 1

        ::continue::
    end

    self:debugPrint(("^2successful to load %d config override(s)^0"):format(count))

    return count
end

---[[
---     Change one setting, persist it and apply it to the running config
---]]
---@param path string
---@param value any
---@param actor? string label written to updatedBy
---@return boolean, string|nil reason
function WebConfigStore:set(path, value, actor)

    local setting = self.settings[path]
    if setting == nil then
        return false, "is not a writable setting"
    end

    local isValid, reason = self:validate(setting, value)
    if isValid == false then
        self:debugPrint(("^3refused config write... path: %s reason: %s^0"):format(path, tostring(reason)))
        return false, reason
    end

    -- typing the shipped value back in is not an override, so the row is dropped
    if self:isSameAsDefault(path, value) == true then
        return self:reset(path, actor)
    end

    if self:apply(path, value) == false then
        return false, "could not be applied to the config"
    end

    self.overrides[path] = copyValue(value)

    if self.persistent == true then
        MySQL.update.await(("INSERT INTO `%s` (`resource`, `path`, `value`, `updatedBy`) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE `value` = VALUES(`value`), `updatedBy` = VALUES(`updatedBy`)"):format(TABLE_NAME), {
            self.resourceName,
            path,
            json.encode(value),
            actor or "unknown",
        })
    end

    self:debugPrint(("^2successful to set config override... path: %s^0"):format(path))

    if self.onChange ~= nil then
        self.onChange(self, path, value)
    end

    return true
end

---[[
---     Drop the override and put the shipped default back
---]]
---@param path string
---@param actor? string
---@return boolean, string|nil reason
function WebConfigStore:reset(path, actor)

    local setting = self.settings[path]
    if setting == nil then
        return false, "is not a writable setting"
    end

    ---@type any
    local default = self.defaults[path]

    ---@type boolean
    local wasStored = self.overrides[path] ~= nil

    if self:apply(path, default) == false then
        return false, "could not be applied to the config"
    end

    self.overrides[path] = nil

    -- nothing was stored, so there is no row to delete
    if self.persistent == true and wasStored == true then
        MySQL.update.await(("DELETE FROM `%s` WHERE `resource` = ? AND `path` = ?"):format(TABLE_NAME), {
            self.resourceName,
            path,
        })
    end

    self:debugPrint(("^2successful to reset config override... path: %s actor: %s^0"):format(path, tostring(actor)))

    if self.onChange ~= nil then
        self.onChange(self, path, default)
    end

    return true
end

---[[
---     Put every setting back to what the declaration ships
---]]
---@param actor? string
---@return integer count of settings that were overridden
function WebConfigStore:resetAll(actor)

    ---@type integer
    local count = 0

    for path in pairs(self.overrides) do
        self:apply(path, self.defaults[path])
        count = count + 1
    end

    self.overrides = {}

    if self.persistent == true and count > 0 then
        MySQL.update.await(("DELETE FROM `%s` WHERE `resource` = ?"):format(TABLE_NAME), {
            self.resourceName,
        })
    end

    self:debugPrint(("^2successful to reset every config override... count: %d actor: %s^0"):format(count, tostring(actor)))

    if self.onChange ~= nil then
        self.onChange(self, "*", nil)
    end

    return count
end

---[[
---     Every declared setting and its effective value, as one portable table
---]]
---@return REC_Library.Server.Class.Web.WebConfigStore.Export
function WebConfigStore:export()

    ---@type table<string, any>
    local values = {}

    for path in pairs(self.settings) do
        values[path] = copyValue(readPath(self.config, path))
    end

    ---@type REC_Library.Server.Class.Web.WebConfigStore.Export
    return {
        resource = self.resourceName,
        version = EXPORT_VERSION,
        values = values,
    }
end

---[[
---     Apply an exported table, checking each entry on its own
---     A path this resource does not declare is skipped rather than stored
---]]
---@param payload any
---@param actor? string
---@return REC_Library.Server.Class.Web.WebConfigStore.ImportResult
function WebConfigStore:import(payload, actor)

    ---@type REC_Library.Server.Class.Web.WebConfigStore.ImportResult
    local result = { applied = 0, skipped = 0, failed = {}, }

    if type(payload) ~= "table" or type(payload.values) ~= "table" then
        result.failed[#result.failed+1] = { path = "", reason = "is not an exported settings table", }
        return result
    end

    if payload.resource ~= nil and payload.resource ~= self.resourceName then
        result.failed[#result.failed+1] = { path = "", reason = ("was exported from %s"):format(tostring(payload.resource)), }
        return result
    end

    for path, value in pairs(payload.values) do

        if self.settings[path] == nil then
            result.skipped = result.skipped + 1
            goto continue
        end

        local isOk, reason = self:set(path, value, actor)
        if isOk == false then
            result.failed[#result.failed+1] = { path = path, reason = tostring(reason), }
            goto continue
        end

        result.applied = result.applied + 1

        ::continue::
    end

    self:debugPrint(("^2successful to import settings... applied: %d skipped: %d failed: %d^0"):format(result.applied, result.skipped, #result.failed))

    return result
end

---[[
---     Whether a value matches what the declaration ships
---]]
---@param path string
---@param value any
---@return boolean
function WebConfigStore:isSameAsDefault(path, value)

    ---@type any
    local default = self.defaults[path]

    if type(default) ~= "table" or type(value) ~= "table" then
        return default == value
    end

    if #default ~= #value then
        return false
    end

    for index, entry in ipairs(default) do
        if value[index] ~= entry then
            return false
        end
    end

    return true
end

---[[
---     Every declared setting with its default and current value, for the panel to render
---]]
---@return REC_Library.Server.Class.Web.WebConfigStore.SchemaEntry[]
function WebConfigStore:getSchema()

    ---@type REC_Library.Server.Class.Web.WebConfigStore.SchemaEntry[]
    local schema = {}

    for path, setting in pairs(self.settings) do

        schema[#schema+1] = {
            path = path,
            valueType = setting.valueType,
            area = setting.area,
            labelKey = setting.labelKey ~= "" and setting.labelKey or path,
            descriptionKey = setting.descriptionKey or "",
            group = setting.group,
            min = setting.min,
            max = setting.max,
            maxLength = setting.maxLength,
            choices = setting.choices,
            needsRestart = setting.needsRestart,
            critical = setting.critical == true,
            order = self.order[path] or 0,
            default = copyValue(self.defaults[path]),
            value = copyValue(readPath(self.config, path)),
            isOverridden = self.overrides[path] ~= nil,
        }
    end

    -- declaration order, so a group reads "on / off" first and its parameters after
    table.sort(schema, function (a, b)
        return a.order < b.order
    end)

    return schema
end

---@param ... any
function WebConfigStore:debugPrint(...)
    if self.debug == true then
        utils:debugPrint(...)
    end
end

return WebConfigStore

---@class REC_Library.Server.Class.Web.WebConfigStore.Config
---@field config table the resource config table, mutated in place
---@field settings REC_Library.Server.Class.Web.Setting[]
---@field resourceName? string
---@field persistent? boolean false keeps the overrides in memory only
---@field onChange? fun(self: REC_Library.Server.Class.Web.WebConfigStore, path: string, value: any)
---@field debug? boolean

---@class REC_Library.Server.Class.Web.WebConfigStore.Export
---@field resource string
---@field version integer
---@field values table<string, any>

---@class REC_Library.Server.Class.Web.WebConfigStore.ImportResult
---@field applied integer
---@field skipped integer paths this resource does not declare
---@field failed { path: string, reason: string, }[]

---@class REC_Library.Server.Class.Web.WebConfigStore.SchemaEntry
---@field path string
---@field order integer
---@field descriptionKey string declaration order, which is the order the panel renders
---@field valueType REC_Library.Server.Class.Web.WebSettingConfigBuilder.ValueType
---@field area string
---@field labelKey string
---@field group string
---@field min? number
---@field max? number
---@field maxLength? integer
---@field choices? string[]
---@field needsRestart boolean
---@field critical boolean
---@field default any
---@field value any
---@field isOverridden boolean
