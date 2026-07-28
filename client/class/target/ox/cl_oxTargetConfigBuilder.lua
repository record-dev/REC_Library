
---@class REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder
---@field label string
---@field icon string
---@field iconColor? string
---@field distance? number
---@field bones? string|string[]
---@field offset? vector3
---@field offsetAbsolute? vector3
---@field groups? string|string[]|table<string, number>
---@field items? string|string[]|table<string, number>
---@field anyItem? boolean
---@field canInteract? fun(...)
---@field menuName? string
---@field openMenu? string
---@field onSelect? fun(...)
---@field export? string
---@field event? string
---@field serverEvent? string
---@field command? string
local OXTargetConfigBuilder = {}
OXTargetConfigBuilder.__index = OXTargetConfigBuilder

---instantiation
---@param label string Label when interacting
---@return self OXTargetConfigBuilder
function OXTargetConfigBuilder:new(label)
    local instance = setmetatable({}, self)
    assert(type(label) == "string")
    instance.label = label
    instance.icon = "fa-regular fa-circle-question"
    return instance
end

---Method chain
---@param name string
---@return self
function OXTargetConfigBuilder:setName(name)
    if name == nil then return self end
    assert(type(name) == "string")
    self.name = name return self
end

---Method chain
---@param event string
---@return self
function OXTargetConfigBuilder:setEvent(event)
    if event == nil then return self end
    assert(type(event) == "string")
    self.event = event return self
end

---Method chain
---@param serverEvent string
---@return self
function OXTargetConfigBuilder:setServerEvent(serverEvent)
    if serverEvent == nil then return self end
    assert(type(serverEvent) == "string")
    self.serverEvent = serverEvent return self
end

---Method chain
---@param icon string https://fontawesome.com/search?ic=free
---@return self
function OXTargetConfigBuilder:setIcon(icon)
    if icon == nil then return self end
    assert(type(icon) == "string")
    self.icon = icon return self
end

---Method chain
---@param iconColor string
---@return self
function OXTargetConfigBuilder:setIconColor(iconColor)
    if iconColor == nil then return self end
    assert(type(iconColor) == "string")
    self.iconColor = iconColor return self
end

---Method chain
---@param distance number
---@return self
function OXTargetConfigBuilder:setDistance(distance)
    if distance == nil then return self end
    assert(type(distance) == "number")
    self.distance = distance return self
end

---Method chain
---@param bones string|string[]
---@return self
function OXTargetConfigBuilder:setBones(bones)
    if bones == nil then return self end
    assert(type(bones) == "string" or type(bones) == "table")
    self.bones = bones return self
end

---Method chain
---@param offset vector3
---@return self
function OXTargetConfigBuilder:setOffset(offset)
    if offset == nil then return self end
    assert(type(offset) == "vector3")
    self.offset = offset return self
end

---Method chain
---@param offsetAbsolute vector3
---@return self
function OXTargetConfigBuilder:setOffsetAbsolute(offsetAbsolute)
    if offsetAbsolute == nil then return self end
    assert(type(offsetAbsolute) == "vector3")
    self.offsetAbsolute = offsetAbsolute return self
end

---Method chain
---@param groups string|string[]|table<string, number>
---@return self
function OXTargetConfigBuilder:setGroups(groups)
    if groups == nil then return self end
    assert(type(groups) == "string" or type(groups) == "table")
    self.groups = groups return self
end

---Method chain
---@param items string|string[]|table<string, number>
---@return self
function OXTargetConfigBuilder:setItems(items)
    if items == nil then return self end
    assert(type(items) == "string" or type(items) == "table")
    self.items = items return self
end

---Method chain
---@param anyItem boolean
---@return self
function OXTargetConfigBuilder:setAnyItem(anyItem)
    if anyItem == nil then return self end
    assert(type(anyItem) == "boolean")
    self.anyItem = anyItem return self
end

---Method chain
---@param canInteract function
---@return self
function OXTargetConfigBuilder:setCanInteract(canInteract)
    if canInteract == nil then return self end
    assert(type(canInteract) == "function")
    self.canInteract = canInteract return self
end

---Method chain
---@param menuName string
---@return self
function OXTargetConfigBuilder:setMenuName(menuName)
    if menuName == nil then return self end
    assert(type(menuName) == "string")
    self.menuName = menuName return self
end

---Method chain
---@param openMenu string
---@return self
function OXTargetConfigBuilder:setOpenMenu(openMenu)
    if openMenu == nil then return self end
    assert(type(openMenu) == "string")
    self.openMenu = openMenu return self
end

---Method chain
---@param onSelect fun(...)
---@return self
function OXTargetConfigBuilder:setOnSelect(onSelect)
    if onSelect == nil then return self end
    assert(type(onSelect) == "function")
    self.onSelect = onSelect return self
end

---Method chain
---@param export string
---@return self
function OXTargetConfigBuilder:setExport(export)
    if export == nil then return self end
    assert(type(export) == "string")
    self.export = export return self
end

---Method chain
---@param command string
---@return self
function OXTargetConfigBuilder:setCommand(command)
    if command == nil then return self end
    assert(type(command) == "string")
    self.command = command return self
end

---Build and return in table format lol
function OXTargetConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return OXTargetConfigBuilder
