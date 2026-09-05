
---[[
---     points (client)
---     A point is a coordinate with a distance. Every 300ms the distance to the
---     player is measured, onEnter / onExit fire when it crosses, and nearby runs
---     every frame only while the player is inside. Draw markers in nearby and
---     nothing is rendered until someone is close enough to see it.
---]]

---@class REC_Library.Lib.Point.Options
---@field coords vector3
---@field distance? number default 2.0
---@field onEnter? fun(self: REC_Library.Lib.Point)
---@field onExit? fun(self: REC_Library.Lib.Point)
---@field nearby? fun(self: REC_Library.Lib.Point)
---@field [string] any anything else is kept on the point

---@class REC_Library.Lib.Point: REC_Library.Lib.Point.Options
---@field id integer
---@field currentDistance number
---@field isClosest boolean
---@field inside boolean
---@field remove fun(self: REC_Library.Lib.Point)

---@class REC_Library.Lib.Points
local points = {}

---@type table<integer, REC_Library.Lib.Point>
local registry = {}

---@type REC_Library.Lib.Point[]
local nearbyPoints = {}

---@type REC_Library.Lib.Point|nil
local closestPoint = nil

---@type integer
local nextId = 0

---@type boolean
local checkRunning = false

---@type boolean
local tickRunning = false

---@param self REC_Library.Lib.Point
local function remove(self)

    registry[self.id] = nil

    if self.inside == true then
        self.inside = false
        if self.onExit ~= nil then
            self:onExit()
        end
    end

    if closestPoint == self then
        closestPoint = nil
    end
end

local function ensureTick()

    if tickRunning == true then
        return
    end

    tickRunning = true

    CreateThread(function ()
        while #nearbyPoints > 0 do

            for i = 1, #nearbyPoints do
                local point = nearbyPoints[i]
                if point.nearby ~= nil then
                    point:nearby()
                end
            end

            Wait(0)
        end

        tickRunning = false
    end)
end

local function ensureCheck()

    if checkRunning == true then
        return
    end

    checkRunning = true

    CreateThread(function ()
        while next(registry) ~= nil do

            local coords = GetEntityCoords(cache.ped)
            local nearby = {}
            local closest = nil
            local closestDistance = math.huge

            for _, point in pairs(registry) do

                local distance = #(coords - point.coords)
                point.currentDistance = distance
                point.isClosest = false

                local inside = distance <= point.distance
                if inside ~= point.inside then
                    point.inside = inside
                    if inside == true then
                        if point.onEnter ~= nil then
                            point:onEnter()
                        end
                    elseif point.onExit ~= nil then
                        point:onExit()
                    end
                end

                if inside == true then
                    nearby[#nearby+1] = point
                    if distance < closestDistance then
                        closestDistance = distance
                        closest = point
                    end
                end
            end

            if closest ~= nil then
                closest.isClosest = true
            end

            closestPoint = closest
            nearbyPoints = nearby

            if #nearby > 0 then
                ensureTick()
            end

            Wait(300)
        end

        nearbyPoints = {}
        closestPoint = nil
        checkRunning = false
    end)
end

---@param options REC_Library.Lib.Point.Options
---@return REC_Library.Lib.Point
function points.new(options)

    assert(type(options) == "table", "options must be a table")
    assert(type(options.coords) == "vector3", "options.coords must be a vector3")

    nextId += 1

    local point = options --[[@as REC_Library.Lib.Point]]
    point.id = nextId
    point.distance = options.distance or 2.0
    point.currentDistance = math.huge
    point.isClosest = false
    point.inside = false
    point.remove = remove

    registry[nextId] = point

    ensureCheck()

    return point
end

---@return table<integer, REC_Library.Lib.Point>
function points.getAllPoints()
    return registry
end

---@return REC_Library.Lib.Point[]
function points.getNearbyPoints()
    return nearbyPoints
end

---@return REC_Library.Lib.Point|nil
function points.getClosestPoint()
    return closestPoint
end

lib.points = points
