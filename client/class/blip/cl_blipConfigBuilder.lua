---@class REC_Library.Client.Class.Blip.BlipConfigBuilder
---@field id number
---@field name string
---@field sprite number
---@field coords vector3
---@field color number
---@field scale number
---@field alpha number
---@field display number
---@field flashesDuration? integer
---@field visible boolean
---@field isFlashes boolean
---@field isShortRange boolean
local BlipConfigBuilder = {}
BlipConfigBuilder.__index = BlipConfigBuilder

---Default BlipId == 1
---@param name string
---@param coords vector3
function BlipConfigBuilder:new(name, coords)
    assert(name and type(name) == "string")
    assert(coords and type(coords) == "vector3")
    local instance = setmetatable({}, self)
    instance.id = nil
    instance.name = name
    instance.coords = coords
    instance.sprite = 0
    instance.color = nil
    instance.scale = nil
    instance.alpha = 255
    instance.display = nil
    instance.priority = nil
    instance.visible = true
    instance.isFlashes = false
    instance.isShortRange = false
    return instance
end

---@param sprite number|nil https://docs.fivem.net/docs/game-references/blips/
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setSprite(sprite)
    if sprite == nil then return self end
    assert(type(sprite) == "number" and sprite >= 0)
    self.sprite = sprite return self
end

---@param color number|nil https://docs.fivem.net/docs/game-references/blips/#blip-colors
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setColor(color)
    if color == nil then return self end
    assert(type(color) == "number" and color >= 0)
    self.color = color return self
end

---@param scale number|nil recomanded 0.6-0.8
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setScale(scale)
    if scale == nil then return self end
    assert(type(scale) == "number" and scale >= 0)
    self.scale = scale return self
end

---@param alpha number|nil recomanded 0-255
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setAlpha(alpha)
    if alpha == nil then return self end
    assert(type(alpha) == "number" and alpha >= 0 and alpha <= 255)
    self.alpha = alpha return self
end

---@param display number|nil https://docs.fivem.net/natives/?_0x9029B2F3DA924928
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setDisplay(display)
    if display == nil then return self end
    assert(type(display) == "number" and display >= 0 and display <= 10)
    self.display = display return self
end

---@param priority number|nil
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setPriority(priority)
    if priority == nil then return self end
    assert(type(priority) == "number")
    self.priority = priority return self
end

---@param visible boolean|nil
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setVisible(visible)
    if visible == nil then return self end
    assert(type(visible) == "boolean")
    self.visible = visible return self
end

---@param category number|nil
---@param entryKey string|nil
---@param entryText string|nil
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setCategory(category, entryKey, entryText)
    if category == nil or entryKey == nil or entryText == nil then return self end
    assert(type(category) == "number")
    assert(type(entryKey) == "string")
    assert(type(entryText) == "string")
    self.category = {
        id = category,
        entryKey = entryKey,
        entryText = entryText
    }
    return self
end

---@param isFlashes boolean|nil
---@param duration? integer
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setIsFlashes(isFlashes, duration)
    if isFlashes == nil then return self end
    assert(type(isFlashes) == "boolean")
    if duration ~= nil then
        assert(type(duration) == "number", "duration must be a number|integer")
        self.flashesDuration = duration
    end
    self.isFlashes = isFlashes return self
end

---@param isShortRange boolean|nil
---@return self BlipConfigBuilder method chain
function BlipConfigBuilder:setIsShortRange(isShortRange)
    if isShortRange == nil then return self end
    assert(type(isShortRange) == "boolean")
    self.isShortRange = isShortRange return self
end

---Build
---@return table
function BlipConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return BlipConfigBuilder
