
---[[
---     common (client)
---]]

---[[
---     disableControls
---     lib.disableControls:Add(30, 31) once, then lib.disableControls() every frame.
---]]
---@class REC_Library.Lib.DisableControls
---@overload fun()
lib.disableControls = setmetatable({
    controls = {},
}, {
    __call = function (self)
        for control, count in pairs(self.controls) do
            if count > 0 then
                DisableControlAction(0, control, true)
            end
        end
    end,
})

---@param ... integer
function lib.disableControls:Add(...)
    for _, control in ipairs({ ... }) do
        self.controls[control] = (self.controls[control] or 0) + 1
    end
end

---@param ... integer
function lib.disableControls:Remove(...)
    for _, control in ipairs({ ... }) do
        local count = self.controls[control]
        if count ~= nil then
            self.controls[control] = math.max(0, count - 1)
        end
    end
end

function lib.disableControls:Clear()
    self.controls = {}
end



---[[
---     playAnim
---     Loads the dictionary, plays the clip, and frees the dictionary again.
---]]
---@param entity integer
---@param dict string
---@param clip string
---@param blendInSpeed? number
---@param blendOutSpeed? number
---@param duration? integer
---@param flag? integer
---@param startPhase? number
---@param phaseControlled? boolean
---@param controlFlags? integer
---@param overrideCloneUpdate? boolean
---@return boolean
function lib.playAnim(entity, dict, clip, blendInSpeed, blendOutSpeed, duration, flag, startPhase, phaseControlled, controlFlags, overrideCloneUpdate)

    if lib.requestAnimDict(dict, 2000) == nil then
        return false
    end

    TaskPlayAnim(
        entity, dict, clip,
        blendInSpeed or 8.0, blendOutSpeed or 8.0, duration or -1,
        flag or 0, startPhase or 0.0,
        phaseControlled == true, controlFlags or 0, overrideCloneUpdate == true
    )

    RemoveAnimDict(dict)

    return true
end



---[[
---     raycast
---]]
---@class REC_Library.Lib.Raycast
lib.raycast = {}

---@param handle integer
---@return boolean hit
---@return integer entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return integer materialHash
local function resolveShapeTest(handle)

    local _, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)

    return hit ~= false and hit ~= 0, entityHit, endCoords, surfaceNormal, materialHash
end

---@param coords vector3
---@param destination vector3
---@param flags? integer default 511
---@param ignore? integer default 4
---@return boolean hit
---@return integer entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return integer materialHash
function lib.raycast.fromCoords(coords, destination, flags, ignore)

    local handle = StartShapeTestLosProbe(
        coords.x, coords.y, coords.z,
        destination.x, destination.y, destination.z,
        flags or 511, cache.ped, ignore or 4
    )

    return resolveShapeTest(handle)
end

---@param flags? integer default 511
---@param ignore? integer default 4
---@param distance? number default 10.0
---@return boolean hit
---@return integer entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return integer materialHash
function lib.raycast.fromCamera(flags, ignore, distance)

    local camCoords = GetGameplayCamCoord()
    local camRotation = GetGameplayCamRot(2)

    local pitch = math.rad(camRotation.x)
    local yaw = math.rad(camRotation.z)
    local direction = vector3(-math.sin(yaw) * math.cos(pitch), math.cos(yaw) * math.cos(pitch), math.sin(pitch))
    local destination = camCoords + direction * (distance or 10.0)

    return lib.raycast.fromCoords(camCoords, destination, flags, ignore)
end

lib.raycast.cam = lib.raycast.fromCamera



---[[
---     marker
---]]
---@class REC_Library.Lib.Marker.Options
---@field type integer | string marker id or its name ("CylinderMarker")
---@field coords vector3
---@field width? number
---@field height? number
---@field color? { r: integer, g: integer, b: integer, a?: integer }
---@field direction? vector3
---@field rotation? vector3
---@field bobUpAndDown? boolean
---@field faceCamera? boolean
---@field rotate? boolean
---@field textureDict? string
---@field textureName? string
---@field invertAlpha? boolean

---@class REC_Library.Lib.Marker: REC_Library.Lib.Marker.Options
---@field draw fun(self: REC_Library.Lib.Marker)

---@type table<string, integer>
local markerTypes = {
    UpsideDownCone = 0, VerticalCylinder = 1, ThickChevronUp = 2, ThinChevronUp = 3, CheckeredFlagRect = 4,
    CheckeredFlagCircle = 5, VerticleCircle = 6, PlaneModel = 7, LostMCTransparent = 8, LostMC = 9,
    Number0 = 10, Number1 = 11, Number2 = 12, Number3 = 13, Number4 = 14, Number5 = 15, Number6 = 16,
    Number7 = 17, Number8 = 18, Number9 = 19, ChevronUpx1 = 20, ChevronUpx2 = 21, ChevronUpx3 = 22,
    HorizontalCircleFat = 23, ReplayIcon = 24, HorizontalCircleSkinny = 25, HorizontalCircleSkinny_Arrow = 26,
    HorizontalSplitArrowCircle = 27, DebugSphere = 28, DollarSign = 29, HorizontalBars = 30, WolfHead = 31,
    QuestionMark = 32, PlaneSymbol = 33, HelicopterSymbol = 34, BoatSymbol = 35, CarSymbol = 36,
    MotorcycleSymbol = 37, BikeSymbol = 38, TruckSymbol = 39, ParachuteSymbol = 40, Unknown41 = 41,
    SawbladeSymbol = 42, Unknown43 = 43, CylinderMarker = 1,
}

---@class REC_Library.Lib.MarkerModule
lib.marker = {}

---@param self REC_Library.Lib.Marker
local function drawMarker(self)

    local c = self.color
    local d = self.direction
    local r = self.rotation

    DrawMarker(
        self.type --[[@as integer]],
        self.coords.x, self.coords.y, self.coords.z,
        d.x, d.y, d.z,
        r.x, r.y, r.z,
        self.width, self.width, self.height,
        c.r, c.g, c.b, c.a,
        self.bobUpAndDown == true, self.faceCamera == true, 2, self.rotate == true,
        self.textureDict, self.textureName, self.invertAlpha == true
    )
end

---@param options REC_Library.Lib.Marker.Options
---@return REC_Library.Lib.Marker
function lib.marker.new(options)

    assert(type(options) == "table", "options must be a table")
    assert(type(options.coords) == "vector3", "options.coords must be a vector3")

    local marker = options --[[@as REC_Library.Lib.Marker]]

    if type(options.type) == "string" then
        marker.type = markerTypes[options.type] or 1
    else
        marker.type = options.type or 1
    end

    marker.width = options.width or 2.0
    marker.height = options.height or 1.0
    marker.color = options.color or { r = 0, g = 255, b = 136, a = 100, }
    marker.color.a = marker.color.a or 100
    marker.direction = options.direction or vector3(0.0, 0.0, 0.0)
    marker.rotation = options.rotation or vector3(0.0, 0.0, 0.0)
    marker.draw = drawMarker

    return marker
end
