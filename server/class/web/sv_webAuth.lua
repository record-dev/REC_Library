---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
---     Shared browser-route auth for the REC_* admin panels
---     Each token in config.web.http.tokens carries its own "<area>:<action>" scopes
---]]

---@type integer
local MIN_TOKEN_LENGTH = 32

---[[
---     Convert an IPv4 string to an integer
---]]
---@param ip string
---@return integer|nil
local function ipToInt(ip)

    local a, b, c, d = ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    if a == nil then
        return nil
    end

    a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
    if a > 255 or b > 255 or c > 255 or d > 255 then
        return nil
    end

    return (a << 24) | (b << 16) | (c << 8) | d
end

---[[
---     Strip the port from req.address ("127.0.0.1:52134" / "[::1]:52134")
---]]
---@param address any
---@return string|nil
local function parseAddress(address)

    if type(address) ~= "string" then
        return nil
    end

    local v6 = address:match("^%[(.+)%]:%d+$")
    if v6 ~= nil then
        return v6
    end

    local v4 = address:match("^([%d%.]+):%d+$")
    if v4 ~= nil then
        return v4
    end

    return address
end

---[[
---     Lowercase and unwrap IPv4-mapped IPv6 ("::ffff:127.0.0.1")
---]]
---@param ip string
---@return string
local function normalizeIp(ip)

    ip = ip:lower()

    local mapped = ip:match("^::ffff:([%d%.]+)$")
    if mapped ~= nil then
        return mapped
    end

    return ip
end

---[[
---     Match an address against one allowedAddresses / trustedProxies entry
---]]
---@param ip string
---@param entry string
---@return boolean
local function matchesEntry(ip, entry)

    local base, bits = entry:match("^(.+)/(%d+)$")
    if base == nil then
        return ip == entry:lower()
    end

    bits = tonumber(bits)
    local ipInt, baseInt = ipToInt(ip), ipToInt(base)
    if ipInt == nil or baseInt == nil or bits == nil or bits > 32 then
        return false
    end

    local mask = (0xFFFFFFFF << (32 - bits)) & 0xFFFFFFFF

    return (ipInt & mask) == (baseInt & mask)
end

---@param ip string
---@param entries string[]|nil
---@return boolean
local function matchesList(ip, entries)

    if type(entries) ~= "table" then
        return false
    end

    for _, entry in ipairs(entries) do
        if matchesEntry(ip, entry) == true then
            return true
        end
    end

    return false
end

---[[
---     "read" / "write" are shorthands for every area, everything else is taken as is
---]]
---@param scope any
---@return string|nil
local function normalizeScope(scope)

    if type(scope) ~= "string" then
        return nil
    end

    scope = scope:lower():gsub("%s", "")
    if scope == "" then
        return nil
    end

    if scope == "read" or scope == "write" then
        return "*:" .. scope
    end

    -- a bare area name grants both actions on it
    if scope:find(":") == nil then
        return scope .. ":*"
    end

    return scope
end

---[[
---     Split "<area>:<action>", "*" counts as both wildcards
---]]
---@param scope string
---@return string, string
local function splitScope(scope)

    if scope == "*" then
        return "*", "*"
    end

    local area, action = scope:match("^([^:]*):([^:]*)$")
    if area == nil then
        return scope, "*"
    end

    return area, action
end

---@class REC_Library.Server.Class.Web.WebAuth.Token
---@field token string
---@field label string
---@field scopes string[] as written in the config
---@field normalizedScopes string[] after the read / write shorthands are expanded
---@field enabled boolean
---@field expiresAt integer|nil unix time, nil never expires

---@class REC_Library.Server.Class.Web.WebAuth.Config
---@field resourceName string
---@field tokens table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>|nil
---@field allowedAddresses string[]|nil
---@field trustedProxies string[]|nil
---@field debug boolean|nil

---@class REC_Library.Server.Class.Web.WebAuth.ConfigToken
---@field label? string
---@field scopes? string[]
---@field enabled? boolean
---@field expiresAt? integer

---[[
---     Browser-route auth for one resource
---]]
---@class REC_Library.Server.Class.Web.WebAuth
---@field resourceName string
---@field tokens table<string, REC_Library.Server.Class.Web.WebAuth.Token>
---@field allowedAddresses string[]
---@field trustedProxies string[]
---@field debug boolean
local WebAuth = {}
WebAuth.__index = WebAuth

---instantiation
---@param config REC_Library.Server.Class.Web.WebAuth.Config
---@return REC_Library.Server.Class.Web.WebAuth
function WebAuth:new(config)
    local instance = setmetatable({}, self)

    instance.resourceName = config.resourceName or GetCurrentResourceName()
    instance.allowedAddresses = config.allowedAddresses or {}
    instance.trustedProxies = config.trustedProxies or {}
    instance.debug = config.debug == true
    instance.tokens = {}

    instance:setTokens(config.tokens)

    return instance
end

---[[
---     Replace the token table, dropping entries with an unusable token
---]]
---@param tokens table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>|nil
---@return integer count of usable tokens
function WebAuth:setTokens(tokens)

    self.tokens = {}

    if type(tokens) ~= "table" then
        return 0
    end

    local count = 0
    for token, entry in pairs(tokens) do

        if type(token) ~= "string" or token == "" then
            goto continue
        end

        if type(entry) ~= "table" then
            print(("^3[%s] token entry is not a table and was ignored^0"):format(self.resourceName))
            goto continue
        end

        ---@type string[]
        local normalizedScopes = {}
        for _, scope in ipairs(entry.scopes or {}) do
            local normalized = normalizeScope(scope)
            if normalized ~= nil then
                normalizedScopes[#normalizedScopes+1] = normalized
            end
        end

        if #normalizedScopes == 0 then
            print(("^3[%s] token '%s' has no scopes and can do nothing^0"):format(self.resourceName, entry.label or "?"))
        end

        self.tokens[token] = {
            token = token,
            label = type(entry.label) == "string" and entry.label ~= "" and entry.label or "token",
            scopes = entry.scopes or {},
            normalizedScopes = normalizedScopes,
            enabled = entry.enabled ~= false,
            expiresAt = type(entry.expiresAt) == "number" and entry.expiresAt or nil,
        }

        count = count + 1

        ::continue::
    end

    return count
end

---@return boolean whether at least one usable token is configured
function WebAuth:hasTokens()
    for _, tokenInfo in pairs(self.tokens) do
        if self:isUsable(tokenInfo) == true then
            return true
        end
    end
    return false
end

---@param tokenInfo REC_Library.Server.Class.Web.WebAuth.Token
---@return boolean
function WebAuth:isUsable(tokenInfo)

    if tokenInfo.enabled == false then
        return false
    end

    if tokenInfo.expiresAt ~= nil and os.time() >= tokenInfo.expiresAt then
        return false
    end

    return true
end

---[[
---     Warn about entries that can never work (startup check)
---]]
function WebAuth:warnConfig()

    for _, list in ipairs({ self.allowedAddresses, self.trustedProxies, }) do
        for _, entry in ipairs(list) do
            local base = entry:match("^(.+)/%d+$")
            if base ~= nil and ipToInt(base) == nil then
                print(("^3[%s] address entry is not an IPv4 CIDR and will never match: %s^0"):format(self.resourceName, entry))
            end
        end
    end

    if self:hasTokens() == false then
        print(("^3[%s] browser route is enabled but no usable token is configured - nobody can sign in^0"):format(self.resourceName))
        return
    end

    for token, tokenInfo in pairs(self.tokens) do
        if #token < MIN_TOKEN_LENGTH then
            print(("^3[%s] token '%s' is shorter than %d characters^0"):format(self.resourceName, tokenInfo.label, MIN_TOKEN_LENGTH))
        end
        if tokenInfo.expiresAt ~= nil and os.time() >= tokenInfo.expiresAt then
            print(("^3[%s] token '%s' has expired^0"):format(self.resourceName, tokenInfo.label))
        end
    end
end

---[[
---     Read the bearer token out of the request headers
---]]
---@param headers table<string, string>|nil
---@return string|nil
function WebAuth:readBearer(headers)

    if type(headers) ~= "table" then
        return nil
    end

    local auth = headers["Authorization"] or headers["authorization"]
    if type(auth) ~= "string" then
        return nil
    end

    local token = auth:match("^[Bb][Ee][Aa][Rr][Ee][Rr]%s+(.+)$")
    if token == nil or token == "" then
        return nil
    end

    return token
end

---[[
---     Resolve a request to the token that signed it
---]]
---@param headers table<string, string>|nil
---@return REC_Library.Server.Class.Web.WebAuth.Token|nil
function WebAuth:resolve(headers)

    local token = self:readBearer(headers)
    if token == nil then
        return nil
    end

    local tokenInfo = self.tokens[token]
    if tokenInfo == nil or self:isUsable(tokenInfo) == false then
        return nil
    end

    return tokenInfo
end

---[[
---     Whether a token may perform "<area>:<action>", "*" as either half is a wildcard
---]]
---@param tokenInfo REC_Library.Server.Class.Web.WebAuth.Token|nil
---@param required string
---@return boolean
function WebAuth:hasScope(tokenInfo, required)

    if tokenInfo == nil then
        return false
    end

    local normalized = normalizeScope(required)
    if normalized == nil then
        return false
    end

    local requiredArea, requiredAction = splitScope(normalized)

    for _, granted in ipairs(tokenInfo.normalizedScopes) do

        if granted == "*" then
            return true
        end

        local grantedArea, grantedAction = splitScope(granted)

        local areaMatches = grantedArea == "*" or grantedArea == requiredArea
        local actionMatches = grantedAction == "*" or grantedAction == requiredAction or requiredAction == "*"

        if areaMatches == true and actionMatches == true then
            return true
        end
    end

    return false
end

---[[
---     Build a token that is not in the table, for the ACE / job authenticated in-game panel
---]]
---@param label string
---@param scopes string[]|nil nil means full access
---@return REC_Library.Server.Class.Web.WebAuth.Token
function WebAuth:localToken(label, scopes)

    ---@type string[]
    local normalizedScopes = {}
    for _, scope in ipairs(scopes or { "*", }) do
        local normalized = normalizeScope(scope)
        if normalized ~= nil then
            normalizedScopes[#normalizedScopes+1] = normalized
        end
    end

    ---@type REC_Library.Server.Class.Web.WebAuth.Token
    return {
        token = "",
        label = label,
        scopes = scopes or { "*", },
        normalizedScopes = normalizedScopes,
        enabled = true,
        expiresAt = nil,
    }
end

---[[
---     Longest label kept, the audit columns are varchar(64)
---]]
---@type integer
local MAX_LABEL_LENGTH = 64

---[[
---     Does this player satisfy every condition the grant names
---]]
---@param src integer
---@param grant REC_Library.Server.Class.Web.WebConfig.Grant
---@param hasJob? fun(src: integer, job: string, ranks?: table<integer, true>, onDutyOnly?: boolean): boolean
---@return boolean
local function grantMatches(src, grant, hasJob)

    if type(grant.ace) == "string" and IsPlayerAceAllowed(tostring(src), grant.ace) ~= 1 then
        return false
    end

    if type(grant.job) == "string" then

        -- the framework adapter lives in REC_Utils, which this library does not depend
        -- on, so the caller passes the check in. Without one a job grant cannot match
        if hasJob == nil then
            return false
        end

        if hasJob(src, grant.job, grant.ranks, grant.onDutyOnly) ~= true then
            return false
        end
    end

    return true
end

---[[
---     The token one player runs the in-game panel with
---     Every grant that matches contributes its scopes, so holding two of them hands
---     out the union. nil means nothing matched, which is the same answer as "not
---     allowed in": the entry check and the scope list come from one declaration.
---]]
---@param src integer
---@param grants REC_Library.Server.Class.Web.WebConfig.Grant[]|nil
---@param hasJob? fun(src: integer, job: string, ranks?: table<integer, true>, onDutyOnly?: boolean): boolean
---@return REC_Library.Server.Class.Web.WebAuth.Token|nil
function WebAuth:resolveInGame(src, grants, hasJob)

    if type(grants) ~= "table" then
        return nil
    end

    ---@type string[]
    local scopes = {}

    ---@type string[]
    local labels = {}

    ---@type table<string, true>
    local seen = {}

    for _, grant in ipairs(grants) do

        if grantMatches(src, grant, hasJob) == false then
            goto continue
        end

        labels[#labels+1] = grant.label or grant.ace or grant.job

        for _, scope in ipairs(grant.scopes) do
            if seen[scope] == nil then
                seen[scope] = true
                scopes[#scopes+1] = scope
            end
        end

        ::continue::
    end

    if #labels == 0 then
        return nil
    end

    -- the label is what the audit trail records, so it names what let the player in
    return self:localToken(("in-game:%s"):format(table.concat(labels, "+")):sub(1, MAX_LABEL_LENGTH), scopes)
end

---[[
---     The ACE names out of a grant list, for lib.addCommand's restricted
---     A command takes a flat list of permissions and cannot express a job, so a
---     job only grant is not represented here: that matches what the command could
---     check anyway, and the panel's own gate still answers for those players.
---]]
---@param grants REC_Library.Server.Class.Web.WebConfig.Grant[]|nil
---@param requiredScope? string only the grants that hand this out, nil means all of them
---@return string[]
function WebAuth:aceGroups(grants, requiredScope)

    ---@type string[]
    local result = {}

    ---@type table<string, true>
    local seen = {}

    for _, grant in ipairs(grants or {}) do

        if type(grant.ace) ~= "string" or seen[grant.ace] ~= nil then
            goto continue
        end

        if requiredScope ~= nil and self:hasScope(self:localToken(grant.ace, grant.scopes), requiredScope) == false then
            goto continue
        end

        seen[grant.ace] = true
        result[#result+1] = grant.ace

        ::continue::
    end

    return result
end

---[[
---     The same token with every write dropped
---]]
---@param tokenInfo REC_Library.Server.Class.Web.WebAuth.Token
---@return REC_Library.Server.Class.Web.WebAuth.Token
function WebAuth:readOnly(tokenInfo)

    ---@type string[]
    local normalizedScopes = {}

    for _, granted in ipairs(tokenInfo.normalizedScopes) do
        local area, action = splitScope(granted)
        if action == "read" or action == "*" then
            normalizedScopes[#normalizedScopes+1] = area .. ":read"
        end
    end

    ---@type REC_Library.Server.Class.Web.WebAuth.Token
    return {
        token = tokenInfo.token,
        label = tokenInfo.label,
        scopes = normalizedScopes,
        normalizedScopes = normalizedScopes,
        enabled = tokenInfo.enabled,
        expiresAt = tokenInfo.expiresAt,
    }
end

---[[
---     The scopes as the UI needs them: what the caller may actually do
---]]
---@param tokenInfo REC_Library.Server.Class.Web.WebAuth.Token|nil
---@param areas string[]
---@return REC_Library.Server.Class.Web.WebAuth.Session
function WebAuth:toSession(tokenInfo, areas)

    ---@type table<string, boolean>
    local permissions = {}

    for _, area in ipairs(areas) do
        permissions[area .. ":read"] = self:hasScope(tokenInfo, area .. ":read")
        permissions[area .. ":write"] = self:hasScope(tokenInfo, area .. ":write")
    end

    ---@type REC_Library.Server.Class.Web.WebAuth.Session
    return {
        label = tokenInfo ~= nil and tokenInfo.label or "anonymous",
        scopes = tokenInfo ~= nil and tokenInfo.normalizedScopes or {},
        permissions = permissions,
        expiresAt = tokenInfo ~= nil and tokenInfo.expiresAt or nil,
    }
end

---[[
---     Whether a browser request comes from an allowed address
---]]
---@param address any
---@param headers table<string, string>|nil
---@return boolean
function WebAuth:isAllowedAddress(address, headers)

    local ip = parseAddress(address)
    if ip == nil then
        self:debugPrint(("^3failed to parse address... address: %s^0"):format(tostring(address)))
        return false
    end

    ip = normalizeIp(ip)

    -- a trusted proxy is the access-control point, X-Forwarded-For is kept for the log only
    if matchesList(ip, self.trustedProxies) == true then
        local forwarded = type(headers) == "table" and (headers["X-Forwarded-For"] or headers["x-forwarded-for"]) or nil
        local client = forwarded ~= nil and forwarded:match("([^,%s]+)%s*$") or nil
        self:debugPrint(("^5browser request via trusted proxy %s... client: %s^0"):format(ip, tostring(client)))
        return true
    end

    if matchesList(ip, self.allowedAddresses) == true then
        return true
    end

    self:debugPrint(("^3rejected browser request from %s...^0"):format(ip))

    return false
end

---@param ... any
function WebAuth:debugPrint(...)
    if self.debug == true then
        utils:debugPrint(...)
    end
end

---@class REC_Library.Server.Class.Web.WebAuth.Session
---@field label string
---@field scopes string[]
---@field permissions table<string, boolean> "<area>:<action>" -> allowed
---@field expiresAt integer|nil

return WebAuth
