
---[[
---     command (client)
---]]

local command = lib._command

---@param commandName string | string[]
---@param properties? REC_Library.Lib.Command.Properties
---@param cb fun(source: integer, args: table<string | integer, any>, raw: string)
function lib.addCommand(commandName, properties, cb)

    assert(type(cb) == "function", "cb must be a function")

    if type(commandName) == "string" then
        commandName = { commandName, }
    end

    local params = properties ~= nil and properties.params or nil

    ---@param source integer
    ---@param args string[]
    ---@param raw string
    local function handler(source, args, raw)

        local parsed = command.parseArguments(source, args, raw, params)
        if parsed == nil then
            return
        end

        cb(source, parsed, raw)
    end

    for _, name in ipairs(commandName) do

        RegisterCommand(name, handler, false)

        local suggestion = command.suggestion(name, properties)
        TriggerEvent("chat:addSuggestion", suggestion.name, suggestion.help, suggestion.params)
    end
end
