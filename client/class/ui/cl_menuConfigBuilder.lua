
---@type REC_Library.Client.Class.UI.MenuItemConfigBuilder
local MenuItemConfigBuilder = require "@REC_Library.client.class.ui.cl_menuItemConfigBuilder"

---@alias REC_Library.Lib.Menu.Position "top-left" | "top-center" | "top-right" | "left-center" | "center" | "right-center" | "bottom-left" | "bottom-center" | "bottom-right"

---@class REC_Library.Client.Class.UI.MenuConfigBuilder
---@field id string
---@field title string
---@field subtitle? string
---@field position? REC_Library.Lib.Menu.Position
---@field color? string
---@field banner? string image URL
---@field visibleItems? integer
---@field width? integer
---@field canClose? boolean
---@field items REC_Library.Client.Class.UI.MenuItemConfigBuilder[]
---@field onOpen? fun()
---@field onClose? fun(reason: string)
---@field onBack? fun()
---@field onSwitch? fun(id: string, previousId: string|nil)
local MenuConfigBuilder = {}
MenuConfigBuilder.__index = MenuConfigBuilder

---@param id string
---@param title string
---@return self
function MenuConfigBuilder:new(id, title)
    assert(type(id) == "string" and id ~= "", "menu.id must be a non-empty string")
    assert(type(title) == "string", "menu.title must be a string")
    local instance = setmetatable({}, self)
    instance.id, instance.title, instance.items = id, title, {}
    return instance
end

---@param value? string
---@return self
function MenuConfigBuilder:setTitle(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid title")
    self.title = value
    return self
end

---@param value? string
---@return self
function MenuConfigBuilder:setSubtitle(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid subtitle")
    self.subtitle = value
    return self
end

---@param value? REC_Library.Lib.Menu.Position
---@return self
function MenuConfigBuilder:setPosition(value)
    if value == nil then return self end
    assert(({ ["top-left"] = true, ["top-center"] = true, ["top-right"] = true, ["left-center"] = true, center = true, ["right-center"] = true, ["bottom-left"] = true, ["bottom-center"] = true, ["bottom-right"] = true, })[value] == true, "invalid position")
    self.position = value
    return self
end

---@param value? string
---@return self
function MenuConfigBuilder:setColor(value)
    if value == nil then return self end
    assert(type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil, "invalid color")
    self.color = value
    return self
end

---@param value? string
---@return self
function MenuConfigBuilder:setBanner(value)
    if value == nil then return self end
    assert(type(value) == "string", "invalid banner")
    self.banner = value
    return self
end

---@param value? integer
---@return self
function MenuConfigBuilder:setVisibleItems(value)
    if value == nil then return self end
    assert(type(value) == "number" and value % 1 == 0 and value >= 1 and value <= 20, "invalid visibleItems")
    self.visibleItems = value
    return self
end

---@param value? integer
---@return self
function MenuConfigBuilder:setWidth(value)
    if value == nil then return self end
    assert(type(value) == "number" and value % 1 == 0 and value >= 240 and value <= 800, "invalid width")
    self.width = value
    return self
end

---@param value? boolean
---@return self
function MenuConfigBuilder:setCanClose(value)
    if value == nil then return self end
    assert(type(value) == "boolean", "invalid canClose")
    self.canClose = value
    return self
end

---@param value? fun()
---@return self
function MenuConfigBuilder:setOnOpen(value)
    if value == nil then return self end
    assert(type(value) == "function" or (type(value) == "table" and type(rawget(value, "__cfx_functionReference")) == "string"), "invalid onOpen")
    self.onOpen = value
    return self
end

---@param value? fun(reason: string)
---@return self
function MenuConfigBuilder:setOnClose(value)
    if value == nil then return self end
    assert(type(value) == "function" or (type(value) == "table" and type(rawget(value, "__cfx_functionReference")) == "string"), "invalid onClose")
    self.onClose = value
    return self
end

---@param value? fun()
---@return self
function MenuConfigBuilder:setOnBack(value)
    if value == nil then return self end
    assert(type(value) == "function" or (type(value) == "table" and type(rawget(value, "__cfx_functionReference")) == "string"), "invalid onBack")
    self.onBack = value
    return self
end

---@param value? fun(id: string, previousId: string|nil)
---@return self
function MenuConfigBuilder:setOnSwitch(value)
    if value == nil then return self end
    assert(type(value) == "function" or (type(value) == "table" and type(rawget(value, "__cfx_functionReference")) == "string"), "invalid onSwitch")
    self.onSwitch = value
    return self
end

---@param item REC_Library.Client.Class.UI.MenuItemConfigBuilder
---@return self
function MenuConfigBuilder:addItem(item)
    assert(type(item) == "table", "item must be a builder or table")
    for _, existing in ipairs(self.items) do
        assert(existing.id ~= item.id, "item ids must be unique")
    end
    self.items[#self.items+1] = item
    return self
end

---@return REC_Library.Client.Class.UI.MenuConfigBuilder
function MenuConfigBuilder:build()
    local result = MenuConfigBuilder:new(self.id, self.title)
    result:setSubtitle(self.subtitle):setPosition(self.position):setColor(self.color):setBanner(self.banner)
        :setVisibleItems(self.visibleItems):setWidth(self.width):setCanClose(self.canClose)
        :setOnOpen(self.onOpen):setOnClose(self.onClose):setOnBack(self.onBack):setOnSwitch(self.onSwitch)
    assert(type(self.items) == "table", "menu.items must be a table")
    for _, item in ipairs(self.items) do
        result:addItem(MenuItemConfigBuilder.build(item))
    end
    local config = {}
    for key, value in pairs(result) do config[key] = value end
    return config
end

return MenuConfigBuilder
