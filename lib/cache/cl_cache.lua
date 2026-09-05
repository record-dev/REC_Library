
---[[
---     cache (client)
---     cache.ped / vehicle / seat / weapon follow the local player, refreshed every
---     100ms. lib.onCache(key, fn) is called with (newValue, oldValue) on each change.
---]]

---@class REC_Library.Lib.Cache
---@field resource string
---@field game string
---@field playerId integer
---@field serverId integer
---@field ped integer
---@field vehicle integer | false
---@field seat integer | false
---@field weapon integer | false
---@field coords vector3
cache = {
    resource = lib.name,
    game = GetGameName(),
    playerId = PlayerId(),
    serverId = GetPlayerServerId(PlayerId()),
    ped = PlayerPedId(),
    vehicle = false,
    seat = false,
    weapon = false,
    coords = GetEntityCoords(PlayerPedId()),
}

---@type table<string, fun(value: any, oldValue: any)[]>
local handlers = {}

---@param key "ped" | "vehicle" | "seat" | "weapon" | "coords"
---@param fn fun(value: any, oldValue: any)
function lib.onCache(key, fn)

    assert(type(key) == "string", "key must be a string")
    assert(type(fn) == "function", "fn must be a function")

    local list = handlers[key]
    if list == nil then
        list = {}
        handlers[key] = list
    end

    list[#list+1] = fn
end

---@param key string
---@param value any
local function update(key, value)

    local oldValue = cache[key]
    if oldValue == value then
        return
    end

    cache[key] = value

    local list = handlers[key]
    if list == nil then
        return
    end

    for _, fn in ipairs(list) do
        CreateThread(function ()
            fn(value, oldValue)
        end)
    end
end

---@param ped integer
---@param vehicle integer
---@return integer | false
local function getSeat(ped, vehicle)

    for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        if GetPedInVehicleSeat(vehicle, seat) == ped then
            return seat
        end
    end

    return false
end

---@type integer
local unarmed = `WEAPON_UNARMED`

CreateThread(function ()
    while true do

        local ped = PlayerPedId()
        update("ped", ped)

        cache.coords = GetEntityCoords(ped)

        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle == 0 then
            update("vehicle", false)
            update("seat", false)
        else
            update("vehicle", vehicle)
            update("seat", getSeat(ped, vehicle))
        end

        local weapon = GetSelectedPedWeapon(ped)
        update("weapon", weapon ~= unarmed and weapon or false)

        Wait(100)
    end
end)
