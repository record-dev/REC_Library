
---@class REC_Library.Shared.Validator
local Validator = {}

---Verify if it is empty
---@param value any Variable you want to verify (tables are also possible)
---@return boolean result
function Validator.isNull(value)
    if type(value) == "table" then
        return next(value) == nil
    else -- For non-tables
        return value == nil
    end
end

---The variable exists and
---@param value any variable you want to validate
---@return boolean result
function Validator.isNotNull(value)
    if type(value) == "table" then
        if next(value) == nil then
            return false
        end
    else -- For non-tables
        return value ~= nil
    end

    return true
end

---validation function to verify that table<number, string> is of type
---@param tbl any variable you want to verify
---@return boolean, string|nil Validation result and error message
function Validator.isTableOfNumberString(tbl)
    if type(tbl) ~= "table" then
        return false, "Input is not a table."
    end

    for k, v in pairs(tbl) do
        if type(k) ~= "number" then
            return false, ("Invalid key type: Key '%s' is a %s, expected a number."):format(tostring(k), type(k))
        end
        if type(v) ~= "string" then
            return false, ("Invalid value type for key '%s': Value is a %s, expected a string."):format(tostring(k), type(v))
        end
    end

    return true
end

---Validation function to verify that table<string, number> is of type
---@param tbl any variable you want to verify
---@return boolean, string|nil Validation result and error message
function Validator.isTableOfStringNumber(tbl)
    if type(tbl) ~= "table" then
        return false, "Input is not a table."
    end

    for k, v in pairs(tbl) do
        if type(k) ~= "string" then
            return false, ("Invalid key type: Key '%s' is a %s, expected a string."):format(tostring(k), type(k))
        end
        if type(v) ~= "number" then
            return false, ("Invalid value type for key '%s': Value is a %s, expected a number."):format(tostring(k), type(v))
        end
    end

    return true
end

---validation function to verify that the table<string, boolean> type
---@param tbl any variable you want to verify
---@return boolean, string|nil Validation result and error message
function Validator.isTableOfStringBoolean(tbl)
    if type(tbl) ~= "table" then
        return false, "Input is not a table."
    end

    for k, v in pairs(tbl) do
        if type(k) ~= "string" then
            return false, ("Invalid key type: Key '%s' is a %s, expected a string."):format(tostring(k), type(k))
        end
        if type(v) ~= "boolean" then
            return false, ("Invalid value type for key '%s': Value is a %s, expected a boolean."):format(tostring(k), type(v))
        end
    end

    return true
end

return Validator
