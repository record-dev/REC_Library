
---[[
---     callback (shared)
---     The event name both sides agree on and the pending table the side specific
---     files fill. A key is unique per request so two resources awaiting the same
---     callback never pick up each other's answer.
---]]

---@type string
local cbEvent = "__rec_cb_%s"

---@type integer
local counter = 0

---@type integer
local timeout = 300000

---@type table<string, fun(...: any)>
local pending = {}

---@type table<string, boolean>
local listening = {}

---@class REC_Library.Lib.Callback
---@overload fun(name: string, target: integer | number | false, cb: fun(...: any), ...: any)
local callback = setmetatable({}, {
    __call = function (self, name, target, cb, ...)
        return self.trigger(name, target, cb, ...)
    end,
})

---@return string
function callback._key()
    counter += 1
    return ("%s:%d:%d"):format(lib.name, counter, math.random(100000, 999999))
end

---@param name string
---@return string
function callback._event(name)
    return cbEvent:format(name)
end

---@return table<string, fun(...: any)>
function callback._pending()
    return pending
end

---@return table<string, boolean>
function callback._listening()
    return listening
end

---@return integer
function callback._timeout()
    return timeout
end

---[[
---     Wait for the answer stored under key, nil after the timeout
---]]
---@param key string
---@return ...
function callback._await(key)

    local p = promise.new()

    pending[key] = function (...)
        p:resolve(table.pack(...))
    end

    SetTimeout(timeout, function ()
        if pending[key] == nil then
            return
        end

        pending[key] = nil
        print(("^3callback timed out... key: %s^0"):format(key))
        p:resolve(table.pack())
    end)

    local result = Citizen.Await(p)
    return table.unpack(result, 1, result.n)
end

lib.callback = callback
