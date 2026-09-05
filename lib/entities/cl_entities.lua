
---[[
---     entities (client)
---     Nearby lookups around a point. Distances are in game units.
---]]

---@param coords vector3
---@param maxDistance? number default 2.0
---@param includePlayer? boolean
---@return { id: integer, ped: integer, coords: vector3 }[]
function lib.getNearbyPlayers(coords, maxDistance, includePlayer)

    maxDistance = maxDistance or 2.0

    local nearby = {}
    local localPed = cache.ped

    for _, playerId in ipairs(GetActivePlayers()) do

        local ped = GetPlayerPed(playerId)
        if ped ~= localPed or includePlayer == true then

            local pedCoords = GetEntityCoords(ped)
            if #(coords - pedCoords) < maxDistance then
                nearby[#nearby+1] = { id = playerId, ped = ped, coords = pedCoords, }
            end
        end
    end

    return nearby
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@param includePlayer? boolean
---@return integer|nil playerId
---@return integer|nil ped
---@return vector3|nil coords
function lib.getClosestPlayer(coords, maxDistance, includePlayer)

    maxDistance = maxDistance or 2.0

    local closestId, closestPed, closestCoords
    local localPed = cache.ped

    for _, playerId in ipairs(GetActivePlayers()) do

        local ped = GetPlayerPed(playerId)
        if ped ~= localPed or includePlayer == true then

            local pedCoords = GetEntityCoords(ped)
            local distance = #(coords - pedCoords)
            if distance < maxDistance then
                maxDistance = distance
                closestId, closestPed, closestCoords = playerId, ped, pedCoords
            end
        end
    end

    return closestId, closestPed, closestCoords
end

---@param pool string
---@param coords vector3
---@param maxDistance number
---@param key string
---@param filter? fun(entity: integer): boolean
---@return table[]
local function getNearby(pool, coords, maxDistance, key, filter)

    local nearby = {}

    for _, entity in ipairs(GetGamePool(pool)) do
        if filter == nil or filter(entity) == true then

            local entityCoords = GetEntityCoords(entity)
            if #(coords - entityCoords) < maxDistance then
                nearby[#nearby+1] = { [key] = entity, coords = entityCoords, }
            end
        end
    end

    return nearby
end

---@param pool string
---@param coords vector3
---@param maxDistance number
---@param filter? fun(entity: integer): boolean
---@return integer|nil entity
---@return vector3|nil coords
local function getClosest(pool, coords, maxDistance, filter)

    local closest, closestCoords

    for _, entity in ipairs(GetGamePool(pool)) do
        if filter == nil or filter(entity) == true then

            local entityCoords = GetEntityCoords(entity)
            local distance = #(coords - entityCoords)
            if distance < maxDistance then
                maxDistance = distance
                closest, closestCoords = entity, entityCoords
            end
        end
    end

    return closest, closestCoords
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return { object: integer, coords: vector3 }[]
function lib.getNearbyObjects(coords, maxDistance)
    return getNearby("CObject", coords, maxDistance or 2.0, "object")
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return integer|nil object
---@return vector3|nil coords
function lib.getClosestObject(coords, maxDistance)
    return getClosest("CObject", coords, maxDistance or 2.0)
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@param includePlayerVehicle? boolean
---@return { vehicle: integer, coords: vector3 }[]
function lib.getNearbyVehicles(coords, maxDistance, includePlayerVehicle)

    local playerVehicle = cache.vehicle

    return getNearby("CVehicle", coords, maxDistance or 2.0, "vehicle", function (vehicle)
        return includePlayerVehicle == true or vehicle ~= playerVehicle
    end)
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@param includePlayerVehicle? boolean
---@return integer|nil vehicle
---@return vector3|nil coords
function lib.getClosestVehicle(coords, maxDistance, includePlayerVehicle)

    local playerVehicle = cache.vehicle

    return getClosest("CVehicle", coords, maxDistance or 2.0, function (vehicle)
        return includePlayerVehicle == true or vehicle ~= playerVehicle
    end)
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return { ped: integer, coords: vector3 }[]
function lib.getNearbyPeds(coords, maxDistance)
    return getNearby("CPed", coords, maxDistance or 2.0, "ped", function (ped)
        return IsPedAPlayer(ped) == false
    end)
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return integer|nil ped
---@return vector3|nil coords
function lib.getClosestPed(coords, maxDistance)
    return getClosest("CPed", coords, maxDistance or 2.0, function (ped)
        return IsPedAPlayer(ped) == false
    end)
end
