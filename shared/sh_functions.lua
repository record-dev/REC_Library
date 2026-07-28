
---@class REC_Library.Shared.Functions
local functions = {}

---Output a random spawn point on the flame from the specified coordinates
---@param x number x coordinate of the center point you want to boil
---@param y number y coordinate of the center point you want to boil
---@param z number z coordinate of the center point you want to boil
---@param radius number Range you want to boil (radius)
---@return vector3
function functions:getRandomCoords(x, y, z, radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * radius

    -- calculate new coordinates
    local newX = x + distance * math.cos(angle)
    local newY = y + distance * math.sin(angle)
    local newZ = z

    return vector3(newX, newY, newZ)
end


---[[
--- Generate event table
---]]
---@param prefix string
---@param tbl table
function functions:generateEventsName(prefix, tbl)
    for key, value in pairs(tbl) do
        if type(value) == "string" then
            tbl[key] = prefix .. ":" .. key
        else
            functions:generateEventsName(prefix .. ":" .. key, value)
        end
    end
end

return functions
