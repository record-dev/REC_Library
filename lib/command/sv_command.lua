
---[[
---     command (server)
---     restricted = true keeps the command behind the command.<name> ace,
---     a string or list of principals is allowed on that ace, false opens it.
---]]

local command = lib._command

---@type { name: string, help: string, params?: { name: string, help: string }[] }[]
local suggestions = {}

---@param commandName string
---@param restricted boolean | string | string[] | nil
local function allowPrincipals(commandName, restricted)

    if type(restricted) == "string" then
        restricted = { restricted, }
    end

    if type(restricted) ~= "table" then
        return
    end

    for _, principal in ipairs(restricted) do
        ExecuteCommand(("add_ace %s command.%s allow"):format(principal, commandName))
    end
end

---@param commandName string | string[]
---@param properties? REC_Library.Lib.Command.Properties
---@param cb fun(source: integer, args: table<string | integer, any>, raw: string)
function lib.addCommand(commandName, properties, cb)

    assert(type(cb) == "function", "cb must be a function")

    if type(commandName) == "string" then
        commandName = { commandName, }
    end

    local restricted = properties ~= nil and properties.restricted or nil
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

        RegisterCommand(name, handler, restricted ~= nil and restricted ~= false)
        allowPrincipals(name, restricted)

        local suggestion = command.suggestion(name, properties)
        suggestions[#suggestions+1] = suggestion
        TriggerClientEvent("chat:addSuggestion", -1, suggestion.name, suggestion.help, suggestion.params)
    end
end

AddEventHandler("playerJoining", function ()

    local src = source --[[@as integer]]

    for _, suggestion in ipairs(suggestions) do
        TriggerClientEvent("chat:addSuggestion", src, suggestion.name, suggestion.help, suggestion.params)
    end
end)
