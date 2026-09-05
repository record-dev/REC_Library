
---[[
---     command (shared)
---     Turns the raw argument list of a command into a table keyed by param name,
---     converting and validating each one the way properties.params describes.
---]]

---@class REC_Library.Lib.Command.Param
---@field name string
---@field help? string
---@field type? "number" | "playerId" | "string" | "longString"
---@field optional? boolean

---@class REC_Library.Lib.Command.Properties
---@field help? string
---@field params? REC_Library.Lib.Command.Param[]
---@field restricted? boolean | string | string[]

---@class REC_Library.Lib.Command
local command = {}

---@param source integer
---@param message string
function command.reject(source, message)

    if source == 0 then
        print(("^1%s^0"):format(message))
        return
    end

    TriggerClientEvent("chat:addMessage", source, {
        color = { 255, 80, 80, },
        args = { "SYSTEM", message, },
    })
end

---[[
---     nil when a param is invalid, the player was already told why
---]]
---@param source integer
---@param args string[]
---@param raw string
---@param params? REC_Library.Lib.Command.Param[]
---@return table<string | integer, any>|nil
function command.parseArguments(source, args, raw, params)

    if params == nil then
        return args
    end

    ---@type table<string | integer, any>
    local parsed = {}

    for i = 1, #params do

        local param = params[i]
        local value = args[i]
        local paramType = param.type

        if paramType == "number" then
            value = tonumber(value)

        elseif paramType == "playerId" then
            if value == "me" then
                value = source
            else
                value = tonumber(value)
                if value ~= nil and lib.context == "server" and GetPlayerName(value) == nil then
                    value = nil
                end
            end

        elseif paramType == "longString" and i == #params then
            if value ~= nil then
                local position = raw:find(value, 1, true)
                value = position ~= nil and raw:sub(position) or value
            end
        end

        if value == nil and param.optional ~= true then
            command.reject(source, ("command '%s' requires the argument '%s' (%s)"):format(
                raw:match("^/?(%S+)") or raw,
                param.name,
                paramType or "string"
            ))
            return nil
        end

        parsed[i] = value
        parsed[param.name] = value
    end

    return parsed
end

---@param commandName string
---@param properties? REC_Library.Lib.Command.Properties
---@return { name: string, help: string, params?: { name: string, help: string }[] }
function command.suggestion(commandName, properties)

    ---@type { name: string, help: string }[]|nil
    local params

    if properties ~= nil and properties.params ~= nil then
        params = {}
        for i, param in ipairs(properties.params) do
            params[i] = { name = param.name, help = param.help or "", }
        end
    end

    return {
        name = "/" .. commandName,
        help = properties ~= nil and properties.help or "",
        params = params,
    }
end

lib._command = command
