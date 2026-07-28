
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.UI.Subtitle
---@field info REC_Library.Client.Class.UI.SubtitleConfigBuilder
local Subtitle = {}
Subtitle.__index = Subtitle

---instantiation
---@param config REC_Library.Client.Class.UI.SubtitleConfigBuilder
---@return self
function Subtitle:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Subtitle drawing
---@return boolean
function Subtitle:draw()
    local info = self.info

    -- Check if drawing is in progress
    if info.isDrawing == true then
        utils:debugPrint("[Subtitle:draw] is already drawing")
        return false
    end

    -- Set drawing flag
    info.isDrawing = true

    BeginTextCommandPrint(info.textEntry)
    AddTextComponentSubstringPlayerName(info.text)
    EndTextCommandPrint(info.duration, true)

    -- Fold drawing flag
    info.isDrawing = false

    return true
end

return Subtitle
