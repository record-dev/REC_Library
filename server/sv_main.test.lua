
---@type REC_Library.Server.Config
local svCfg = require "@REC_Library.server.sv_config"

---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

-- only enabled in debug mode
if svCfg.debugMode == false then
    return
end

---[[
---     Debug commands that drive the client UI from the server
---     From the server console pass a playerId, in game "me" or nothing means yourself
---     /rl-sv-helptext [playerId] [duration]
---     /rl-sv-helptextclear [playerId]
---     /rl-sv-subtitle [playerId] [duration]
---     /rl-sv-subtitleclear [playerId]
---     /rl-sv-notify [playerId] [type]
---     /rl-sv-ui [playerId]  (everything at once)
---]]

---@type REC_Library.Lib.Command.Param
local playerParam = { name = "playerId", help = "target player (me / server id, defaults to yourself)", type = "playerId", optional = true, }

---@type REC_Library.Lib.Command.Param
local durationParam = { name = "duration", help = "display time in ms (omit for the default, 0 keeps it until cleared)", type = "number", optional = true, }

---@type string[]
local notifyTypes = { "inform", "success", "warning", "error", }

---[[
---     the player the UI goes to, the console has to name one
---]]
---@param src integer
---@param playerId integer|nil
---@return integer|nil
local function resolveTarget(src, playerId)

    if playerId ~= nil then
        return playerId
    end

    if src == 0 then
        utils:debugPrint("^3playerId is required from the console...^0")
        return nil
    end

    return src
end



---[[
---     help text
---]]
lib.addCommand("rl-sv-helptext", {
    help = "Show a test help text on a client (debug)",
    params = { playerParam, durationParam, },
}, function (src, args)

    local playerId = resolveTarget(src, args.playerId)
    if playerId == nil then
        return
    end

    lib.showHelpText(playerId, {
        text     = { "~INPUT_CONTEXT~ Interact", "~INPUT_FRONTEND_CANCEL~ ~r~Cancel~s~", },
        icon     = "circle-info",
        duration = args.duration,
    })

    utils:debugPrint(("^2sent help text... playerId: %d^0"):format(playerId))
end)

lib.addCommand("rl-sv-helptextclear", {
    help = "Clear the help text on a client (debug)",
    params = { playerParam, },
}, function (src, args)

    local playerId = resolveTarget(src, args.playerId)
    if playerId == nil then
        return
    end

    lib.hideHelpText(playerId)
end)

---[[
---     subtitle
---]]
lib.addCommand("rl-sv-subtitle", {
    help = "Show a test subtitle on a client (debug)",
    params = { playerParam, durationParam, },
}, function (src, args)

    local playerId = resolveTarget(src, args.playerId)
    if playerId == nil then
        return
    end

    lib.showSubtitle(playerId, {
        text     = "Get to the ~y~marked location~s~ before the timer runs out.",
        name     = "REC_Library",
        duration = args.duration,
    })

    utils:debugPrint(("^2sent subtitle... playerId: %d^0"):format(playerId))
end)

lib.addCommand("rl-sv-subtitleclear", {
    help = "Clear the subtitle on a client (debug)",
    params = { playerParam, },
}, function (src, args)

    local playerId = resolveTarget(src, args.playerId)
    if playerId == nil then
        return
    end

    lib.hideSubtitle(playerId)
end)

---[[
---     notify
---]]
lib.addCommand("rl-sv-notify", {
    help = "Show a test notification on a client (debug)",
    params = {
        playerParam,
        { name = "type", help = "inform / success / warning / error (omit for every type)", optional = true, },
    },
}, function (src, args)

    local playerId = resolveTarget(src, args.playerId)
    if playerId == nil then
        return
    end

    local types = args.type ~= nil and { args.type, } or notifyTypes

    CreateThread(function ()

        for _, notifyType in ipairs(types) do
            lib.notify(playerId, {
                type         = notifyType,
                title        = "REC_Library",
                description  = ("This is a %s notification."):format(notifyType),
                duration     = 5000,
                showDuration = true,
                sound        = { set = "HUD_FRONTEND_DEFAULT_SOUNDSET", name = "SELECT", },
            })

            Citizen.Wait(150)
        end
    end)
end)

---[[
---     everything at once, to see how the overlays sit together
---]]
lib.addCommand("rl-sv-ui", {
    help = "Show the help text, the subtitle and a notification on a client (debug)",
    params = { playerParam, },
}, function (src, args)

    local playerId = resolveTarget(src, args.playerId)
    if playerId == nil then
        return
    end

    lib.showHelpText(playerId, {
        text     = { "~INPUT_CONTEXT~ Interact", "~INPUT_FRONTEND_CANCEL~ ~r~Cancel~s~", },
        icon     = "circle-info",
        duration = 8000,
    })

    lib.showSubtitle(playerId, {
        text     = "Get to the ~y~marked location~s~ before the timer runs out.",
        name     = "REC_Library",
        duration = 8000,
    })

    lib.notify(playerId, {
        type         = "success",
        title        = "REC_Library",
        description  = "Help text, subtitle and notify are all up.",
        duration     = 8000,
        showDuration = true,
        sound        = { set = "HUD_FRONTEND_DEFAULT_SOUNDSET", name = "SELECT", },
    })

    utils:debugPrint(("^2sent every overlay... playerId: %d^0"):format(playerId))
end)
