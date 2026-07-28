
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.UI.HelpText
---@field info REC_Library.Client.Class.UI.HelpTextConfigBuilder
local HelpText = {}
HelpText.__index = HelpText

---instantiation
---@param config REC_Library.Client.Class.UI.HelpTextConfigBuilder
---@return self
function HelpText:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Draw
---@return boolean
function HelpText:draw()
    local info = self.info

    -- Check if drawing is in progress
    if info.hasDrawing == true then
        utils:debugPrint("HelpText is already being drawn.")
        return false
    end

    -- Set drawing flag
    info.hasDrawing = true

    BeginTextCommandDisplayHelp("THREESTRINGS")

    -- Setting the characters to draw
    for _, helpText in ipairs(info.args) do
        AddTextComponentSubstringPlayerName(helpText)
    end

    EndTextCommandDisplayHelp(0, false, true, info.duration)

    -- Set drawing flag
    info.hasDrawing = false

    return true
end

---@param args string[]
function HelpText:setArgs(args)
    self.info.args = args
end

return HelpText
