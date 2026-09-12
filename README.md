
## Documentation
https://docs.re-cord.dev/en/common-dependencies/rec_library
## Menu UI

A MenuV-style menu is available alongside context menus and dialogs. It has a banner, subtitle, selected-row description, scrolling, and button, checkbox, choice slider, numeric range, confirmation, submenu, and label rows. Keyboard arrows navigate/change values, Enter selects, and Escape/Backspace returns to the parent or closes the root. Mouse controls and gamepad D-pad/A/B are also supported.

The implementation uses REC_Library's existing React NUI. MenuV's Lua menu/item objects, event handling, NUI serialization, and selection logic were studied in the local `menuv/source/` files. No MenuV runtime dependency, Vue bundle, fonts, or texture assets are needed. This is a new REC_Library API; existing `MenuV:CreateMenu` calls must be adapted.

### In-game sample commands

- `/rl-menu` opens a builder-based sample covering all seven item types, a submenu, disabled rows, and scrolling. Callback results appear in a subtitle and the result row. Values persist when reopened.
- `/rl-menuclose` closes the sample, including its submenu.

In the submenu, select the checkbox action to try `Menu:setValue()` and return with Escape to see the parent update. The sample lives in `client/cl_main.test.lua` alongside the existing `rl-*` test commands. Restart REC_Library after adding the commands.

### Builder example

Use labels from the calling resource's locales. `locales` in this example refers to that resource's loaded locale table.

```lua
---@type REC_Library.Client.API
local clApi = require "@REC_Library.client.cl_api"
local ui = clApi.Class.UI

local optionsConfig = ui.MenuConfigBuilder:new("options", locales.options)
    :addItem(ui.MenuItemConfigBuilder:new("volume", locales.volume, "range")
        :setRange(0, 100, 5)
        :setValue(50)
        :setOnChange(function (value, oldValue, args, id)
            -- Apply the new volume here.
        end))

local optionsMenu = ui.Menu:new(optionsConfig)
optionsMenu:register()

local menuConfig = ui.MenuConfigBuilder:new("vehicle", locales.vehicle)
    :setSubtitle(locales.settings)
    :setPosition("top-right")
    :setColor("#00ff88")
    :setVisibleItems(8)
    :addItem(ui.MenuItemConfigBuilder:new("start", locales.startEngine)
        :setIcon("car")
        :setDescription(locales.startEngineDescription)
        :setOnSelect(function (value, args, id)
            -- Start the engine here.
        end))
    :addItem(ui.MenuItemConfigBuilder:new("lights", locales.lights, "checkbox")
        :setValue(false)
        :setOnChange(function (value, oldValue, args, id)
            -- Apply the boolean value here.
        end))
    :addItem(ui.MenuItemConfigBuilder:new("mode", locales.mode, "slider")
        :setValues({
            { label = locales.normal, value = "normal", },
            { label = locales.sport, value = "sport", description = locales.sportDescription, },
        })
        :setValue("normal"))
    :addItem(ui.MenuItemConfigBuilder:new("options", locales.options, "submenu")
        :setMenu("options"))

local menu = ui.Menu:new(menuConfig)
menu:openWith("F6")
-- menu:open() also works without a keybind.
```

Pass the builder directly to `Menu:new`. IDs are scoped to the calling resource. Register child menus before opening their parent; returning restores the parent's selection. Cyclic submenu links are ignored. Empty menus and menus with only disabled/label rows can still be closed.

### Configuration and callbacks

| Builder | Methods |
| --- | --- |
| MenuConfigBuilder | `setTitle`, `setSubtitle`, `setPosition`, `setColor`, `setBanner`, `setWidth`, `setVisibleItems`, `setCanClose`, `addItem` |
| MenuConfigBuilder events | `setOnOpen(fn)`, `setOnClose(fn(reason))`, `setOnBack(fn)`, `setOnSwitch(fn(id, previousId))` |
| MenuItemConfigBuilder | `setType`, `setLabel`, `setDescription`, `setIcon`, `setValue`, `setValues`, `setRange(min, max, step)`, `setMenu`, `setDisabled`, `setCloseOnSelect`, `setArgs` |
| MenuItemConfigBuilder events | `setOnSelect(fn(value, args, id))`, `setOnChange(fn(value, oldValue, args, id))` |

Setters return the builder. Optional setters ignore `nil`; supplied values are validated. `build()` returns a validated copy if a plain table is needed. `color` is `#RRGGBB`, `width` is 240–800 pixels (default 380), and `visibleItems` is 1–20 (default 8). `banner` is an optional image URL, including a caller-provided NUI asset URL. Nine positions are supported: `top-left`, `top-center`, `top-right`, `left-center`, `center`, `right-center`, `bottom-left`, `bottom-center`, `bottom-right`.

Checkbox selection toggles its boolean and runs change/select callbacks. Choice sliders wrap through distinct string/number/boolean values. Numeric ranges clamp at the bounds and use the configured step. Confirmation rows choose Yes/No with Left/Right and submit that boolean on Enter; the caller decides what each answer does. A label is display-only. Buttons stay open unless `setCloseOnSelect(true)` is used.

`onOpen` runs when a menu opens or a parent is restored. `onBack` runs on the child before returning. `onClose` runs when the visible menu closes, with `exit`, `hidden`, `select`, `replaced`, or `removed`; entering a submenu is not a close. Resource stops discard callbacks and release focus. Another REC_Library dialog/context menu temporarily suspends this menu's input until its focus is released.

### Runtime API

| Class method | Behavior |
| --- | --- |
| `menu:register()` | Register or replace the full configuration from `menu.info`. Replacement resets values from that configuration. |
| `menu:open()` | Register on first use, then open. Later opens retain runtime values. |
| `menu:close()` / `menu:isOpen()` | Close/query this instance's menu. |
| `menu:getValue(itemId)` | Read the current value, including `false`. |
| `menu:setValue(itemId, value)` | Validate and update a value without firing callbacks. |
| `menu:updateItem(itemId, patch)` | Update fields such as `label`, `disabled`, `values`, or callbacks. Item IDs stay fixed. |
| `menu:openWith(key, description)` | Register a configurable keyboard binding once; returns the menu. |
| `menu:destroy()` | Unregister and disable the instance's keybind. |

Equivalent client `lib.*` functions and exports are `registerMenu(config)`, `showMenu(id)`, `hideMenu()`, `getOpenMenu()`, `unregisterMenu(id)`, `getMenuValue(id, itemId)`, and `updateMenuItem(id, itemId, patch)`. `registerMenu` accepts a builder or a plain table with `id`, `title`, and `items`. `canClose = false` blocks user exit, while programmatic close/destroy still work. Updates are authoritative in Lua and do not modify the original builder; re-register to replace the complete menu or clear optional fields.

The NUI receives display fields and a session token; callbacks and application arguments remain in Lua. Stale sessions, disabled rows, unknown IDs, and invalid change directions are rejected. Gamepad controls follow the [Cfx control map](https://docs.fivem.net/docs/game-references/controls/), and cross-resource callback validation supports [Cfx function references](https://github.com/citizenfx/fivem/blob/master/data/shared/citizen/scripting/lua/scheduler.lua).

See [tests/README.md](tests/README.md) for the Lua checks and browser preview.
