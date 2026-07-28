
---@class REC_Library.Server.Class.Player.PlayerConfig
---@field src string
---@field handle integer
---@field routingBucket integer
---@field currentCoords vector3
---@field lastCoords vector3
---@field joinedAt? number
---@field identifiers REC_Library.Server.Class.Player.PlayerConfig.Identifiers
---@field hasInitialized boolean
---@field isResolving boolean

---@class REC_Library.Server.Class.Player.PlayerConfigBuilder: REC_Library.Server.Class.Player.PlayerConfig
local PlayerConfigBuilder = {}
PlayerConfigBuilder.__index = PlayerConfigBuilder

---instantiation
---@param src string Player's server ID
---@return self
function PlayerConfigBuilder:new(src)
    local handle = GetPlayerPed(src)
    local coords = GetEntityCoords(handle)
    local instance = setmetatable({}, self)
    assert(src ~= nil and type(src) == "string", "src must be a string")
    instance.src = src
    instance.handle = handle
    instance.routingBucket = GetPlayerRoutingBucket(src)
    instance.currentCoords = coords
    instance.lastCoords = coords
    instance.identifiers = {}
    instance.hasInitialized = false
    instance.isResolving = false
    return instance
end

---@class REC_Library.Server.Class.Player.PlayerConfig.Identifiers
---@field ip? string
---@field fivem? integer
---@field license? integer
---@field license2? integer
---@field discord? integer
---@field steam? integer
---@field xbl? integer
---@field live? integer

return PlayerConfigBuilder
