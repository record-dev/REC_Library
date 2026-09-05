
---[[
---     Text UI
---     A small hint box that stays on screen until hidden.
---]]

---@type REC_Library.Client.UI.Nui
local nui = require "@REC_Library.client.ui.cl_nui"

---@class REC_Library.Lib.TextUI.Options
---@field position? "right-center" | "left-center" | "top-center" | "bottom-center"
---@field icon? string
---@field iconColor? string
---@field iconAnimation? string
---@field alignIcon? "top" | "center"
---@field style? table<string, string> inline css

---@type boolean
local isOpen = false

---@type string|nil
local currentText = nil

---@param text string
---@param options? REC_Library.Lib.TextUI.Options
function lib.showTextUI(text, options)

    assert(type(text) == "string", "text must be a string")

    if isOpen == true and currentText == text then
        return
    end

    isOpen = true
    currentText = text

    options = options or {}

    nui:send("textUI", {
        text = text,
        position = options.position,
        icon = options.icon,
        iconColor = options.iconColor,
        iconAnimation = options.iconAnimation,
        alignIcon = options.alignIcon,
        style = options.style,
    })
end

function lib.hideTextUI()

    if isOpen == false then
        return
    end

    isOpen = false
    currentText = nil

    nui:send("hideTextUI")
end

---@return boolean isOpen
---@return string|nil text
function lib.isTextUIOpen()
    return isOpen, currentText
end

exports("showTextUI", lib.showTextUI)
exports("hideTextUI", lib.hideTextUI)
exports("isTextUIOpen", lib.isTextUIOpen)
