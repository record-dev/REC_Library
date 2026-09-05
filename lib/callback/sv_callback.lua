
---[[
---     callback (server)
---     lib.callback.register(name, fn(src, ...)) answers the clients,
---     lib.callback.await(name, playerId, ...) asks one client.
---]]

local callback = lib.callback
local pending = callback._pending()
local listening = callback._listening()

---@type table<string, integer>
local pendingSource = {}

---@param name string
local function listen(name)

    if listening[name] == true then
        return
    end

    listening[name] = true

    RegisterNetEvent(callback._event(name), function (key, ...)

        local src = source --[[@as integer]]

        local resolve = pending[key]
        if resolve == nil then
            return
        end

        -- only the client that was asked may answer
        if pendingSource[key] ~= src then
            return
        end

        pending[key] = nil
        pendingSource[key] = nil
        resolve(...)
    end)
end

---[[
---     Ask a client, the answer lands in cb
---]]
---@param name string
---@param playerId integer
---@param cb fun(...: any)
---@param ... any
function callback.trigger(name, playerId, cb, ...)

    assert(type(name) == "string", "name must be a string")
    assert(type(playerId) == "number", "playerId must be a number")
    assert(type(cb) == "function", "cb must be a function")

    listen(name)

    local key = callback._key()
    pending[key] = cb
    pendingSource[key] = playerId

    TriggerClientEvent(callback._event(name), playerId, key, ...)
end

---[[
---     Ask a client and wait for the answer
---]]
---@param name string
---@param playerId integer
---@param ... any
---@return ...
function callback.await(name, playerId, ...)

    assert(type(name) == "string", "name must be a string")
    assert(type(playerId) == "number", "playerId must be a number")

    listen(name)

    local key = callback._key()
    pendingSource[key] = playerId

    TriggerClientEvent(callback._event(name), playerId, key, ...)

    return callback._await(key)
end

---[[
---     Answer the clients, fn(src, ...) returns what the client receives
---]]
---@param name string
---@param fn fun(src: integer, ...: any): ...
function callback.register(name, fn)

    assert(type(name) == "string", "name must be a string")
    assert(type(fn) == "function", "fn must be a function")

    local event = callback._event(name)

    RegisterNetEvent(event, function (key, ...)

        local src = source --[[@as integer]]

        if type(key) ~= "string" then
            return
        end

        TriggerClientEvent(event, src, key, fn(src, ...))
    end)
end
