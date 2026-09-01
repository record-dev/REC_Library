---[[
---     Shared defaults for the characters a REC_* resource leaves out of its figures
---     https://docs.re-cord.dev/en/resources/rec_library/staff-config
---]]
---@class REC_Library.Server.Class.Staff.StaffConfig
local staffConfig = {}

---@type REC_Library.Server.Class.Staff.Staff
local Staff = require "@REC_Library.server.class.staff.sv_staff"

---[[
---     Every default below lives in server/sv_config.lua, so one edit there moves
---     every REC_* resource that counts anything
---]]
---@type REC_Library.Server.Config
local svCfg = require "@REC_Library.server.sv_config"
local defaults = svCfg.staffDefaults

---[[
---     Read a convar, preferring the one named after this resource
---     set REC:staffCitizenIds "..." for every resource,
---     set REC_Economy:staffCitizenIds "..." for one
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
---     The characters every resource on this server leaves out
---     The list in sv_config and the convar are both shared, so both land here:
---     one is edited in a file, the other without touching one.
---         set REC:staffCitizenIds "ABCDEFGH, K3PQ81ZR"
---]]
---@return string[]
local function buildSharedCitizenIds()

    ---@type string[]
    local entries = {}

    for _, citizenId in ipairs(defaults.citizenIds) do
        entries[#entries+1] = citizenId
    end

    for _, citizenId in ipairs(convarList(defaults.convar) or {}) do
        entries[#entries+1] = citizenId
    end

    return entries
end

---[[
---     Build config.staff from the shared list, overrides.citizenIds added on top
---
---     citizenIds is the one key that is added rather than replaced: a resource
---     naming one character of its own must never drop the server wide list, which
---     is the mistake a replacing merge makes silently. The shared list is sv_config
---     staffDefaults.citizenIds plus the convar. Pass useSharedList false
---     when a resource really has to stand alone.
---]]
---@param overrides? REC_Library.Server.Class.Staff.StaffConfig.Overrides
---@return REC_Library.Server.Class.Staff.Staff
function staffConfig:build(overrides)

    overrides = overrides or {}

    assert(type(overrides) == "table", "overrides must be a table")

    ---@type table<string, true>
    local citizenIds = {}

    ---@type string[]
    local list = {}

    ---@param entries string[]|nil
    local function add(entries)
        for _, citizenId in ipairs(entries or {}) do
            if type(citizenId) == "string" and citizenId ~= "" and citizenIds[citizenId] == nil then
                citizenIds[citizenId] = true
                list[#list+1] = citizenId
            end
        end
    end

    if overrides.useSharedList ~= false then
        add(buildSharedCitizenIds())
    end

    add(overrides.citizenIds)

    ---@type string[]
    local aceGroups = {}
    for index, group in ipairs(overrides.aceGroups or defaults.aceGroups) do
        aceGroups[index] = group
    end

    ---@type REC_Library.Server.Class.Staff.StaffConfig.Result
    local staff = {
        citizenIds = citizenIds,
        list = list,
        aceGroups = aceGroups,
        enabled = overrides.enabled ~= false,
    }

    return Staff:new(staff)
end

return staffConfig

---[[
---     Every default a resource may replace, what is left out keeps the shared one
---]]
---@class REC_Library.Server.Class.Staff.StaffConfig.Overrides
---@field citizenIds? string[] added on top of the shared list rather than replacing it, so an empty one changes nothing
---@field aceGroups? string[] replaces the default, because widening a permission boundary must be deliberate. An empty one is taken at its word and leaves hasSource() answering false for everyone
---@field enabled? boolean false counts staff like anyone else, so every figure covers the whole roster
---@field useSharedList? boolean false leaves the shared list out, only citizenIds counts then

---@class REC_Library.Server.Class.Staff.StaffConfig.Result
---@field citizenIds table<string, true> lookup table, the DB walks index this directly
---@field list string[] the same ids in order, for a NOT IN (?) parameter
---@field aceGroups string[]
---@field enabled boolean
