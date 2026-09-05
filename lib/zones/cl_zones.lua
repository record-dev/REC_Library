
---[[
---     zones (client)
---     lib.zones.sphere / box / poly build a zone that fires onEnter / onExit for
---     the local player and calls inside every frame while the player is in it.
---     One 300ms thread checks every zone of this resource, a per frame thread only
---     runs while a zone needs inside or debug drawing.
---]]

---@class REC_Library.Lib.Zone.Options
---@field coords? vector3 sphere / box center
---@field radius? number sphere
---@field size? vector3 box, full width / length / height
---@field rotation? number | vector3 box, heading in degrees or a full rotation
---@field points? vector3[] poly
---@field thickness? number poly, height around the points
---@field onEnter? fun(self: REC_Library.Lib.Zone)
---@field onExit? fun(self: REC_Library.Lib.Zone)
---@field inside? fun(self: REC_Library.Lib.Zone)
---@field debug? boolean
---@field debugColour? { r: integer, g: integer, b: integer, a?: integer }

---@class REC_Library.Lib.Zone: REC_Library.Lib.Zone.Options
---@field id integer
---@field type "sphere" | "box" | "poly"
---@field insideZone boolean
---@field remove fun(self: REC_Library.Lib.Zone)
---@field contains fun(self: REC_Library.Lib.Zone, coords: vector3): boolean
---@field setDebug fun(self: REC_Library.Lib.Zone, toggle: boolean, colour?: { r: integer, g: integer, b: integer, a?: integer })

---@class REC_Library.Lib.Zones
local zones = {}

---@type table<integer, REC_Library.Lib.Zone>
local registry = {}

---@type integer
local nextId = 0

---@type boolean
local checkRunning = false

---@type boolean
local tickRunning = false

---@type { r: integer, g: integer, b: integer, a: integer }
local defaultColour = { r = 0, g = 255, b = 136, a = 60, }



---[[
---     Geometry
---]]
---@param rotation number | vector3 | nil
---@return number[] 3x3 rotation matrix, row major
local function rotationMatrix(rotation)

    local x, y, z = 0.0, 0.0, 0.0
    if type(rotation) == "number" then
        z = rotation
    elseif type(rotation) == "vector3" then
        x, y, z = rotation.x, rotation.y, rotation.z
    end

    local cx, sx = math.cos(math.rad(x)), math.sin(math.rad(x))
    local cy, sy = math.cos(math.rad(y)), math.sin(math.rad(y))
    local cz, sz = math.cos(math.rad(z)), math.sin(math.rad(z))

    -- Rz * Ry * Rx, the same order the game applies entity rotations
    return {
        cz * cy, cz * sy * sx - sz * cx, cz * sy * cx + sz * sx,
        sz * cy, sz * sy * sx + cz * cx, sz * sy * cx - cz * sx,
        -sy,     cy * sx,                cy * cx,
    }
end

---@param m number[]
---@param v vector3
---@return vector3
local function rotate(m, v)
    return vector3(
        m[1] * v.x + m[2] * v.y + m[3] * v.z,
        m[4] * v.x + m[5] * v.y + m[6] * v.z,
        m[7] * v.x + m[8] * v.y + m[9] * v.z
    )
end

---@param m number[]
---@param v vector3
---@return vector3
local function rotateInverse(m, v)
    return vector3(
        m[1] * v.x + m[4] * v.y + m[7] * v.z,
        m[2] * v.x + m[5] * v.y + m[8] * v.z,
        m[3] * v.x + m[6] * v.y + m[9] * v.z
    )
end

---@param points vector3[]
---@param x number
---@param y number
---@return boolean
local function pointInPolygon(points, x, y)

    local inside = false
    local count = #points
    local j = count

    for i = 1, count do

        local pi, pj = points[i], points[j]
        if (pi.y > y) ~= (pj.y > y) then
            local crossX = (pj.x - pi.x) * (y - pi.y) / (pj.y - pi.y) + pi.x
            if x < crossX then
                inside = not inside
            end
        end

        j = i
    end

    return inside
end



---[[
---     Zone methods
---]]
---@param self REC_Library.Lib.Zone
---@param coords vector3
---@return boolean
local function sphereContains(self, coords)
    return #(coords - self.coords) <= self.radius
end

---@param self REC_Library.Lib.Zone
---@param coords vector3
---@return boolean
local function boxContains(self, coords)

    local localCoords = rotateInverse(self.matrix, coords - self.coords)
    local half = self.size / 2

    return math.abs(localCoords.x) <= half.x
        and math.abs(localCoords.y) <= half.y
        and math.abs(localCoords.z) <= half.z
end

---@param self REC_Library.Lib.Zone
---@param coords vector3
---@return boolean
local function polyContains(self, coords)

    if coords.z < self.minZ or coords.z > self.maxZ then
        return false
    end

    return pointInPolygon(self.points, coords.x, coords.y)
end

---@param self REC_Library.Lib.Zone
local function remove(self)

    registry[self.id] = nil

    if self.insideZone == true then
        self.insideZone = false
        if self.onExit ~= nil then
            self:onExit()
        end
    end
end

---@param self REC_Library.Lib.Zone
---@param toggle boolean
---@param colour? { r: integer, g: integer, b: integer, a?: integer }
local function setDebug(self, toggle, colour)

    self.debug = toggle == true

    if colour ~= nil then
        self.debugColour = colour
    end

    zones._ensureTick()
end



---[[
---     Debug drawing
---]]
---@param self REC_Library.Lib.Zone
local function drawSphere(self)

    local c = self.debugColour or defaultColour
    local coords = self.coords
    local size = self.radius * 2

    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size, size, size, c.r, c.g, c.b, c.a or defaultColour.a, false, false, 2, false, nil, nil, false)
end

---@param a vector3
---@param b vector3
---@param c { r: integer, g: integer, b: integer, a?: integer }
local function drawEdge(a, b, c)
    DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, c.r, c.g, c.b, 255)
end

---[[
---     A translucent quad, drawn from both sides so it never culls away
---]]
---@param a vector3
---@param b vector3
---@param c vector3
---@param d vector3
---@param colour { r: integer, g: integer, b: integer, a?: integer }
local function drawFace(a, b, c, d, colour)

    local alpha = colour.a or defaultColour.a

    DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, colour.r, colour.g, colour.b, alpha)
    DrawPoly(c.x, c.y, c.z, b.x, b.y, b.z, a.x, a.y, a.z, colour.r, colour.g, colour.b, alpha)
    DrawPoly(a.x, a.y, a.z, c.x, c.y, c.z, d.x, d.y, d.z, colour.r, colour.g, colour.b, alpha)
    DrawPoly(d.x, d.y, d.z, c.x, c.y, c.z, a.x, a.y, a.z, colour.r, colour.g, colour.b, alpha)
end

---@param self REC_Library.Lib.Zone
local function drawBox(self)

    local c = self.debugColour or defaultColour
    local half = self.size / 2
    local corners = {}

    for i, sign in ipairs({
        vector3(-1, -1, -1), vector3(1, -1, -1), vector3(1, 1, -1), vector3(-1, 1, -1),
        vector3(-1, -1, 1), vector3(1, -1, 1), vector3(1, 1, 1), vector3(-1, 1, 1),
    }) do
        corners[i] = self.coords + rotate(self.matrix, half * sign)
    end

    for i = 1, 4 do
        local j = i % 4 + 1
        drawEdge(corners[i], corners[j], c)
        drawEdge(corners[i + 4], corners[j + 4], c)
        drawEdge(corners[i], corners[i + 4], c)
        drawFace(corners[i], corners[j], corners[j + 4], corners[i + 4], c)
    end

    drawFace(corners[1], corners[2], corners[3], corners[4], c)
    drawFace(corners[5], corners[6], corners[7], corners[8], c)
end

---@param self REC_Library.Lib.Zone
local function drawPoly(self)

    local c = self.debugColour or defaultColour
    local points = self.points
    local count = #points

    for i = 1, count do

        local j = i % count + 1
        local bottomA = vector3(points[i].x, points[i].y, self.minZ)
        local bottomB = vector3(points[j].x, points[j].y, self.minZ)
        local topA = vector3(points[i].x, points[i].y, self.maxZ)
        local topB = vector3(points[j].x, points[j].y, self.maxZ)

        drawEdge(bottomA, bottomB, c)
        drawEdge(topA, topB, c)
        drawEdge(bottomA, topA, c)
        drawFace(bottomA, bottomB, topB, topA, c)
    end
end



---[[
---     Threads
---]]
---@return boolean
local function needsTick()

    for _, zone in pairs(registry) do
        if zone.debug == true or (zone.inside ~= nil and zone.insideZone == true) then
            return true
        end
    end

    return false
end

function zones._ensureTick()

    if tickRunning == true or needsTick() == false then
        return
    end

    tickRunning = true

    CreateThread(function ()
        while needsTick() == true do

            for _, zone in pairs(registry) do

                if zone.debug == true then
                    zone:draw()
                end

                if zone.inside ~= nil and zone.insideZone == true then
                    zone:inside()
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

            for _, zone in pairs(registry) do

                local inside = zone:contains(coords)
                if inside ~= zone.insideZone then

                    zone.insideZone = inside

                    if inside == true then
                        if zone.onEnter ~= nil then
                            zone:onEnter()
                        end
                        zones._ensureTick()
                    elseif zone.onExit ~= nil then
                        zone:onExit()
                    end
                end
            end

            Wait(300)
        end

        checkRunning = false
    end)
end

---@param zoneType "sphere" | "box" | "poly"
---@param options REC_Library.Lib.Zone.Options
---@param contains fun(self: REC_Library.Lib.Zone, coords: vector3): boolean
---@param draw fun(self: REC_Library.Lib.Zone)
---@return REC_Library.Lib.Zone
local function register(zoneType, options, contains, draw)

    nextId += 1

    local zone = options --[[@as REC_Library.Lib.Zone]]
    zone.id = nextId
    zone.type = zoneType
    zone.insideZone = false
    zone.contains = contains
    zone.draw = draw
    zone.remove = remove
    zone.setDebug = setDebug

    registry[nextId] = zone

    ensureCheck()
    zones._ensureTick()

    return zone
end



---[[
---     Builders
---]]
---@param options REC_Library.Lib.Zone.Options
---@return REC_Library.Lib.Zone
function zones.sphere(options)

    assert(type(options) == "table", "options must be a table")
    assert(type(options.coords) == "vector3", "options.coords must be a vector3")

    options.radius = options.radius or 2.0

    return register("sphere", options, sphereContains, drawSphere)
end

---@param options REC_Library.Lib.Zone.Options
---@return REC_Library.Lib.Zone
function zones.box(options)

    assert(type(options) == "table", "options must be a table")
    assert(type(options.coords) == "vector3", "options.coords must be a vector3")

    options.size = options.size or vector3(2.0, 2.0, 2.0)
    options.matrix = rotationMatrix(options.rotation)

    return register("box", options, boxContains, drawBox)
end

---@param options REC_Library.Lib.Zone.Options
---@return REC_Library.Lib.Zone
function zones.poly(options)

    assert(type(options) == "table", "options must be a table")
    assert(type(options.points) == "table" and #options.points >= 3, "options.points must hold at least 3 points")

    local thickness = options.thickness or 4.0
    local minZ, maxZ = math.huge, -math.huge
    local sumX, sumY = 0.0, 0.0

    for _, point in ipairs(options.points) do
        minZ = math.min(minZ, point.z)
        maxZ = math.max(maxZ, point.z)
        sumX += point.x
        sumY += point.y
    end

    options.thickness = thickness
    options.minZ = minZ - thickness / 2
    options.maxZ = maxZ + thickness / 2
    options.coords = vector3(sumX / #options.points, sumY / #options.points, (minZ + maxZ) / 2)

    return register("poly", options, polyContains, drawPoly)
end

---@return table<integer, REC_Library.Lib.Zone>
function zones.getAllZones()
    return registry
end

---@return table<integer, REC_Library.Lib.Zone>
function zones.getCurrentZones()

    local current = {}
    for id, zone in pairs(registry) do
        if zone.insideZone == true then
            current[id] = zone
        end
    end

    return current
end

lib.zones = zones
