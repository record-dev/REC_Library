
---@type REC_Library.Client.Class.UI.MenuConfigBuilder
local MenuConfigBuilder = require "@REC_Library.client.class.ui.cl_menuConfigBuilder"

---@class REC_Library.Client.Class.UI.Menu
---@field info REC_Library.Client.Class.UI.MenuConfigBuilder
---@field registered boolean
---@field keybind? REC_Library.Lib.Keybind
local Menu = {}
Menu.__index = Menu

---@param config REC_Library.Client.Class.UI.MenuConfigBuilder
---@return self
function Menu:new(config)
    MenuConfigBuilder.build(config)
    local instance = setmetatable({}, self)
    instance.info, instance.registered = config, false
    return instance
end

---@return boolean
function Menu:register()
    self.registered = lib.registerMenu(MenuConfigBuilder.build(self.info))
    return self.registered
end

---@return boolean
function Menu:open()
    if self.registered == false and self:register() == false then return false end
    return lib.showMenu(self.info.id)
end

---@return boolean
function Menu:close()
    if self:isOpen() == false then return false end
    return lib.hideMenu()
end

---@return boolean
function Menu:isOpen()
    return lib.getOpenMenu() == self.info.id
end

---@param itemId string
---@return REC_Library.Lib.Menu.Value|nil
function Menu:getValue(itemId)
    return lib.getMenuValue(self.info.id, itemId)
end

---@param itemId string
---@param patch table
---@return boolean
function Menu:updateItem(itemId, patch)
    return lib.updateMenuItem(self.info.id, itemId, patch)
end

---@param itemId string
---@param value REC_Library.Lib.Menu.Value
---@return boolean
function Menu:setValue(itemId, value)
    return self:updateItem(itemId, { value = value, })
end

---@param defaultKey string
---@param description? string
---@return self
function Menu:openWith(defaultKey, description)
    assert(type(defaultKey) == "string", "defaultKey must be a string")
    if self.keybind ~= nil then
        self.keybind:disable(false)
        return self
    end
    self.keybind = lib.addKeybind({
        name = ("%s:menu:%s"):format(GetCurrentResourceName(), self.info.id),
        description = description or self.info.title,
        defaultKey = defaultKey,
        onPressed = function ()
            if self:isOpen() == true then self:close() else self:open() end
        end,
    })
    return self
end

---@return boolean
function Menu:destroy()
    local removed = lib.unregisterMenu(self.info.id)
    self.registered = false
    if self.keybind ~= nil then self.keybind:disable(true) end
    return removed
end

return Menu
