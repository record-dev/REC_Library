
---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"



---[[
---     Print the detected integrations once at startup, detected again after the other resources had a chance to start
---]]
-- wait for the ensures of server.cfg, resources after REC_Library are not started yet here
CreateThread(function ()
    Wait(0)

    local detected = shCfg.detect()
    -- plain print on purpose: always shown regardless of debugMode
    print("^5[REC_Library] detected integrations^0")

    for _, category in ipairs(shCfg.detectCategories) do
        local info = detected[category]
        if info == nil then
            goto continue
        end

        if info.resource == nil then
            print(("^3[REC_Library] %-12s %-10s (not detected)^0"):format(category, info.value))
            goto continue
        end

        print(("^2[REC_Library] %-12s %-10s (%s)^0"):format(category, info.value, info.resource))

        ::continue::
    end
end)
