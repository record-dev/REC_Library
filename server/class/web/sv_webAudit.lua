---[[
---     Shared write trail for the REC_* admin panels
---     Recorded at the gate rather than per endpoint: every write already passes one
---     scope check, so hooking that is what makes the trail complete instead of
---     complete-where-somebody-remembered.
---
---     Reads are never recorded. A panel polls them, so they would bury the writes
---     without saying anything a write does not already say.
---]]
---@class REC_Library.Server.Class.Web.WebAudit
---@field resourceName string
---@field enabled boolean
---@field keepDays integer 0 keeps rows forever
---@field memorySize integer rows kept in memory for a panel that has no DB
---@field rows REC_Library.Server.Class.Web.WebAudit.Row[] newest last
---@field dbReady boolean
---@field debug boolean
local WebAudit = {}
WebAudit.__index = WebAudit

---@type string
local TABLE_NAME = "rec_web_audit"

---[[
---     Column widths, so a long path never fails the insert
---]]
---@type table<string, integer>
local LIMITS = {
    action = 64,
    scope = 64,
    actor = 64,
    actorIdentifier = 64,
    detail = 255,
}

---@param value any
---@param limit integer
---@return string|nil
local function clip(value, limit)

    if type(value) ~= "string" or value == "" then
        return nil
    end

    return value:sub(1, limit)
end

---instantiation
---@param config REC_Library.Server.Class.Web.WebAudit.Config
---@return REC_Library.Server.Class.Web.WebAudit
function WebAudit:new(config)
    assert(type(config) == "table", "config must be a table")
    assert(type(config.resourceName) == "string", "config.resourceName must be a string")

    local instance = setmetatable({}, self)

    instance.resourceName = config.resourceName
    instance.enabled = config.enabled ~= false
    instance.keepDays = type(config.keepDays) == "number" and math.max(0, math.floor(config.keepDays)) or 30
    instance.memorySize = type(config.memorySize) == "number" and math.max(1, math.floor(config.memorySize)) or 200
    instance.rows = {}
    instance.dbReady = false
    instance.debug = config.debug == true

    return instance
end

---@param ... any
function WebAudit:debugPrint(...)
    if self.debug == true then
        print(("^6[%s][audit]^0"):format(self.resourceName), ...)
    end
end

---[[
---     Whether the table is there, checked once
---     A server that never ran rec_web_audit.sql keeps the in-memory trail and says
---     so once, rather than failing an insert per write.
---]]
---@return boolean
function WebAudit:ensureTable()

    if self.dbReady == true then
        return true
    end

    if MySQL == nil then
        return false
    end

    local query = "SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ? LIMIT 1"

    local ok, exists = pcall(MySQL.scalar.await, query, { TABLE_NAME, })
    if ok == false or exists == nil then
        print(("^3[%s] %s is missing, the write trail stays in memory only. Run rec_web_audit.sql^0"):format(self.resourceName, TABLE_NAME))
        return false
    end

    self.dbReady = true

    return true
end

---[[
---     Record one write
---     Never yields: the insert is fired and forgotten, so a gate cannot be slowed
---     down by the database.
---]]
---@param entry REC_Library.Server.Class.Web.WebAudit.Entry
function WebAudit:record(entry)

    if self.enabled == false then
        return
    end

    if type(entry) ~= "table" or type(entry.action) ~= "string" or entry.action == "" then
        return
    end

    ---@type REC_Library.Server.Class.Web.WebAudit.Row
    local row = {
        resource = self.resourceName,
        action = clip(entry.action, LIMITS.action) or "unknown",
        scope = clip(entry.scope, LIMITS.scope),
        actor = clip(entry.actor, LIMITS.actor) or "anonymous",
        actorIdentifier = clip(entry.actorIdentifier, LIMITS.actorIdentifier),
        allowed = entry.allowed ~= false,
        detail = clip(entry.detail, LIMITS.detail),
        createdAt = os.time(),
    }

    self.rows[#self.rows+1] = row
    if #self.rows > self.memorySize then
        table.remove(self.rows, 1)
    end

    self:debugPrint(("%s %s by %s"):format(row.allowed == true and "allowed" or "refused", row.action, row.actor))

    if self.dbReady == false then
        return
    end

    local query = ("INSERT INTO `%s` (`resource`, `action`, `scope`, `actor`, `actorIdentifier`, `allowed`, `detail`) VALUES (?, ?, ?, ?, ?, ?, ?)"):format(TABLE_NAME)

    MySQL.insert(query, {
        row.resource,
        row.action,
        row.scope,
        row.actor,
        row.actorIdentifier,
        row.allowed == true and 1 or 0,
        row.detail,
    })
end

---[[
---     Open the table and drop what aged out, both in one thread
---     Called from the resource once oxmysql is up.
---]]
function WebAudit:start()

    if self.enabled == false then
        return
    end

    if self:ensureTable() == false then
        return
    end

    self:prune()
end

---[[
---     Delete rows past keepDays, this resource's only
---]]
function WebAudit:prune()

    if self.dbReady == false or self.keepDays <= 0 then
        return
    end

    local query = ("DELETE FROM `%s` WHERE `resource` = ? AND `createdAt` < DATE_SUB(NOW(), INTERVAL ? DAY)"):format(TABLE_NAME)

    local ok, removed = pcall(MySQL.update.await, query, { self.resourceName, self.keepDays, })
    if ok == true and type(removed) == "number" and removed > 0 then
        self:debugPrint(("pruned %d rows older than %d days"):format(removed, self.keepDays))
    end
end

---[[
---     The trail this resource wrote, newest first
---     Falls back to the in-memory ring when the table is missing, so a panel page
---     shows something rather than an error.
---]]
---@param limit? integer
---@return REC_Library.Server.Class.Web.WebAudit.Row[]
function WebAudit:list(limit)

    limit = math.min(math.max(tonumber(limit) or 100, 1), 1000)

    if self.dbReady == false then

        ---@type REC_Library.Server.Class.Web.WebAudit.Row[]
        local result = {}
        for index = #self.rows, math.max(1, #self.rows - limit + 1), -1 do
            result[#result+1] = self.rows[index]
        end
        return result
    end

    local query = ("SELECT `action`, `scope`, `actor`, `actorIdentifier`, `allowed`, `detail`, UNIX_TIMESTAMP(`createdAt`) AS `createdAt` FROM `%s` WHERE `resource` = ? ORDER BY `id` DESC LIMIT ?"):format(TABLE_NAME)

    local ok, rows = pcall(MySQL.query.await, query, { self.resourceName, limit, })
    if ok == false then
        return {}
    end

    return rows or {}
end

return WebAudit

---[[
---     Only the scope check knows enough to fill this in, which is why the gate is
---     where it is recorded
---]]
---@class REC_Library.Server.Class.Web.WebAudit.Entry
---@field action string what was asked for, an endpoint name or a method and path
---@field scope? string the scope the gate required
---@field actor? string token label, or "in-game:<grant>" for the NUI
---@field actorIdentifier? string the player name in game, the calling address over http
---@field allowed? boolean false records a refusal, which is the half worth keeping
---@field detail? string anything else worth reading back

---@class REC_Library.Server.Class.Web.WebAudit.Row: REC_Library.Server.Class.Web.WebAudit.Entry
---@field resource string
---@field createdAt integer

---@class REC_Library.Server.Class.Web.WebAudit.Config
---@field resourceName string
---@field enabled? boolean
---@field keepDays? integer
---@field memorySize? integer
---@field debug? boolean
