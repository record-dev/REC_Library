
---[[
---     table (shared)
---]]

---@class REC_Library.Lib.Table
local tbl = {}

---@param source table
---@return table
function tbl.clone(source)

    local copy = {}
    for k, v in pairs(source) do
        copy[k] = v
    end

    return setmetatable(copy, getmetatable(source))
end

---@param source table
---@return table
function tbl.deepclone(source)

    local copy = {}
    for k, v in pairs(source) do
        copy[k] = type(v) == "table" and tbl.deepclone(v) or v
    end

    return setmetatable(copy, getmetatable(source))
end

---@param source table
---@param value any
---@return boolean
function tbl.contains(source, value)

    for _, v in pairs(source) do
        if v == value then
            return true
        end
    end

    return false
end

---@param a table
---@param b table
---@return boolean
function tbl.matches(a, b)

    for k, v in pairs(a) do
        if type(v) == "table" then
            if type(b[k]) ~= "table" or tbl.matches(v, b[k]) == false then
                return false
            end
        elseif b[k] ~= v then
            return false
        end
    end

    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end

    return true
end

---@param target table
---@param source table
---@param addDuplicateNumbers? boolean sum numbers that exist in both tables
---@return table
function tbl.merge(target, source, addDuplicateNumbers)

    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            tbl.merge(target[k], v, addDuplicateNumbers)
        elseif addDuplicateNumbers == true and type(v) == "number" and type(target[k]) == "number" then
            target[k] += v
        else
            target[k] = v
        end
    end

    return target
end

lib.table = tbl
