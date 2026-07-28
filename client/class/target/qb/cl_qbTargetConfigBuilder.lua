
---@type REC_Library.Shared.Validator
local validator = require "@REC_Library.shared.sh_validator"

---@class REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder
---@field name string
---@field entity number
---@field debugPoly boolean
---@field distance number
---@field type REC_Library.Shared.Enums.TargetType.QB
---@field event string NetEvent
---@field icon string https://fontawesome.com/search?ic=free
---@field label string
---@field num? number
---@field targetIcon? string
---@field item string?
---@field action? fun(...)
---@field canInteract? fun(...)
---@field job? string|table<string, number>[]
---@field gang? string|table<string, number>[]
---@field citizenid? string|table<string, boolean>[]
local QBTargetConfigBuilder = {}
QBTargetConfigBuilder.__index = QBTargetConfigBuilder

---instantiation
---@param name string name
---@param type REC_Library.Shared.Enums.TargetType.QB client|server
---@param label string Interaction label
---@return self
function QBTargetConfigBuilder:new(name, type, label)
    assert(type(name) == "string")
    assert(type(type) == "string" and (type == "client" or type == "server"))
    assert(type(label) == "string")

    local instance = setmetatable({}, self)

    -- Required
    instance.name = name
    instance.type = type
    instance.label = label

    --optional
    instance.icon = "fa-regular fa-circle-question"
    instance.num = nil
    instance.targetIcon = nil
    instance.item = nil
    instance.action = nil
    instance.canInteract = nil
    instance.job = nil
    instance.gang = nil
    instance.citizenid = nil
    return instance
end

---Method chain
---@param clientEvent string
---@return self
function QBTargetConfigBuilder:setEvent(clientEvent)
    if clientEvent == nil then return self end
    assert(type(clientEvent) == "string")
    self.event = clientEvent
    return self
end

---Method chain
---@param icon string
---@return self
function QBTargetConfigBuilder:setIcon(icon)
    if icon == nil then return self end
    assert(type(icon) == "string")
    self.icon = icon return self
end

---Method chain
---@param num number
---@return self
function QBTargetConfigBuilder:setNumber(num)
    if num == nil then return self end
    assert(type(num) == "number")
    self.num = num return self
end

---Method chain
---@param targetIcon string https://fontawesome.com/search?ic=free
---@return self
function QBTargetConfigBuilder:setTargetIcon(targetIcon)
    if targetIcon == nil then return self end
    assert(type(targetIcon) == "string")
    self.targetIcon = targetIcon return self
end

---Method chain
---@param item string
---@return self
function QBTargetConfigBuilder:setItem(item)
    if item == nil then return self end
    assert(type(item) == "string")
    self.item = item return self
end

---Method chain
---@param action fun(...)
---@return self
function QBTargetConfigBuilder:setAction(action)
    if action == nil then return self end
    assert(type(action) == "function")
    self.action = action return self
end

---Method chain
---@param canInteract fun(...)
---@return self
function QBTargetConfigBuilder:setCanInteract(canInteract)
    if canInteract == nil then return self end
    assert(type(canInteract) == "function")
    self.canInteract = canInteract return self
end

---Set job settings method chain
---@param jobs table<string, number> Expected data structure is {['job_name'] = grade_number, ...}
---@return self
function QBTargetConfigBuilder:setJobs(jobs)
    if jobs == nil then return self end
    assert(validator.isTableOfStringNumber(jobs))
    self.job = jobs return self
end

---Set gang settings method chain
---@param gangs table<string, number> Expected data structure is {['gang_name'] = grade_number, ...}
---@return self
function QBTargetConfigBuilder:setGangs(gangs)
    if gangs == nil then return self end
    assert(validator.isTableOfStringNumber(gangs))
    self.gang = gangs return self
end

---Set citizenId configuration method chain
---@param citizenIds table<string, boolean> Expected data structure is {['gang_name'] = true|false, ...}
---@return self
function QBTargetConfigBuilder:setCitizenIds(citizenIds)
    if citizenIds == nil then return self end
    assert(validator.isTableOfStringBoolean(citizenIds))
    self.citizenid = citizenIds return self
end

---Build and return in table format
---@return table
function QBTargetConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return QBTargetConfigBuilder
