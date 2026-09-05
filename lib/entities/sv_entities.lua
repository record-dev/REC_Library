
---[[
---     entities (server)
---     Same lookups as the client, ids are server ids here.
---]]

---@param coords vector3
---@param maxDistance? number default 2.0
---@return { id: integer, ped: integer, coords: vector3 }[]
function lib.getNearbyPlayers(coords, maxDistance)

    maxDistance = maxDistance or 2.0

    local nearby = {}

    for _, playerId in ipairs(GetPlayers()) do

        local src = tonumber(playerId) --[[@as integer]]
        local ped = GetPlayerPed(src)
        if ped ~= 0 then

            local pedCoords = GetEntityCoords(ped)
            if #(coords - pedCoords) < maxDistance then
                nearby[#nearby+1] = { id = src, ped = ped, coords = pedCoords, }
            end
        end
    end

    return nearby
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return integer|nil playerId
---@return integer|nil ped
---@return vector3|nil coords
function lib.getClosestPlayer(coords, maxDistance)

    maxDistance = maxDistance or 2.0

    local closestId, closestPed, closestCoords

    for _, playerId in ipairs(GetPlayers()) do

        local src = tonumber(playerId) --[[@as integer]]
        local ped = GetPlayerPed(src)
        if ped ~= 0 then

            local pedCoords = GetEntityCoords(ped)
            local distance = #(coords - pedCoords)
            if distance < maxDistance then
                maxDistance = distance
                closestId, closestPed, closestCoords = src, ped, pedCoords
            end
        end
    end

    return closestId, closestPed, closestCoords
end

---@param entities integer[]
---@param coords vector3
---@param maxDistance number
---@param key string
---@return table[]
local function getNearby(entities, coords, maxDistance, key)

    local nearby = {}

    for _, entity in ipairs(entities) do

        local entityCoords = GetEntityCoords(entity)
        if #(coords - entityCoords) < maxDistance then
            nearby[#nearby+1] = { [key] = entity, coords = entityCoords, }
        end
    end

    return nearby
end

---@param entities integer[]
---@param coords vector3
---@param maxDistance number
---@return integer|nil entity
---@return vector3|nil coords
local function getClosest(entities, coords, maxDistance)

    local closest, closestCoords

    for _, entity in ipairs(entities) do

        local entityCoords = GetEntityCoords(entity)
        local distance = #(coords - entityCoords)
        if distance < maxDistance then
            maxDistance = distance
            closest, closestCoords = entity, entityCoords
        end
    end

    return closest, closestCoords
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return { object: integer, coords: vector3 }[]
function lib.getNearbyObjects(coords, maxDistance)
    return getNearby(GetAllObjects(), coords, maxDistance or 2.0, "object")
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return integer|nil object
---@return vector3|nil coords
function lib.getClosestObject(coords, maxDistance)
    return getClosest(GetAllObjects(), coords, maxDistance or 2.0)
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return { vehicle: integer, coords: vector3 }[]
function lib.getNearbyVehicles(coords, maxDistance)
    return getNearby(GetAllVehicles(), coords, maxDistance or 2.0, "vehicle")
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return integer|nil vehicle
---@return vector3|nil coords
function lib.getClosestVehicle(coords, maxDistance)
    return getClosest(GetAllVehicles(), coords, maxDistance or 2.0)
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return { ped: integer, coords: vector3 }[]
function lib.getNearbyPeds(coords, maxDistance)
    return getNearby(GetAllPeds(), coords, maxDistance or 2.0, "ped")
end

---@param coords vector3
---@param maxDistance? number default 2.0
---@return integer|nil ped
---@return vector3|nil coords
function lib.getClosestPed(coords, maxDistance)
    return getClosest(GetAllPeds(), coords, maxDistance or 2.0)
end
