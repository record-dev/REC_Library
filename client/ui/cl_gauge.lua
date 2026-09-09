
---[[
---     Gauge (a value between 0 and max drawn as a bar or a ring)
---     Several can be on screen at once, each one addressed by its id.
---     Lua remembers every gauge so isGaugeOpen and a NUI reboot work, and only sends
---     what changed so a caller may push the value from a tight loop.
---]]

---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"
local gaugeCfg = shCfg.ui.gauge

---@type REC_Library.Shared.Enums
local shEnums = require "@REC_Library.shared.sh_enums"

---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@type REC_Library.Client.UI.Text
local text = require "@REC_Library.client.ui.cl_text"

---@class REC_Library.Lib.Gauge.Data
---@field id? string same id updates the gauge in place, omitted ids are generated
---@field value? number 0 to max, default 0
---@field max? number default 1.0
---@field label? string text drawn above the bar
---@field icon? string font awesome class
---@field color? string fill colour (defaults to config.ui.gauge.color)
---@field position? REC_Library.Shared.Enums.HelpTextPosition
---@field shape? REC_Library.Lib.Gauge.Shape default "bar"
---@field variant? REC_Library.Lib.Gauge.Variant "card" (default) draws the themed box, "plain" only the bar and the wording like the native DrawRect meter
---@field width? string CSS width of a bar (defaults to config.ui.gauge.width)
---@field showValue? boolean draw the percentage next to the label
---@field hideWhenEmpty? boolean keep the gauge registered but off screen while the value is 0

---@class REC_Library.Lib.Gauge.Patch
---@field value? number
---@field max? number
---@field label? string
---@field icon? string
---@field color? string
---@field showValue? boolean
---@field hideWhenEmpty? boolean

---@alias REC_Library.Lib.Gauge.Shape "bar" | "ring"
---@alias REC_Library.Lib.Gauge.Variant "card" | "plain"

---@class REC_Library.Lib.Gauge.Entry
---@field id string
---@field percent integer 0 to 100
---@field label string|nil
---@field icon string|nil
---@field color string
---@field position REC_Library.Shared.Enums.HelpTextPosition
---@field shape REC_Library.Lib.Gauge.Shape
---@field variant REC_Library.Lib.Gauge.Variant
---@field width string|nil
---@field showValue boolean
---@field hideWhenEmpty boolean

---@type table<string, true>
local validPositions = (function ()
    local positions = {}
    for _, position in pairs(shEnums.HelpTextPosition) do
        positions[position] = true
    end
    return positions
end)()

---@type table<string, true>
local validShapes = { bar = true, ring = true, }

---@type table<string, true>
local validVariants = { card = true, plain = true, }

---@type table<string, { entry: REC_Library.Lib.Gauge.Entry, max: number }>
local gauges = {}

---@type string[]
local order = {}

---@param value any
---@param max number
---@return integer
local function toPercent(value, max)

    local number = tonumber(value) or 0.0
    local clamped = math.min(math.max(number, 0.0), max)

    return math.floor(clamped / max * 100 + 0.5)
end

---@param value any
---@param fallback number
---@return number
local function toMax(value, fallback)

    local number = tonumber(value)
    if number == nil or number <= 0 then
        return fallback
    end

    return number
end

---@param value any
---@param fallback boolean
---@return boolean
local function toFlag(value, fallback)

    if value == nil then
        return fallback
    end

    return value == true
end

---@param id string
local function forget(id)

    gauges[id] = nil

    for index, key in ipairs(order) do
        if key == id then
            table.remove(order, index)
            return
        end
    end
end

---[[
---     shape the data into what the NUI expects
---]]
---@param data REC_Library.Lib.Gauge.Data
---@return REC_Library.Lib.Gauge.Entry
---@return number max
local function build(data)

    assert(type(data) == "table", "data must be a table")

    local max = toMax(data.max, 1.0)

    return {
        id            = type(data.id) == "string" and data.id or text:generateId(),
        percent       = toPercent(data.value, max),
        label         = type(data.label) == "string" and data.label or nil,
        icon          = type(data.icon) == "string" and data.icon or nil,
        color         = type(data.color) == "string" and data.color or gaugeCfg.color,
        position      = validPositions[data.position] == true and data.position or gaugeCfg.position,
        shape         = validShapes[data.shape] == true and data.shape or "bar",
        variant       = validVariants[data.variant] == true and data.variant or "card",
        width         = type(data.width) == "string" and data.width or nil,
        showValue     = data.showValue == true,
        hideWhenEmpty = data.hideWhenEmpty == true,
    }, max
end

---@param a REC_Library.Lib.Gauge.Entry
---@param b REC_Library.Lib.Gauge.Entry
---@return boolean
local function same(a, b)
    return a.percent == b.percent
        and a.label == b.label
        and a.icon == b.icon
        and a.color == b.color
        and a.position == b.position
        and a.shape == b.shape
        and a.variant == b.variant
        and a.width == b.width
        and a.showValue == b.showValue
        and a.hideWhenEmpty == b.hideWhenEmpty
end



---[[
---     show a gauge, the same id replaces the one on screen
---]]
---@param data REC_Library.Lib.Gauge.Data
---@return string id
function lib.showGauge(data)

    local entry, max = build(data)
    local previous = gauges[entry.id]

    gauges[entry.id] = { entry = entry, max = max, }

    if previous == nil then
        order[#order+1] = entry.id
    end

    if previous ~= nil and same(previous.entry, entry) == true then
        return entry.id
    end

    nui:send("gauge", entry)

    return entry.id
end

---[[
---     change the value or the look of a gauge that is on screen
---     nothing is sent when the change does not move the drawn percentage
---]]
---@param id string
---@param patch REC_Library.Lib.Gauge.Patch | number a number is taken as the value
---@return boolean
function lib.updateGauge(id, patch)

    local gauge = gauges[id]
    if gauge == nil then
        utils:debugPrint(("^3gauge is not founded... id: %s^0"):format(tostring(id)))
        return false
    end

    if type(patch) == "number" then
        patch = { value = patch, }
    end

    assert(type(patch) == "table", "patch must be a table or a number")

    local previous = gauge.entry
    local max = toMax(patch.max, gauge.max)

    ---@type REC_Library.Lib.Gauge.Entry
    local entry = {
        id            = id,
        percent       = patch.value ~= nil and toPercent(patch.value, max) or previous.percent,
        label         = type(patch.label) == "string" and patch.label or previous.label,
        icon          = type(patch.icon) == "string" and patch.icon or previous.icon,
        color         = type(patch.color) == "string" and patch.color or previous.color,
        position      = previous.position,
        shape         = previous.shape,
        variant       = previous.variant,
        width         = previous.width,
        showValue     = toFlag(patch.showValue, previous.showValue),
        hideWhenEmpty = toFlag(patch.hideWhenEmpty, previous.hideWhenEmpty),
    }

    gauge.entry = entry
    gauge.max = max

    if same(previous, entry) == true then
        return true
    end

    nui:send("gauge", entry)

    return true
end

---[[
---     dismiss a gauge, without an id every gauge goes
---]]
---@param id? string
---@return boolean
function lib.hideGauge(id)

    if id == nil then

        if next(gauges) == nil then
            return false
        end

        gauges = {}
        order = {}
        nui:send("hideGauge", {})

        return true
    end

    if gauges[id] == nil then
        utils:debugPrint(("^3gauge is not founded... id: %s^0"):format(tostring(id)))
        return false
    end

    forget(id)
    nui:send("hideGauge", { id = id, })

    return true
end

---[[
---     whether a gauge is on screen, without an id whether any is
---]]
---@param id? string
---@return boolean isOpen
---@return string[] ids
function lib.isGaugeOpen(id)

    local ids = {}
    for index, key in ipairs(order) do
        ids[index] = key
    end

    if id ~= nil then
        return gauges[id] ~= nil, ids
    end

    return #ids > 0, ids
end

-- the NUI just booted, send every gauge again in the order they were shown
nui:onReady(function ()
    for _, id in ipairs(order) do
        nui:send("gauge", gauges[id].entry)
    end
end)

RegisterNetEvent("REC_Library:showGauge", lib.showGauge)
RegisterNetEvent("REC_Library:updateGauge", lib.updateGauge)
RegisterNetEvent("REC_Library:hideGauge", lib.hideGauge)

exports("showGauge", lib.showGauge)
exports("updateGauge", lib.updateGauge)
exports("hideGauge", lib.hideGauge)
exports("isGaugeOpen", lib.isGaugeOpen)
