
---[[
---     callback (client)
---     lib.callback.await(name, delay, ...) asks the server, lib.callback.register
---     answers the server. delay is false or a per name throttle in ms.
---]]

local callback = lib.callback
local pending = callback._pending()
local listening = callback._listening()

---@type table<string, integer>
local lastCall = {}

---@param name string
local function listen(name)

    if listening[name] == true then
        return
    end

    listening[name] = true

    RegisterNetEvent(callback._event(name), function (key, ...)

        local resolve = pending[key]
        if resolve == nil then
            return
        end

        pending[key] = nil
        resolve(...)
    end)
end

---@param name string
---@param delay number | false
---@return boolean allowed
local function throttle(name, delay)

    if type(delay) ~= "number" or delay <= 0 then
        return true
    end

    local now = GetGameTimer()
    local last = lastCall[name]
    if last ~= nil and now - last < delay then
        return false
    end

    lastCall[name] = now
    return true
end

---[[
---     Ask the server, the answer lands in cb
---]]
---@param name string
---@param delay number | false
---@param cb fun(...: any)
---@param ... any
function callback.trigger(name, delay, cb, ...)

    assert(type(name) == "string", "name must be a string")
    assert(type(cb) == "function", "cb must be a function")

    if throttle(name, delay) == false then
        return
    end

    listen(name)

    local key = callback._key()
    pending[key] = cb

    TriggerServerEvent(callback._event(name), key, ...)
end

---[[
---     Ask the server and wait for the answer
---]]
---@param name string
---@param delay number | false
---@param ... any
---@return ...
function callback.await(name, delay, ...)

    assert(type(name) == "string", "name must be a string")

    if throttle(name, delay) == false then
        return
    end

    listen(name)

    local key = callback._key()
    TriggerServerEvent(callback._event(name), key, ...)

    return callback._await(key)
end

---[[
---     Answer the server, fn(...) returns what the server receives
---]]
---@param name string
---@param fn fun(...: any): ...
function callback.register(name, fn)

    assert(type(name) == "string", "name must be a string")
    assert(type(fn) == "function", "fn must be a function")

    local event = callback._event(name)

    RegisterNetEvent(event, function (key, ...)

        if type(key) ~= "string" then
            return
        end

        TriggerServerEvent(event, key, fn(...))
    end)
end
