---[[
---     REC_Library server config
---     The shared defaults every REC_* resource starts from. A resource overrides
---     what it needs in its own config/sv_config.lua, everything it leaves out comes
---     from here, so one edit in this file moves every panel at once.
---
---     Server side on purpose: a shared_script is downloaded by every client and can
---     be read there, and the staff list must not be.
---]]

---@class REC_Library.Server.Config
local config = {}

---@type boolean
config.debugMode = true

---[[
---     Convar prefix every REC_* resource falls back to
---     A resource named convar wins over this one, so REC_Economy:adminToken beats
---     REC:adminToken. Changing this renames every convar the server already sets.
---]]
---@type string
config.convarPrefix = "REC"

---[[
---     Shared defaults for the admin panels
---     sv_webConfig builds each resource's config.web from these.
---]]
config.webDefaults = {

    ---[[
    ---     Who opens every REC_* panel, and what they may do once inside
    ---     A resource adds its own narrower entries on top of these rather than
    ---     replacing them, so naming one moderator grant in one panel can never drop
    ---     the row that lets an admin back in.
    ---
    ---     Every entry that matches contributes its scopes, so someone holding two of
    ---     them gets the union. There is no deny form: to take something away, stop
    ---     granting it.
    ---]]
    ---@type REC_Library.Server.Class.Web.WebConfig.Grant[]
    grants = {
        { ace = "admin", scopes = { "*", }, },
    },

    ---[[
    ---     Always allowed to reach the browser route
    ---     Emptying this locks the panel out of the machine it runs on.
    ---]]
    ---@type string[]
    loopbackAddresses = {
        "127.0.0.0/8",
        "::1",
    },

    ---[[
    ---     Allowed on top of loopback while debugMode is on
    ---     Off in release, and the REC:allowedAddresses convar replaces both lists.
    ---]]
    ---@type string[]
    privateAddresses = {
        "192.168.1.0/24",   -- LAN
        "172.16.0.0/12",    -- Docker
        "100.64.0.0/10",    -- Tailscale (CGNAT range)
    },

    ---[[
    ---     The token pair every panel understands, each read from its own convar
    ---     Only the convar name lives here, never a value. Add an entry to give every
    ---     REC_* panel one more token in a single move:
    ---         { convar = "moderatorToken", label = "moderator", scopes = { "read", }, },
    ---     A resource still narrows its own with http.customTokens.
    ---]]
    ---@type REC_Library.Server.Config.WebDefaults.Token[]
    tokens = {
        { convar = "adminToken",   label = "admin",   scopes = { "*", }, },
        { convar = "supportToken", label = "support", scopes = { "read", }, },
    },

    ---[[
    ---     Convar prefix a named token reads its value from (token:<name>)
    ---]]
    ---@type string
    customTokenPrefix = "token:",

    ---@type string
    distDir = "web/build", -- where a built panel lives, relative to the resource

    ---@type boolean
    httpEnabled = false, -- the browser route is off until a resource turns it on
}

---[[
---     Shared defaults for the characters left out of the figures
---     sv_staffConfig builds each resource's config.staff from these, and every
---     REC_* resource that counts money, items or activity asks it before adding a
---     character to a total.
---
---     Naming a character here covers the whole server. The convar does the same
---     without touching a file, and the two are merged:
---         set REC:staffCitizenIds "ABCDEFGH, K3PQ81ZR"
---]]
config.staffDefaults = {

    ---[[
    ---     Characters every resource leaves out, added to whatever the convar lists
    ---]]
    ---@type string[]
    citizenIds = {
        -- "ABCDEFGH",
    },

    ---[[
    ---     Counted as staff where only the source is known, never for an offline one
    ---     A resource replaces this rather than adding to it, because widening a
    ---     permission boundary should never happen by accident.
    ---]]
    ---@type string[]
    aceGroups = {
        "admin",
    },

    ---@type string
    convar = "staffCitizenIds", -- convar suffix the shared list is read from
}

return config

---@class REC_Library.Server.Config.WebDefaults.Token
---@field convar string convar suffix the token value is read from
---@field label string shown in the panel and the change log
---@field scopes string[] "economy:read", a bare area, "read"/"write", or "*"
