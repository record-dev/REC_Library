
local callbacks, handlers, messages, modules = {}, {}, {}, {}
local invoking = "resource_a"
local readyHandler
local nui = { focused = false, blocked = false, }
function nui:send(action, data) messages[#messages+1] = { action = action, data = data, } end
function nui:focus(_, toggle) self.focused = toggle end
function nui:isOnlyFocus() return self.focused == true and self.blocked == false end
function nui:onReady(handler) readyHandler = handler end
modules["@REC_Library.client.ui.cl_nui"] = nui
modules["@REC_Library.client.cl_utils"] = { debugPrint = function () end, }
local sounds = {}
modules["@REC_Library.shared.sh_config"] = { ui = { menu = {
    color = "#8feb61", keepInput = true,
    sounds = { open = { name = "open", set = "test", }, navigate = { name = "navigate", set = "test", }, change = { name = "change", set = "test", }, select = { name = "select", set = "test", }, back = { name = "back", set = "test", }, close = false, },
}, }, }
function PlaySoundFrontend(_, name) sounds[#sounds+1] = name end

function require(name)
    if modules[name] ~= nil then return modules[name] end
    local path = name:gsub("^@REC_Library%.", ""):gsub("%.", "/") .. ".lua"
    local module = assert(loadfile(path))()
    modules[name] = module
    return module
end
function GetInvokingResource() return invoking end
function GetCurrentResourceName() return "REC_Library" end
function RegisterNUICallback(name, handler) callbacks[name] = handler end
function AddEventHandler(name, handler) handlers[name] = handler end
function CreateThread() end
function exports() end
lib = {}

---@type REC_Library.Client.Class.UI.MenuItemConfigBuilder
local Item = require "@REC_Library.client.class.ui.cl_menuItemConfigBuilder"
---@type REC_Library.Client.Class.UI.MenuConfigBuilder
local Config = require "@REC_Library.client.class.ui.cl_menuConfigBuilder"
---@type REC_Library.Client.Class.UI.Menu
local Menu = require "@REC_Library.client.class.ui.cl_menu"
assert(loadfile("client/ui/cl_menu.lua"))()

local passed = 0
local function check(condition, message)
    assert(condition, message)
    passed = passed + 1
end
local function fails(callback, message)
    local ok = pcall(callback)
    check(ok == false, message)
end
local function snapshot()
    for i = #messages, 1, -1 do
        if messages[i].action == "showMenu" then return messages[i].data end
    end
end
local function action(kind, id, direction, token)
    local acknowledged = false
    callbacks.menuAction({ token = token or snapshot().token, action = kind, item = id, direction = direction, }, function () acknowledged = true end)
    check(acknowledged, "NUI request must be acknowledged")
end

local changes, selections, lastValue, closes, switches = 0, 0, nil, {}, 0
local function onChange(value)
    changes = changes + 1
    lastValue = value
end
local ref = setmetatable({ __cfx_functionReference = "test-ref", }, { __call = function (_, ...) onChange(...) end, })
local config = Config:new("main", "Menu")
    :setCanClose(false)
    :setOnClose(function (reason) closes[#closes+1] = reason end)
    :setOnSwitch(function () switches = switches + 1 end)
    :addItem(Item:new("check", "Check", "checkbox"):setValue(false):setOnChange(ref))
    :addItem(Item:new("slider", "Choice", "slider"):setValues({ { label = "No", value = false, }, { label = "Yes", value = true, }, }):setValue(false):setOnChange(onChange))
    :addItem(Item:new("range", "Range", "range"):setRange(0, 1, 0.1):setValue(0.9):setOnChange(onChange))
    :addItem(Item:new("confirm", "Confirm", "confirm"):setOnSelect(function (value) selections = selections + 1 lastValue = value end))
    :addItem(Item:new("disabled", "Disabled"):setDisabled(true):setOnSelect(function () error("must never run") end))
    :addItem(Item:new("label", "Label", "label"))
    :addItem(Item:new("child", "Child", "submenu"):setMenu("child"))
local child = Config:new("child", "Child"):addItem(Item:new("cycle", "Cycle", "submenu"):setMenu("main"))
local built = config:build()
check(built.items[1].value == false, "false must survive the builder")
check(built.items[2].value == false, "false choice must survive the builder")
check(built.items ~= config.items, "build must copy items")
fails(function () Item:new("x", "X", "invalid") end, "invalid item type")
fails(function () Item:new("x", "X", "slider"):setValues({}):build() end, "empty choices")
fails(function () Item:new("x", "X", "slider"):setValues({ { label = "A", value = 1, }, }):setValue(2):build() end, "unknown choice")
fails(function () Item:new("x", "X", "range"):setRange(2, 1) end, "reversed range")
fails(function () Item:new("x", "X"):setValue(0 / 0) end, "NaN")
fails(function () Item:new("x", "X"):setOnSelect({}) end, "invalid callback")
fails(function () config:addItem(Item:new("check", "Duplicate")) end, "duplicate id")
fails(function () Config:new("x", "X"):setPosition("invalid") end, "invalid position")

lib.registerMenu(config)
lib.registerMenu(child)
check(lib.showMenu("missing") == false, "unknown menu")
check(lib.showMenu("main") == true and nui.focused == true, "open owns focus")
check(snapshot().color == "#8feb61" and sounds[#sounds] == "open", "config colour and open sound")
check(snapshot().items[1].onChange == nil and snapshot().items[1].args == nil, "callbacks stay in Lua")
action("select", "check")
check(changes == 1 and lastValue == true, "checkbox invokes exported callable ref")
check(sounds[#sounds] == "select", "select sound")
action("select", "check")
check(lib.getMenuValue("main", "check") == false, "checkbox toggles back to false")
action("change", "slider", -1)
check(lastValue == true and sounds[#sounds] == "change", "slider wraps backwards")
action("change", "slider", 1)
check(lib.getMenuValue("main", "slider") == false, "slider wraps to false value")
action("change", "range", 1)
action("change", "range", 1)
check(lib.getMenuValue("main", "range") == 1, "range clamps upper bound")
for _ = 1, 15 do action("change", "range", -1) end
check(lib.getMenuValue("main", "range") == 0, "range clamps lower bound")
action("change", "confirm", 1)
check(selections == 0, "confirm change does not submit")
action("select", "confirm")
check(selections == 1 and lastValue == true, "confirm submits selected boolean")
local previous = changes
action("change", "range", 100)
action("select", "disabled")
action("select", "label")
action("select", "unknown")
check(changes == previous and selections == 1, "invalid actions rejected")
action("hover", "slider")
check(switches == 1 and sounds[#sounds] == "navigate", "selection callback")
local played = #sounds
action("hover", "slider")
action("change", "range", 100)
action("back")
action("close")
check(lib.getOpenMenu() == "main" and #sounds == played, "canClose blocks user exit, rejected actions stay silent")
local oldToken = snapshot().token
check(lib.updateMenuItem("main", "check", { disabled = true, }) == true, "live item update")
action("select", "check", nil, oldToken)
check(changes == previous, "stale revision rejected")
action("select", "child")
check(lib.getOpenMenu() == "child" and snapshot().canBack == true, "submenu opens")
action("select", "cycle")
check(lib.getOpenMenu() == "child", "submenu cycles rejected")
action("back")
check(lib.getOpenMenu() == "main" and snapshot().selected == "child" and sounds[#sounds] == "back", "parent selection restored")
nui.blocked = true
action("change", "slider", 1)
check(lib.getMenuValue("main", "slider") == false, "other focus owner pauses input")
nui.blocked = false
readyHandler()
check(snapshot().id == "main" and nui.focused == true, "NUI reload restores state")

invoking = "resource_b"
lib.registerMenu(Config:new("main", "Other"))
check(lib.getOpenMenu() == nil and lib.hideMenu() == false, "resources cannot close each other's menu")
check(lib.getMenuValue("main", "check") == nil, "resources cannot read each other's values")
lib.showMenu("main")
check(snapshot().title == "Other" and closes[#closes] == "replaced", "same ids are scoped per resource")
invoking = "resource_a"
check(lib.unregisterMenu("main") == true and nui.focused == true, "removing inactive menu preserves another resource's focus")
handlers.onClientResourceStop("resource_b")
check(nui.focused == false, "resource stop releases focus")

local instance = Menu:new(Config:new("instance", "Instance"):addItem(Item:new("value", "Value", "checkbox")))
check(instance:open() and instance:isOpen(), "class registers on first open")
check(instance:setValue("value", true) and instance:getValue("value") == true, "class updates values")
instance:close()
instance:open()
check(instance:getValue("value") == true, "reopen preserves runtime values")
check(instance:destroy() and instance:isOpen() == false and nui.focused == false, "destroy releases focus")
local replacedConfig = Config:new("reentrant", "Reentrant")
    :setOnClose(function () lib.showMenu("winner") end)
lib.registerMenu(replacedConfig)
lib.registerMenu(Config:new("winner", "Winner"))
lib.registerMenu(Config:new("loser", "Loser"))
lib.showMenu("reentrant")
check(lib.showMenu("loser") == false and lib.getOpenMenu() == "winner", "onClose re-entry must not be overwritten")
lib.hideMenu()
lib.registerMenu(Config:new("error", "Error"):setOnOpen(function () error("callback failure") end))
check(lib.showMenu("error") == true, "callback errors do not abort opening")
check(lib.hideMenu() == true and nui.focused == false, "callback errors do not leak focus")
lib.registerMenu(Config:new("parent", "Parent"):addItem(Item:new("child", "Child", "submenu"):setMenu("remover")))
lib.registerMenu(Config:new("remover", "Remover"):setOnBack(function () lib.unregisterMenu("parent") end))
lib.showMenu("parent")
action("select", "child")
action("back")
check(lib.getOpenMenu() == nil and nui.focused == false, "onBack cannot restore an unregistered parent")

print(("menu: %d checks passed"):format(passed))
