Run the menu runtime and builder checks from the resource root with Lua 5.4:

```sh
lua tests/menu.lua
```

FiveM exports, NUI callbacks, resource ownership, and focus are stubbed. The checks exercise the production builders, menu class, and Lua runtime, including callable FiveM function references. Native controller input and actual cross-resource serialization still require an in-game check.

For a browser preview, run `npm run dev` in `web/`, open `?mock=1`, and press **menu**. The preview supports navigation and value changes; submenu routing and application callbacks run in Lua and require FiveM.
