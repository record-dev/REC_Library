
---@type REC_Library.Shared.Enums
local sh_enum = require "@REC_Library.shared.sh_enums"

---@class REC_Library.Shared.Class.Zone.ZoneConfig
---@field name? string
---@field zone REC_Library.Shared.Zone.Self
---@field zoneType REC_Library.Shared.Enums.ZoneType
---@field options REC_Library.Shared.Class.Zone.PolyZoneConfigBuilder|REC_Library.Shared.Class.Zone.BoxZoneConfigBuilder|REC_Library.Shared.Class.Zone.SphereZoneConfigBuilder
---@field isCreated boolean
---@field isResolving boolean

---@class REC_Library.Shared.Class.Zone.ZoneConfigBuilder: REC_Library.Shared.Class.Zone.ZoneConfig
local ZoneConfigBuilder = {}
ZoneConfigBuilder.__index = ZoneConfigBuilder

---instantiation
---@param zoneName string Distinguished name of the zone
---@param zoneType REC_Library.Shared.Enums.ZoneType Type of generated zone
---@param options REC_Library.Shared.Class.Zone.PolyZoneConfigBuilder|REC_Library.Shared.Class.Zone.BoxZoneConfigBuilder|REC_Library.Shared.Class.Zone.SphereZoneConfigBuilder Zone ConfigBuilder built into a table
---@return self
function ZoneConfigBuilder:new(zoneName, zoneType, options)
    assert(type(zoneName) == "string", "zoneName must be a string")
    assert(zoneType ~= nil and sh_enum.ZoneType[zoneType] ~= nil, "zoneType was invalid.")
    assert(options ~= nil and type(options) == "table", "options must be a meta table")
    local instance = setmetatable({}, self)
    instance.name = zoneName
    instance.zone = nil
    instance.zoneType = zoneType
    instance.options = options
    instance.isCreated = false
    instance.isResolving = false
    return instance
end

---Convert in build-like table format
---@return table
function ZoneConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return ZoneConfigBuilder
