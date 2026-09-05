
---[[
---     vehicleProperties (client)
---     The property table is the same shape ox_lib produced, so rows stored by the
---     old builds still apply.
---]]

---@class REC_Library.Lib.VehicleProperties
---@field model integer
---@field plate string
---@field plateIndex integer
---@field bodyHealth number
---@field engineHealth number
---@field tankHealth number
---@field fuelLevel number
---@field oilLevel number
---@field dirtLevel number
---@field paintType1 integer
---@field paintType2 integer
---@field color1 integer | integer[]
---@field color2 integer | integer[]
---@field pearlescentColor integer
---@field interiorColor integer
---@field dashboardColor integer
---@field wheelColor integer
---@field wheelWidth number
---@field wheelSize number
---@field wheels integer
---@field windowTint integer
---@field xenonColor integer
---@field neonEnabled boolean[]
---@field neonColor integer[]
---@field extras table<integer, 0 | 1>
---@field tyreSmokeColor integer[]
---@field modSpoilers integer
---@field modFrontBumper integer
---@field modRearBumper integer
---@field modSideSkirt integer
---@field modExhaust integer
---@field modFrame integer
---@field modGrille integer
---@field modHood integer
---@field modFender integer
---@field modRightFender integer
---@field modRoof integer
---@field modEngine integer
---@field modBrakes integer
---@field modTransmission integer
---@field modHorns integer
---@field modSuspension integer
---@field modArmor integer
---@field modNitrous integer
---@field modTurbo boolean
---@field modSubwoofer boolean
---@field modSmokeEnabled boolean
---@field modHydraulics boolean
---@field modXenon boolean
---@field modFrontWheels integer
---@field modBackWheels integer
---@field modCustomTiresF boolean
---@field modCustomTiresR boolean
---@field modPlateHolder integer
---@field modVanityPlate integer
---@field modTrimA integer
---@field modOrnaments integer
---@field modDashboard integer
---@field modDial integer
---@field modDoorSpeaker integer
---@field modSeats integer
---@field modSteeringWheel integer
---@field modShifterLeavers integer
---@field modAPlate integer
---@field modSpeakers integer
---@field modTrunk integer
---@field modHydrolic integer
---@field modEngineBlock integer
---@field modAirFilter integer
---@field modStruts integer
---@field modArchCover integer
---@field modAerials integer
---@field modTrimB integer
---@field modTank integer
---@field modWindows integer
---@field modDoorR integer
---@field modLivery integer
---@field modRoofLivery integer
---@field modLightbar integer
---@field windows integer[]
---@field doors integer[]
---@field tyres table<integer, 1 | 2>
---@field bulletProofTyres boolean
---@field driftTyres boolean

---@param vehicle integer
---@return integer[]
local function getNeonColour(vehicle)
    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    return { r, g, b, }
end

---@param vehicle integer
---@return integer[]
local function getTyreSmokeColour(vehicle)
    local r, g, b = GetVehicleTyreSmokeColor(vehicle)
    return { r, g, b, }
end

---@param vehicle integer
---@return REC_Library.Lib.VehicleProperties|nil
function lib.getVehicleProperties(vehicle)

    if DoesEntityExist(vehicle) == false then
        return nil
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local paintType1, paintType2 = GetVehicleModColor_1(vehicle), GetVehicleModColor_2(vehicle)
    local damage = { windows = {}, doors = {}, tyres = {}, }
    local windows = 0

    for i = 0, 7 do
        if IsVehicleWindowIntact(vehicle, i) == false then
            windows += 1
            damage.windows[windows] = i
        end
    end

    local doors = 0
    for i = 0, 5 do
        if IsVehicleDoorDamaged(vehicle, i) ~= false then
            doors += 1
            damage.doors[doors] = i
        end
    end

    for i = 0, 7 do
        if IsVehicleTyreBurst(vehicle, i, false) ~= false then
            damage.tyres[i] = IsVehicleTyreBurst(vehicle, i, true) ~= false and 2 or 1
        end
    end

    local neons = {}
    for i = 1, 4 do
        neons[i] = IsVehicleNeonLightEnabled(vehicle, i - 1) ~= false
    end

    local extras = {}
    for i = 1, 15 do
        if DoesExtraExist(vehicle, i) ~= false then
            extras[i] = IsVehicleExtraTurnedOn(vehicle, i) ~= false and 0 or 1
        end
    end

    local modLivery = GetVehicleMod(vehicle, 48)
    if modLivery == -1 then
        modLivery = GetVehicleLivery(vehicle)
    end

    if GetIsVehiclePrimaryColourCustom(vehicle) ~= false then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        colorPrimary = { r, g, b, }
    end

    if GetIsVehicleSecondaryColourCustom(vehicle) ~= false then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        colorSecondary = { r, g, b, }
    end

    return {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = math.floor(GetVehicleBodyHealth(vehicle) + 0.5),
        engineHealth = math.floor(GetVehicleEngineHealth(vehicle) + 0.5),
        tankHealth = math.floor(GetVehiclePetrolTankHealth(vehicle) + 0.5),
        fuelLevel = math.floor(GetVehicleFuelLevel(vehicle) + 0.5),
        oilLevel = math.floor(GetVehicleOilLevel(vehicle) + 0.5),
        dirtLevel = math.floor(GetVehicleDirtLevel(vehicle) + 0.5),
        paintType1 = paintType1,
        paintType2 = paintType2,
        color1 = colorPrimary,
        color2 = colorSecondary,
        pearlescentColor = pearlescentColor,
        interiorColor = GetVehicleInteriorColor(vehicle),
        dashboardColor = GetVehicleDashboardColour(vehicle),
        wheelColor = wheelColor,
        wheelWidth = GetVehicleWheelWidth(vehicle),
        wheelSize = GetVehicleWheelSize(vehicle),
        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenonColor = GetVehicleXenonLightsColor(vehicle),
        neonEnabled = neons,
        neonColor = getNeonColour(vehicle),
        extras = extras,
        tyreSmokeColor = getTyreSmokeColour(vehicle),
        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),
        modNitrous = GetVehicleMod(vehicle, 17),
        modTurbo = IsToggleModOn(vehicle, 18) ~= false,
        modSubwoofer = IsToggleModOn(vehicle, 19) ~= false,
        modSmokeEnabled = IsToggleModOn(vehicle, 20) ~= false,
        modHydraulics = IsToggleModOn(vehicle, 21) ~= false,
        modXenon = IsToggleModOn(vehicle, 22) ~= false,
        modFrontWheels = GetVehicleMod(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modCustomTiresF = GetVehicleModVariation(vehicle, 23) ~= false,
        modCustomTiresR = GetVehicleModVariation(vehicle, 24) ~= false,
        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modDoorR = GetVehicleMod(vehicle, 47),
        modLivery = modLivery,
        modRoofLivery = GetVehicleRoofLivery(vehicle),
        modLightbar = GetVehicleMod(vehicle, 49),
        windows = damage.windows,
        doors = damage.doors,
        tyres = damage.tyres,
        bulletProofTyres = GetVehicleTyresCanBurst(vehicle) == false,
        driftTyres = GetDriftTyresEnabled(vehicle) ~= false,
    }
end

---@param vehicle integer
---@param props REC_Library.Lib.VehicleProperties
---@param fixVehicle? boolean
---@return boolean
function lib.setVehicleProperties(vehicle, props, fixVehicle)

    if DoesEntityExist(vehicle) == false then
        print(("^3vehicle %s does not exist...^0"):format(tostring(vehicle)))
        return false
    end

    if NetworkGetEntityIsNetworked(vehicle) ~= false and NetworkHasControlOfEntity(vehicle) == false then
        print(("^3cannot set the properties of a vehicle this client does not control... vehicle: %s^0"):format(tostring(vehicle)))
        return false
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    SetVehicleModKit(vehicle, 0)
    SetVehicleAutoRepairDisabled(vehicle, true)

    if props.extras ~= nil then
        for id, disable in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(id) --[[@as integer]], disable == 1)
        end
    end

    if props.plate ~= nil then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end

    if props.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end

    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end

    if props.engineHealth ~= nil then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end

    if props.tankHealth ~= nil then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end

    if props.fuelLevel ~= nil then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end

    if props.oilLevel ~= nil then
        SetVehicleOilLevel(vehicle, props.oilLevel + 0.0)
    end

    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end

    if props.paintType1 ~= nil then
        SetVehicleModColor_1(vehicle, props.paintType1, 0, 0)
    end

    if props.paintType2 ~= nil then
        SetVehicleModColor_2(vehicle, props.paintType2, 0)
    end

    if props.color1 ~= nil then
        if type(props.color1) == "number" then
            ClearVehicleCustomPrimaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1, colorSecondary)
        else
            SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
        end
    end

    if props.color2 ~= nil then
        if type(props.color2) == "number" then
            ClearVehicleCustomSecondaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
        else
            SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
        end
    end

    if props.pearlescentColor ~= nil or props.wheelColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor or wheelColor)
    end

    if props.interiorColor ~= nil then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColour(vehicle, props.dashboardColor)
    end

    if props.wheels ~= nil then
        SetVehicleWheelType(vehicle, props.wheels)
    end

    if props.wheelSize ~= nil then
        SetVehicleWheelSize(vehicle, props.wheelSize)
    end

    if props.wheelWidth ~= nil then
        SetVehicleWheelWidth(vehicle, props.wheelWidth)
    end

    if props.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        for i = 1, 4 do
            SetVehicleNeonLightEnabled(vehicle, i - 1, props.neonEnabled[i] == true)
        end
    end

    if props.neonColor ~= nil then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    if props.xenonColor ~= nil then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end

    if props.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    ---@type table<string, integer>
    local mods = {
        modSpoilers = 0, modFrontBumper = 1, modRearBumper = 2, modSideSkirt = 3, modExhaust = 4,
        modFrame = 5, modGrille = 6, modHood = 7, modFender = 8, modRightFender = 9, modRoof = 10,
        modEngine = 11, modBrakes = 12, modTransmission = 13, modHorns = 14, modSuspension = 15,
        modArmor = 16, modNitrous = 17, modFrontWheels = 23, modBackWheels = 24, modPlateHolder = 25,
        modVanityPlate = 26, modTrimA = 27, modOrnaments = 28, modDashboard = 29, modDial = 30,
        modDoorSpeaker = 31, modSeats = 32, modSteeringWheel = 33, modShifterLeavers = 34,
        modAPlate = 35, modSpeakers = 36, modTrunk = 37, modHydrolic = 38, modEngineBlock = 39,
        modAirFilter = 40, modStruts = 41, modArchCover = 42, modAerials = 43, modTrimB = 44,
        modTank = 45, modWindows = 46, modDoorR = 47, modLightbar = 49,
    }

    for key, modType in pairs(mods) do
        if props[key] ~= nil then
            local variation = (modType == 23 and props.modCustomTiresF == true) or (modType == 24 and props.modCustomTiresR == true)
            SetVehicleMod(vehicle, modType, props[key], variation)
        end
    end

    ---@type table<string, integer>
    local toggles = {
        modTurbo = 18, modSubwoofer = 19, modSmokeEnabled = 20, modHydraulics = 21, modXenon = 22,
    }

    for key, modType in pairs(toggles) do
        if props[key] ~= nil then
            ToggleVehicleMod(vehicle, modType, props[key] == true)
        end
    end

    if props.modLivery ~= nil then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.modRoofLivery ~= nil then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props.windows ~= nil then
        for _, window in ipairs(props.windows) do
            SmashVehicleWindow(vehicle, window)
        end
    end

    if props.doors ~= nil then
        for _, door in ipairs(props.doors) do
            SetVehicleDoorBroken(vehicle, door, true)
        end
    end

    if props.tyres ~= nil then
        for tyre, state in pairs(props.tyres) do
            SetVehicleTyreBurst(vehicle, tonumber(tyre) --[[@as integer]], state == 2, 1000.0)
        end
    end

    if props.bulletProofTyres ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.bulletProofTyres == false)
    end

    if props.driftTyres ~= nil then
        SetDriftTyresEnabled(vehicle, props.driftTyres == true)
    end

    if fixVehicle == true then
        SetVehicleFixed(vehicle)
    end

    return true
end
