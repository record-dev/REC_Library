
---[[
---     cache (server)
---]]

---@class REC_Library.Lib.ServerCache
---@field resource string
---@field game string
cache = {
    resource = lib.name,
    game = GetGameName(),
}

---@param key string
---@param fn fun(value: any, oldValue: any)
function lib.onCache(key, fn)
    -- nothing changes on the server side, kept so shared code can call it
end
