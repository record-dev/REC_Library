
---[[
---     Input dialog
---     Blocks until the player submits (a list of values in row order) or cancels (nil).
---]]

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@class REC_Library.Lib.Input.Row
---@field type "input" | "number" | "checkbox" | "select" | "multi-select" | "slider" | "color" | "date" | "time" | "textarea"
---@field label string
---@field description? string
---@field placeholder? string
---@field icon? string
---@field required? boolean
---@field disabled? boolean
---@field default? any
---@field password? boolean input
---@field min? number number / slider / input length
---@field max? number number / slider / input length
---@field step? number number / slider
---@field options? { value: string, label?: string }[] select
---@field clearable? boolean select
---@field searchable? boolean select
---@field autosize? boolean textarea
---@field format? string date, "DD/MM/YYYY" for example
---@field returnString? boolean date, the formatted string instead of the epoch

---@class REC_Library.Lib.Input.Options
---@field allowCancel? boolean default true

---@type promise|nil
local active = nil

---@param values any[]|nil
local function resolve(values)

    local p = active
    if p == nil then
        return
    end

    active = nil
    nui:focus("input", false)
    p:resolve(values)
end

---@param rows (string | REC_Library.Lib.Input.Row)[]
---@return REC_Library.Lib.Input.Row[]
local function normalizeRows(rows)

    local normalized = {}

    for i, row in ipairs(rows) do
        if type(row) == "string" then
            normalized[i] = { type = "input", label = row, }
        else
            normalized[i] = row
        end
    end

    return normalized
end

---@param heading string
---@param rows (string | REC_Library.Lib.Input.Row)[]
---@param options? REC_Library.Lib.Input.Options
---@return any[]|nil
function lib.inputDialog(heading, rows, options)

    assert(type(heading) == "string", "heading must be a string")
    assert(type(rows) == "table", "rows must be a table")

    resolve(nil)

    local p = promise.new()
    active = p

    nui:focus("input", true)
    nui:send("input", {
        heading = heading,
        rows = normalizeRows(rows),
        options = options or {},
    })

    ---@type any[]|nil
    local values = Citizen.Await(p)
    if values == false then
        return nil
    end

    return values
end

function lib.closeInputDialog()
    nui:send("closeInput")
    resolve(false)
end

---@param data { values: any[] | false }
RegisterNUICallback("inputClose", function (data, cb)
    cb(1)
    resolve(type(data.values) == "table" and data.values or false)
end)

exports("inputDialog", lib.inputDialog)
exports("closeInputDialog", lib.closeInputDialog)
