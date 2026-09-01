
---[[
---     Shared defaults for the REC_* admin panel browser route
---     https://docs.re-cord.dev/en/resources/rec_library/web-config
---]]
---@class REC_Library.Shared.Class.Web.WebConfig
local webConfig = {}

---@type string
local SHARED_PREFIX = "REC"

---@type string[]
local LOOPBACK_ADDRESSES = {
    "127.0.0.0/8",
    "::1",
}

---@type string[]
local PRIVATE_ADDRESSES = {
    "192.168.1.0/24",   -- LAN
    "172.16.0.0/12",    -- Docker
    "100.64.0.0/10",    -- Tailscale (CGNAT range)
}

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

    return GetConvar(("%s:%s"):format(SHARED_PREFIX, name), "")
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

    for _, entry in ipairs(LOOPBACK_ADDRESSES) do
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

    for _, entry in ipairs(PRIVATE_ADDRESSES) do
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

    return {
        [convar("adminToken")] = {
            label = "admin",
            scopes = {
                "*",
            },
        },
        [convar("supportToken")] = {
            label = "support",
            scopes = {
                "read",
            },
        },
    }
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
---@param customTokens? REC_Library.Shared.Class.Web.WebConfig.CustomToken[]
---@return table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
local function buildCustomTokens(customTokens)

    ---@type table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
    local extra = {}

    for _, entry in ipairs(customTokens or {}) do

        if type(entry.name) ~= "string" or entry.name == "" then
            goto continue
        end

        ---@type string
        local token = convar("token:" .. entry.name)

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
---     Build config.web from the shared defaults, overrides.http merged key by key
---]]
---@param debugMode boolean
---@param overrides REC_Library.Shared.Class.Web.WebConfig.Overrides
---@return REC_Library.Shared.Class.Web.WebConfig.Result
function webConfig:build(debugMode, overrides)

    assert(type(overrides) == "table", "overrides must be a table")
    assert(type(overrides.areas) == "table", "overrides.areas must be a string[]")

    ---@type REC_Library.Shared.Class.Web.WebConfig.Result
    local web = {
        inGameScopes = {
            "*",
        },
    }

    for key, value in pairs(overrides) do
        if key ~= "http" then
            web[key] = value
        end
    end

    web.http = {
        enabled = false,
        tokens = buildTokens(),
        distDir = "web/build",
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

---@class REC_Library.Shared.Class.Web.WebConfig.Http
---@field enabled boolean
---@field tokens table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken>
---@field distDir string
---@field allowedAddresses string[]
---@field trustedProxies string[]

---@class REC_Library.Shared.Class.Web.WebConfig.Overrides
---@field areas string[] permission areas this resource understands
---@field inGameScopes? string[] scopes the in-game panel runs with
---@field http? REC_Library.Shared.Class.Web.WebConfig.Http.Overrides merged over the defaults key by key
---@field [string] any anything else is copied onto config.web as is

---[[
---     Every http default a resource may replace, what is left out keeps the shared default
---]]
---@class REC_Library.Shared.Class.Web.WebConfig.Http.Overrides
---@field enabled? boolean false keeps the browser route off, which is the shipped default
---@field tokens? table<string, REC_Library.Server.Class.Web.WebAuth.ConfigToken> replaces the convar pair entirely
---@field customTokens? REC_Library.Shared.Class.Web.WebConfig.CustomToken[] named tokens on top of admin/support, each reads its value from its own convar
---@field distDir? string where the built panel lives, relative to the resource
---@field allowedAddresses? string[] IPv4 CIDR or a literal address, anything else gets 404
---@field trustedProxies? string[] addresses allowed to front the route, they must enforce their own access control

---@class REC_Library.Shared.Class.Web.WebConfig.CustomToken
---@field name string convar suffix (token:<name>), also the token's label unless label is set
---@field scopes string[] "economy:read", a bare area, "read"/"write", or "*"
---@field label? string shown in the panel and the change log instead of name

---@class REC_Library.Shared.Class.Web.WebConfig.Result
---@field areas string[]
---@field inGameScopes string[]
---@field http REC_Library.Shared.Class.Web.WebConfig.Http
