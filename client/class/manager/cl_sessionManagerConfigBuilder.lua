
---@class REC_Library.Client.Class.Manager.SessionManagerConfigBuilder
---@field onInit? fun(self: REC_Library.Client.Class.Manager.SessionManager): boolean
---@field entityManager? REC_Library.Client.Class.Manager.EntityManager
---@field zoneManager? REC_Library.Client.Class.Manager.ZoneManager
---@field blipManager? REC_Library.Client.Class.Manager.BlipManager
---@field isBusy boolean
local SessionConfigBuilder = {}
SessionConfigBuilder.__index = SessionConfigBuilder

---instantiation
---@return self
function SessionConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.isBusy = false
    return instance
end

---Setter chain method
---@param onInit fun(self: REC_Library.Client.Class.Manager.SessionManager): boolean callback function
---@return self chain method
function SessionConfigBuilder:setOnInit(onInit)
    if onInit == nil then return self end
    assert(type(onInit) == "function", "onInit must be a function")
    self.onInit = onInit
    return self
end

---EntityManager instance
---@param entityManager REC_Library.Client.Class.Manager.EntityManager
---@return self
function SessionConfigBuilder:setEntityManager(entityManager)
    if entityManager == nil then return self end
    self.entityManager = entityManager
    return self
end

---ZoneManager instance
---@param zoneManager REC_Library.Client.Class.Manager.ZoneManager
function SessionConfigBuilder:setZoneManager(zoneManager)
    if zoneManager == nil then return self end
    self.zoneManager = zoneManager
    return self
end

---Instance of BlipManager
---@param blipManager REC_Library.Client.Class.Manager.BlipManager
function SessionConfigBuilder:setBlipManager(blipManager)
    if blipManager == nil then return self end
    self.blipManager = blipManager
    return self
end

---Configure custom properties
---@param properties? table<string, any>
---@return self SessionConfigBuilder
function SessionConfigBuilder:setCustomProperties(properties)
    if properties == nil then return self end
    assert(type(properties) == "table", "properties must be a table")

    for key, value in pairs(properties) do
        self[key] = value
    end

    return self
end

---Convert in build-like table format
---@return table
function SessionConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return SessionConfigBuilder
