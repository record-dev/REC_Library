
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---@class REC_Library.Server.Class.Player.Player
---@field info REC_Library.Server.Class.Player.PlayerConfigBuilder
local Player = {}
Player.__index = Player

---instantiation
---@param config REC_Library.Server.Class.Player.PlayerConfigBuilder
---@return self
function Player:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Initialization
---@return boolean
function Player:init()
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Player is already resolving.")
        return false
    end

    -- enable in progress flag
    info.isResolving = true

    ---[[
    --- Various settings
    ---]]

    -- Record registration time
    info.joinedAt = GetGameTimer()

    -- Obtaining identification number
    local identifiers = GetPlayerIdentifiers(info.src)

    -- check if empty
    if identifiers == nil or type(identifiers) ~= "table" then
        utils:debugPrint("Failed to get identifiers for player.")
        return false
    end

    -- Substitution of information
    for k, v in pairs(identifiers) do
        info.identifiers[k] = v
    end

    -- get routing bucket
    info.routingBucket = GetPlayerRoutingBucket(info.src)

    -- set initialized flag
    info.hasInitialized = true

    -- Lower progress flag
    info.isResolving = false

    return true
end

---Update data
---@return boolean
function Player:updateData()
    local info = self.info

    -- Is it initialized?
    if info.hasInitialized == false then
        utils:debugPrint("Player has not been initialized.")
        return false
    end

    -- assign old position
    info.lastCoords = info.currentCoords

    -- Reacquire handle
    info.handle = GetPlayerPed(info.src)

    -- Get current location
    info.currentCoords = GetEntityCoords(info.handle)

    -- Get routing bucket
    info.routingBucket = GetPlayerRoutingBucket(info.src)

    return true
end

---Send message
---@param sendMessageEvent string Event name
---@param msg string message
---@return boolean
function Player:sendMessage(sendMessageEvent, msg)
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Player is already resolving.")
        return false
    end

    -- enable in progress flag
    info.isResolving = true

    TriggerClientEvent(sendMessageEvent, tonumber(info.src), msg)

    -- Lower progress flag
    info.isResolving = false


    return true
end

---Kick
---@param reson string
---@return boolean
function Player:kick(reson)
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Player is already resolving.")
        return false
    end

    -- enable in progress flag
    info.isResolving = true

    DropPlayer(info.src, reson)

    -- Lower progress flag
    info.isResolving = false

    return true
end

return Player
