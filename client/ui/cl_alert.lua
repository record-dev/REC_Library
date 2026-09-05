
---[[
---     Alert dialog
---     Blocks until the player answers, "confirm" or "cancel".
---]]

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@class REC_Library.Lib.Alert.Data
---@field header string
---@field content string
---@field centered? boolean
---@field cancel? boolean shows the cancel button
---@field size? "xs" | "sm" | "md" | "lg" | "xl"
---@field labels? { confirm?: string, cancel?: string }

---@type promise|nil
local active = nil

---@param result "confirm" | "cancel"
local function resolve(result)

    local p = active
    if p == nil then
        return
    end

    active = nil
    nui:focus("alert", false)
    p:resolve(result)
end

---@param data REC_Library.Lib.Alert.Data
---@return "confirm" | "cancel"
function lib.alertDialog(data)

    assert(type(data) == "table", "data must be a table")

    -- a dialog that is still open loses to the new one
    resolve("cancel")

    local p = promise.new()
    active = p

    nui:focus("alert", true)
    nui:send("alert", {
        header = data.header,
        content = data.content,
        centered = data.centered,
        cancel = data.cancel,
        size = data.size,
        labels = data.labels,
    })

    return Citizen.Await(p)
end

function lib.closeAlertDialog()
    nui:send("closeAlert")
    resolve("cancel")
end

---@param data { result: string }
RegisterNUICallback("alertClose", function (data, cb)
    cb(1)
    resolve(data.result == "confirm" and "confirm" or "cancel")
end)

exports("alertDialog", lib.alertDialog)
exports("closeAlertDialog", lib.closeAlertDialog)
