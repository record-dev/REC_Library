
---[[
---     Shared defaults for the REC_* admin panel browser route
---     https://docs.re-cord.dev/en/resources/rec_library/web-config
---]]
---@class REC_Library.Server.Class.Web.WebConfig
local webConfig = {}

---[[
---     Every default below lives in server/sv_config.lua, so one edit there moves
---     every REC_* panel at once
---]]
---@type REC_Library.Server.Config
local svCfg = require "@REC_Library.server.sv_config"
local defaults = svCfg.webDefaults

---[[
---     Copy a default list before it leaves this file
---     Handing the shared table out would let one resource's config edit reach every
---     other panel, which is the one thing a default must not do.
---]]
---@param entries string[]
---@return string[]
local function copyList(entries)

    ---@type string[]
    local copy = {}

    for index, entry in ipairs(entries) do
        copy[index] = entry
    end

    return copy
end

---[[
---     Read a convar, preferring the one named after this resource
---     set REC:adminToken "..." for every panel, REC_Economy:adminToken "..." for one
---]]
---@param name string
---@return string
local function convar(name)

    ---@type string
    local own = GetConvar(("%s:%s"):format(GetCurrentResourceName(), name), "")

    if own ~= "" then
        return own
    end

    return GetConvar(("%s:%s"):format(svCfg.convarPrefix, name), "")
end

---[[
---     Split a convar holding a comma or space separated list
---]]
---@param name string
---@return string[]|nil nil when the convar is unset, which is not the same as empty
local function convarList(name)

    ---@type string
    local raw = convar(name)

    if raw == "" then
        return nil
    end

    ---@type string[]
    local entries = {}

    for entry in raw:gmatch("[^,%s]+") do
        entries[#entries+1] = entry
    end

    if #entries == 0 then
        return nil
    end

    return entries
end

---[[
---     Loopback only once debugMode is off
---     set REC:allowedAddresses "192.168.1.0/24, 100.64.0.0/10" replaces the list
---]]
---@param debugMode boolean
---@return string[]
local function buildAllowedAddresses(debugMode)

    ---@type string[]
    local addresses = {}

    for _, entry in ipairs(defaults.loopbackAddresses) do
        addresses[#addresses+1] = entry
    end

    ---@type string[]|nil
    local configured = convarList("allowedAddresses")

    if configured ~= nil then
        for _, entry in ipairs(configured) do
            addresses[#addresses+1] = entry
        end
        return addresses
    end

    if debugMode == false then
        return addresses
    end

    for _, entry in ipairs(defaults.privateAddresses) do
        addresses[#addresses+1] = entry
    end

    return addresses
end

---[[
---     Tokens read from convars, so they never live in a file that ships with the resource
---     set REC:supportToken for every panel, REC_ItemManager:supportToken for one
---]]
---@return table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
local function buildTokens()

    ---@type table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
    local tokens = {}

    for _, entry in ipairs(defaults.tokens) do

        ---@type string
        local token = convar(entry.convar)

        -- an unset convar would key every entry on "", so only the last one would
        -- survive the table. WebAuth drops it too, this keeps the count honest
        if token ~= "" then
            tokens[token] = {
                label = entry.label,
                scopes = copyList(entry.scopes),
            }
        end
    end

    return tokens
end

---[[
---     Extra named tokens beyond admin/support, each with its own scope list
---
---     A resource declares the name and the scopes in Lua (overrides.http.customTokens),
---     the operator only ever sets one convar to give it a value:
---         set REC_Economy:token:financeAudit "xxxxx"
---         set REC:token:auditorPool "yyyyy"   # falls back like every other token
---
---     Nothing to type wrong here: no scope syntax lives in a .cfg file, an unset
---     convar just means that named token does not exist yet.
---]]
---@param customTokens? REC_Library.Server.Class.Web.WebConfig.CustomToken[]
---@return table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
local function buildCustomTokens(customTokens)

    ---@type table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
    local extra = {}

    for _, entry in ipairs(customTokens or {}) do

        if type(entry.name) ~= "string" or entry.name == "" then
            goto continue
        end

        ---@type string
        local token = convar(defaults.customTokenPrefix .. entry.name)

        if token ~= "" then
            extra[token] = {
                label = entry.label or entry.name,
                scopes = entry.scopes or {},
            }
        end

        ::continue::
    end

    return extra
end

---[[
---     Reverse proxies allowed to front the route
---]]
---@return string[]
local function buildTrustedProxies()
    return convarList("trustedProxies") or {}
end

---[[
---     Drop the grant entries that could never match, and keep the rest as declared
---     A grant names a principal (an ACE, a job, or both, in which case both have to
---     match) and the scopes it hands out. Nothing is normalized into scopes here:
---     WebAuth does that, so a scope written one way in a grant and another way in a
---     token cannot end up meaning different things.
---]]
---@param grants any
---@return REC_Library.Server.Class.Web.WebConfig.Grant[]|nil nil when none were declared
local function buildGrants(grants)

    if type(grants) ~= "table" then
        return nil
    end

    ---@type REC_Library.Server.Class.Web.WebConfig.Grant[]
    local result = {}

    for index, grant in ipairs(grants) do

        if type(grant) ~= "table" then
            print(("^3[%s] web.grants[%d] is not a table and was dropped^0"):format(GetCurrentResourceName(), index))
            goto continue
        end

        if type(grant.ace) ~= "string" and type(grant.job) ~= "string" then
            print(("^3[%s] web.grants[%d] names neither an ace nor a job and was dropped^0"):format(GetCurrentResourceName(), index))
            goto continue
        end

        if type(grant.scopes) ~= "table" then
            print(("^3[%s] web.grants[%d] has no scopes and was dropped^0"):format(GetCurrentResourceName(), index))
            goto continue
        end

        result[#result+1] = {
            ace = grant.ace,
            job = grant.job,
            ranks = grant.ranks,
            onDutyOnly = grant.onDutyOnly,
            scopes = copyList(grant.scopes),
            label = grant.label,
        }

        ::continue::
    end

    -- an empty table is a declaration that nobody gets in, which is not the same as
    -- not declaring grants at all: only the latter falls back to the old aceGroups
    return result
end

---[[
---     Build config.web from the shared defaults, overrides.http merged key by key
---]]
---@param debugMode boolean
---@param overrides REC_Library.Server.Class.Web.WebConfig.Overrides
---@return REC_Library.Server.Class.Web.WebConfig.Result
function webConfig:build(debugMode, overrides)

    assert(type(overrides) == "table", "overrides must be a table")
    assert(type(overrides.areas) == "table", "overrides.areas must be a string[]")

    ---@type REC_Library.Server.Class.Web.WebConfig.Result
    local web = {
        inGameScopes = copyList(defaults.inGameScopes),
    }

    for key, value in pairs(overrides) do
        if key ~= "http" and key ~= "grants" then
            web[key] = value
        end
    end

    -- nil rather than an empty table when undeclared, so the in-game path can tell
    -- "no grants declared" (use the old aceGroups) from "grants deny everyone"
    web.grants = buildGrants(overrides.grants)

    web.http = {
        enabled = defaults.httpEnabled,
        tokens = buildTokens(),
        distDir = defaults.distDir,
        allowedAddresses = buildAllowedAddresses(debugMode),
        trustedProxies = buildTrustedProxies(),
    }

    for key, value in pairs(overrides.http or {}) do
        if key ~= "customTokens" then
            web.http[key] = value
        end
    end

    -- layered on top so a named token exists whether or not tokens itself was overridden
    for token, entry in pairs(buildCustomTokens(overrides.http and overrides.http.customTokens)) do
        web.http.tokens[token] = entry
    end

    return web
end

return webConfig

---@class REC_Library.Server.Class.Web.WebConfig.Http
---@field enabled boolean
---@field tokens table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
---@field distDir string
---@field allowedAddresses string[]
---@field trustedProxies string[]

---@class REC_Library.Server.Class.Web.WebConfig.Overrides
---@field areas string[] permission areas this resource understands
---@field grants? REC_Library.Server.Class.Web.WebConfig.Grant[] who opens the in-game panel and with which scopes, leaving this out keeps the resource's own aceGroups
---@field inGameScopes? string[] scopes the in-game panel runs with, ignored once grants is declared
---@field http? REC_Library.Server.Class.Web.WebConfig.Http.Overrides merged over the defaults key by key
---@field [string] any anything else is copied onto config.web as is

---[[
---     Every http default a resource may replace, what is left out keeps the shared default
---]]
---@class REC_Library.Server.Class.Web.WebConfig.Http.Overrides
---@field enabled? boolean false keeps the browser route off, which is the shipped default
---@field tokens? table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken> replaces the convar pair entirely
---@field customTokens? REC_Library.Server.Class.Web.WebConfig.CustomToken[] named tokens on top of admin/support, each reads its value from its own convar
---@field distDir? string where the built panel lives, relative to the resource
---@field allowedAddresses? string[] IPv4 CIDR or a literal address, anything else gets 404
---@field trustedProxies? string[] addresses allowed to front the route, they must enforce their own access control

---@class REC_Library.Server.Class.Web.WebConfig.CustomToken
---@field name string convar suffix (token:<name>), also the token's label unless label is set
---@field scopes string[] "economy:read", a bare area, "read"/"write", or "*"
---@field label? string shown in the panel and the change log instead of name

---[[
---     One rule handing scopes to whoever matches it
---     Every condition present has to match, so naming both an ace and a job means
---     the player needs both. A player matching several grants gets the union of
---     their scopes, which is why there is no deny form: to take something away,
---     stop granting it.
---]]
---@class REC_Library.Server.Class.Web.WebConfig.Grant
---@field ace? string ACE permission the player has to hold
---@field job? string framework job the player has to have
---@field ranks? integer[] job grades that count, nil means any of them
---@field onDutyOnly? boolean the job only counts while the player is on duty
---@field scopes string[] "economy:read", a bare area, "read"/"write", or "*"
---@field label? string recorded in the audit trail instead of the ace or job name

---@class REC_Library.Server.Class.Web.WebConfig.Result
---@field areas string[]
---@field grants REC_Library.Server.Class.Web.WebConfig.Grant[]|nil
---@field inGameScopes string[]
---@field http REC_Library.Server.Class.Web.WebConfig.Http
