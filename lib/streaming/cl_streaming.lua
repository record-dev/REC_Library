
---[[
---     streaming (client)
---     Every request waits until the asset is loaded, nil after timeout.
---]]

---@generic T
---@param request fun(asset: T)
---@param hasLoaded fun(asset: T): boolean
---@param assetType string
---@param asset T
---@param timeout? integer
---@return T|nil
local function streamingRequest(request, hasLoaded, assetType, asset, timeout)

    if hasLoaded(asset) ~= false then
        return asset
    end

    request(asset)

    local deadline = GetGameTimer() + (timeout or 10000)
    while hasLoaded(asset) == false do

        if GetGameTimer() > deadline then
            print(("^3failed to load %s '%s' in time...^0"):format(assetType, tostring(asset)))
            return nil
        end

        Wait(0)
    end

    return asset
end

---@param model integer | string
---@param timeout? integer
---@return integer|nil
function lib.requestModel(model, timeout)

    local hash = type(model) == "string" and joaat(model) or model

    if IsModelValid(hash) == false and IsModelInCdimage(hash) == false then
        print(("^3model '%s' is invalid...^0"):format(tostring(model)))
        return nil
    end

    return streamingRequest(RequestModel, HasModelLoaded, "model", hash, timeout)
end

---@param dict string
---@param timeout? integer
---@return string|nil
function lib.requestAnimDict(dict, timeout)

    if DoesAnimDictExist(dict) == false then
        print(("^3anim dict '%s' does not exist...^0"):format(dict))
        return nil
    end

    return streamingRequest(RequestAnimDict, HasAnimDictLoaded, "animDict", dict, timeout)
end

---@param animSet string
---@param timeout? integer
---@return string|nil
function lib.requestAnimSet(animSet, timeout)
    return streamingRequest(RequestAnimSet, HasAnimSetLoaded, "animSet", animSet, timeout)
end

---@param asset string
---@param timeout? integer
---@return string|nil
function lib.requestNamedPtfxAsset(asset, timeout)
    return streamingRequest(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, "ptfxAsset", asset, timeout)
end

---@param bank string
---@param timeout? integer
---@return string|nil
function lib.requestAudioBank(bank, timeout)
    return streamingRequest(function (name)
        RequestScriptAudioBank(name, false)
    end, function (name)
        return RequestScriptAudioBank(name, false)
    end, "audioBank", bank, timeout)
end

---@param scaleformName string
---@param timeout? integer
---@return integer|nil
function lib.requestScaleformMovie(scaleformName, timeout)

    local scaleform = RequestScaleformMovie(scaleformName)

    local deadline = GetGameTimer() + (timeout or 10000)
    while HasScaleformMovieLoaded(scaleform) == false do

        if GetGameTimer() > deadline then
            print(("^3failed to load scaleform '%s' in time...^0"):format(scaleformName))
            return nil
        end

        Wait(0)
    end

    return scaleform
end

---@param weaponType integer | string
---@param timeout? integer
---@param weaponResourceFlags? integer
---@param extraWeaponComponentFlags? integer
---@return integer|nil
function lib.requestWeaponAsset(weaponType, timeout, weaponResourceFlags, extraWeaponComponentFlags)

    local hash = type(weaponType) == "string" and joaat(weaponType) or weaponType

    return streamingRequest(function (asset)
        RequestWeaponAsset(asset, weaponResourceFlags or 31, extraWeaponComponentFlags or 0)
    end, HasWeaponAssetLoaded, "weaponAsset", hash, timeout)
end

---@param dict string
---@param timeout? integer
---@return string|nil
function lib.requestStreamedTextureDict(dict, timeout)
    return streamingRequest(function (name)
        RequestStreamedTextureDict(name, false)
    end, HasStreamedTextureDictLoaded, "textureDict", dict, timeout)
end
