
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

local Player = require "@REC_Library.server.class.player.sv_player"
local PlayerConfigBuilder = require "@REC_Library.server.class.player.sv_playerConfigBuilder"

---@class REC_Library.Server.Class.Manager.PlayerManager
---@field info REC_Library.Server.Class.Manager.PlayerManagerConfigBuilder
local PlayerManager = {}
PlayerManager.__index = PlayerManager

---instantiation
---@param config REC_Library.Server.Class.Manager.PlayerManagerConfigBuilder
---@return self
function PlayerManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Initialization
---@return boolean
function PlayerManager:init()
    local info = self.info

    -- Check if it has already been initialized
    if info.hasInitialized == true then
        utils:debugPrint("PlayerManager is already initialized.")
        return false
    end

    if info.onPlayerConnecting ~= nil then
        AddEventHandler("playerConnecting", function (...)
            local src = source
            info.onPlayerConnecting(self, src, ...)
        end)
    end

    if info.onPlayerJoined ~= nil then
        AddEventHandler("playerJoining", function (...)
            local src = source
            info.onPlayerJoined(self, tostring(src), ...)
        end)
    end

    if info.onPlayerDropped ~= nil then
        AddEventHandler("playerDropped", function(...)
            local src = source
            info.onPlayerDropped(self, tostring(src), ...)
        end)
    end

    -- set initialized flag
    info.hasInitialized = true

    return true
end

---Start monitoring
---@return boolean
function PlayerManager:start()
    local info = self.info

    -- Check if it has already been initialized
    if info.hasInitialized == false then
        utils:debugPrint("PlayerManager has not been initialized.")
        return false
    end

    -- check if starting
    if info.isMonitorActive == true then
        utils:debugPrint("PlayerManager is already active.")
        return false
    end

    Citizen.CreateThread(function (threadId)

        -- Thread ID storage
        info.threadId = threadId

        -- flag
        info.isMonitorActive = true

        while info.isMonitorActive == true do

            -- Get player
            for _, player in pairs(info.players) do
                local playerKey = player.info.src

                if player == nil then
                    utils:debugPrint("Failed to get playerData for: " .. playerKey)
                    goto continue
                end

                local currentRoutingBucket = GetPlayerRoutingBucket(playerKey)
                if player.info.routingBucket ~= currentRoutingBucket then
                    if info.onRoutingBucketChanged ~= nil then
                        info.onRoutingBucketChanged(self, player, player.info.routingBucket, currentRoutingBucket)
                    end
                end

                -- Update information
                player:updateData()

                -- Update execution callback
                if info.onUpdated ~= nil then
                    info.onUpdated(self, player)
                end

                ::continue::
            end

            Wait(info.waitTime)
        end
    end)

    -- start callback
    if info.onStart ~= nil then
        info.onStart(self)
    end

    return true
end

---Player registration
---@param src string Player's server ID
---@return boolean
function PlayerManager:register(src)
    local info = self.info

    -- type checking
    if type(src) ~= "string" then
        utils:debugPrint("^3[PlayerManager:register] src must be a string.^0")
        return false
    end

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("^3PlayerManager has not been initialized.^0")
        return false
    end

    -- Check if registered
    if self:doesPlayerExist(src) == true then
        utils:debugPrint("Player is already registered: " .. src)
        return false
    end

    local player = Player:new(
        PlayerConfigBuilder:new(
            src
        )
    )

    -- initialization
    player:init()
    player:updateData()

    -- Registration callback
    if info.onRegistered ~= nil then
        info.onRegistered(self, player)
    end

    -- Registration
    info.players[src] = player

    return true
end

---Unregister
---@param src string Player server ID
---@return boolean
function PlayerManager:unregister(src)
    local info = self.info

    -- type checking
    if type(src) ~= "string" then
        utils:debugPrint("^3[PlayerManager:register] src must be a string.^0")
        return false
    end

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("PlayerManager has not been initialized.")
        return false
    end

    -- Check if it exists
    if self:doesPlayerExist(src) == false then
        utils:debugPrint("Player does not exist: " .. src)
        return false
    end

    -- Registration callback
    if info.onUnregistered ~= nil then
        info.onUnregistered(self, info.players[src])
    end

    -- Unregister
    info.players[src] = nil

    return true
end

---Get Player instance from player ID
---@param src string
---@return REC_Library.Server.Class.Player.Player|nil
function PlayerManager:getPlayerFromSrc(src)
    local info = self.info

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("PlayerManager has not been initialized.")
        return nil
    end

    -- Check if it exists
    if self:doesPlayerExist(src) == false then
        utils:debugPrint("Player does not exist: " .. src)
        return nil
    end

    return info.players[src]
end

---Get the player near the specified coordinates
---@param coords vector3
---@param radius number
---@param sort? boolean
---@return table<string, REC_Library.Server.Class.Manager.PlayerManager.getPlayersInRadius>|nil
function PlayerManager:getPlayersInRadius(coords, radius, sort)
    local info = self.info
    radius = radius * 1.0
    sort = sort or false

    -- Calculated from all players and falls within radius
    ---@type table<integer, REC_Library.Server.Class.Player.Player>
    local playersInRadius = {}
    for _, player in pairs(info.players) do
        local playerInfo = player.info

        -- if within range
        if #(coords - playerInfo.currentCoords) <= radius then
            playersInRadius[#playersInRadius+1] = player
        end
    end

    -- if sorting is enabled
    if sort == true then
        table.sort(playersInRadius, function(a, b)
            return #(coords - a.info.currentCoords) < #(coords - b.info.currentCoords)
        end)
    end

    -- Plastic surgery
    ---@type table<string, REC_Library.Server.Class.Manager.PlayerManager.getPlayersInRadius>
    local finallylayersInRadius = {}
    for index, player in ipairs(playersInRadius) do
        local playerInfo = player.info

        finallylayersInRadius[playerInfo.src] = {
            src = playerInfo.src,
            handle = playerInfo.handle,
            coords = playerInfo.currentCoords,
        }
    end

    return next(finallylayersInRadius) ~= nil and finallylayersInRadius or nil
end

---Check whether it is registered or not
---@param src string
---@return boolean
function PlayerManager:doesPlayerExist(src)
    local info = self.info

    -- Check if initialized
    if info.hasInitialized == false then
        utils:debugPrint("PlayerManager has not been initialized.")
        return false
    end

   return info.players[src] ~= nil
end

---Get player data
---@private
---@param src string Player ID
---@return REC_Library.Server.Class.Player.Player|nil
function PlayerManager:getPlayerDataById(src)
    local info = self.info

    -- type checking
    if type(src) ~= "string" then
        utils:debugPrint("^3[PlayerManager:getPlayerDataById] src must be a string.^0")
        return nil
    end

    -- Check if it has already been initialized
    if info.hasInitialized == false then
        utils:debugPrint("PlayerManager has not been initialized.")
        return nil
    end

    --Existence check
    if self:doesPlayerExist(src) == false then
        utils:debugPrint("Player does not exist: " .. src)
        return nil
    end

    return info.players[src]
end

---Stop monitoring
---@return boolean
function PlayerManager:stop()
    local info = self.info

    -- Check if it has already been initialized
    if info.hasInitialized == false then
        utils:debugPrint("PlayerManager has not been initialized.")
        return false
    end

    -- check if starting
    if info.isMonitorActive == false then
        utils:debugPrint("PlayerManager is not active.")
        return false
    end

    -- Loop stop instruction
    info.isMonitorActive = false

    return true
end

---@class REC_Library.Server.Class.Manager.PlayerManager.getPlayersInRadius
---@field src string
---@field handle integer
---@field coords vector3

return PlayerManager
