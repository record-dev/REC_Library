---[[
---     Characters left out of a resource's figures
---     Every REC_* resource that counts money, items or activity asks this before it
---     adds a character to a total, so a staff member may hold whatever they like
---     without the circulation, the money supply or the rankings following them.
---
---     Built once in config/sv_config.lua, staffConfig:build() hands back one of these:
---         config.staff = staffConfig:build({ citizenIds = { "ABCDEFGH", }, })
---]]
---@class REC_Library.Server.Class.Staff.Staff
---@field info REC_Library.Server.Class.Staff.StaffConfig.Result
local Staff = {}
Staff.__index = Staff

---instantiation
---@param staffConfig REC_Library.Server.Class.Staff.StaffConfig.Result
---@return self
function Staff:new(staffConfig)
    assert(type(staffConfig) == "table", "staffConfig must be a staffConfig:build() result")
    assert(type(staffConfig.citizenIds) == "table", "staffConfig.citizenIds is missing, build it with staffConfig:build()")

    local instance = setmetatable({}, self)

    instance.info = staffConfig

    return instance
end

---[[
---     Is this character left out of the figures
---     Answers for an offline citizenId too, which is what the DB walks need and what
---     an ACE check cannot do.
---]]
---@param citizenId? string
---@return boolean
function Staff:has(citizenId)

    if self.info.enabled == false or type(citizenId) ~= "string" then
        return false
    end

    return self.info.citizenIds[citizenId] ~= nil
end

---[[
---     Online only answer, for a path that knows the source but not the character
---     A ped position sample has no citizenId to hand, the ACE groups answer instead.
---]]
---@param src integer|string
---@return boolean
function Staff:hasSource(src)

    if self.info.enabled == false then
        return false
    end

    for _, group in ipairs(self.info.aceGroups) do
        if IsPlayerAceAllowed(tostring(src), group) == 1 then
            return true
        end
    end

    return false
end

---[[
---     The excluded characters as a list, for a NOT IN (?) parameter
---     Empty means every character counts, so a query has to drop the clause instead
---     of sending an empty list.
---]]
---@return string[]
function Staff:list()

    if self.info.enabled == false then
        return {}
    end

    return self.info.list
end

---[[
---     The excluded characters as a lookup table, for a walk that tests every row
---]]
---@return table<string, true>
function Staff:lookup()

    if self.info.enabled == false then
        return {}
    end

    return self.info.citizenIds
end

return Staff
