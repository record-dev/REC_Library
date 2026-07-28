
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Manager.BlipManager
---@field info REC_Library.Client.Class.Manager.BlipManagerConfigBuilder
local BlipManager = {}
BlipManager.__index = BlipManager

---instantiation
---@param config REC_Library.Client.Class.Manager.BlipManagerConfigBuilder
---@return self
function BlipManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Registration
---@param uid string
---@param blip REC_Library.Client.Class.Blip.Blip
---@param group? string
---@return boolean
function BlipManager:register(uid, blip, group)
    local info = self.info

    -- Argument check
    assert(type(uid) == "string", "uid must be a string.")
    assert(type(blip) == "table", "blip must be a table.")

    -- Existence confirmation
    if self:doesExist(uid) == true then
        utils:debugPrint("[BlipManager:register] blip already exist with uid:", uid)
        return false
    end

    -- Registration
    info.blips[uid] = blip

    if group ~= nil then
        if info.blipsByGroup[group] == nil then
            info.blipsByGroup[group] = {}
        end

        info.blipsByGroup[group][uid] = blip
        info.keyToGroup[uid] = group
    end

    return true
end

---Unregister
---@return boolean
function BlipManager:unregister(uid)
    local info = self.info

    -- Argument check
    assert(type(uid) == "string", "uid must be a string")

    if self:doesExist(uid) == false then
        utils:debugPrint("[BlipManager:unregister] blip is not exist with uid:", uid)
        return false
    end

    -- Discard Blip
    info.blips[uid]:destroy()

    -- Unregister
    info.blips[uid] = nil

    --Group check
    local group = info.keyToGroup[uid]
    if group ~= nil then
        info.blipsByGroup[group][uid] = nil
        if next(info.blipsByGroup[group]) == nil then
            info.blipsByGroup[group] = nil   -- Delete the group itself when empty
        end
        info.keyToGroup[uid] = nil
    end

    return true
end

---@param group string
---@return boolean
function BlipManager:unregisterAllByGroup(group)
    local info = self.info

    -- Group confirmation
    local blips = info.blipsByGroup[group]
    if blips == nil then
        utils:debugPrint("[BlipManager:unregisterAllByGroup] blipsByGroup is not exist with group:", group)
        return false
    end

    for key, _ in pairs(blips) do
        if self:unregister(key) == false then
            utils:debugPrint(("^3failed to unregister blip... blipKey: %s^0"):format(key))
            return false
        end
    end

    return true
end

---Existence confirmation
---@return boolean
function BlipManager:doesExist(uid)
    local info = self.info

    -- Argument check
    assert(type(uid) == "string", "uid must be a string")

    return info.blips[uid] ~= nil
end

---Get all Blips
---@return table<string, REC_Library.Client.Class.Blip.Blip>|nil
function BlipManager:getBlips()
    local info = self.info
    return next(info.blips) ~= nil and info.blips or nil
end

return BlipManager
