local inLoop = false
local activeOptions = {}
local activeScript = ''
local zones = {}
local QBCore = exports['qb-core']:GetCoreObject()
local inside = false
local function loop()
    CreateThread(function()
        while inLoop do
            Wait(1)
            if IsControlJustPressed(0, 27) then
                SendNUIMessage({action = 'scroll',    data = -1})
            end
            if IsControlJustPressed(0, 173) then
                SendNUIMessage({action = 'scroll', data = 1})
            end
            if IsControlJustPressed(0, 38) or IsControlJustPressed(0, 18) then
                SendNUIMessage({action = 'select'})
                inLoop = false
            end
            if IsControlJustPressed(0, 322) or IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then
                SendNUIMessage({action = 'hideUI'})
                inLoop = false
            end
        end
    end)
end

local function showUi()
    local labels = {}
    for i = 1, #activeOptions do
        table.insert(labels, {label = activeOptions[i].label})
    end
    SendNUIMessage({
        action = 'setVisible',
        data = labels
    })
    inLoop = true
    loop()
end

RegisterNUICallback('hideUI', function(_, cb)
    cb({})
    SetNuiFocus(false, false)
    inLoop = false
end)

RegisterNUICallback('selectOption', function(data, cb)
    SendNUIMessage({action = 'hideUI'})
    inLoop = false
    local choice = activeOptions[data]
    if not choice then
        cb('')
        return
    end
    if choice and choice.action then
        choice.action()
        return
    end
    if choice and choice.event then
        if not choice.args then
            choice.args = {}
        end
        if choice.type == 'server' then
            TriggerServerEvent(choice.event, table.unpack(choice.args))
        else
            TriggerEvent(choice.event, table.unpack(choice.args))
        end
    end
    cb('')
end)

local function addZones(resource, interact)
    if not interact.height then
        interact.height = 2.0
    end
    zones[resource][interact.name] = BoxZone:Create(vector3(interact.coords.x, interact.coords.y, interact.coords.z), interact.length or 5.0, interact.width or 5.0, {
        name = interact.name,
        heading = interact.heading or interact.coords.w or 180.0,
        debugPoly = interact.debugPoly or false,
        minZ = interact.coords.z - (interact.height / 2),
        maxZ = interact.coords.z + (interact.height / 2),
    })
    zones[resource][interact.name]:onPlayerInOut(function(isPointInside)
        if isPointInside then
            activeScript = resource
            if inside then
                Wait(250)
                inside = false
            end
            for k, v in ipairs(interact.options) do
                local allowance, has = 5,0
                if v.canInteract then
                    if v.canInteract() then
                        has = has + 1
                    end
                else
                    has = has + 1
                end
                if v.item then
                     if QBCore.Functions.HasItem(v.item) then
                        has = has + 1
                     end
                else
                    has = has + 1
                end
                if v.job then
                    if type(v.job) == 'table' then
                        for _, jobName in pairs(v.job) do
                            if QBCore.Functions.GetPlayerData().job.name == jobName then
                                has = has + 1
                                break
                            end
                        end
                    else
                        if QBCore.Functions.GetPlayerData().job.name == v.job then
                            has = has + 1
                        end
                    end
                else
                    has = has + 1
                end
                if v.gang then
                    if type(v.gang) == 'table' then
                        for _, gangName in pairs(v.gang) do
                            if QBCore.Functions.GetPlayerData().gang.name == gangName then
                                has = has + 1
                                break
                            end
                        end
                    else
                        if QBCore.Functions.GetPlayerData().gang.name == v.gang then
                            has = has + 1
                        end
                    end
                else
                    has = has + 1
                end
                if v.citizenid then
                    if type(v.citizenid) == 'table' then
                        for _, cid in pairs(v.citizenid) do
                            if QBCore.Functions.GetPlayerData().citizenid == cid then
                                has = has + 1
                                break
                            end
                        end
                    else
                        if QBCore.Functions.GetPlayerData().citizenid == v.citizenid then
                            has = has + 1
                        end
                    end
                else
                    has = has + 1
                end
                if has == allowance then
                    table.insert(activeOptions, v)
                end
            end
            inside = true
            if #activeOptions > 0 then
                showUi()
            end
        else
            SendNUIMessage({
                action = 'hideUI',
            })
            activeOptions = {}
            inLoop = false
            activeScript = ''
            inside = false
        end
    end)
end

--- @PARAMS interactData {coords = vector4, length = number, width = number, height = number, name = string, options = array}
--- @RETURN boolean
--- @DESCRIPTION Adds an interactable zone at specified coordinates with given options.
local function addInteractZone(interactData)
    local resource = GetInvokingResource() or GetCurrentResourceName()
    if not zones[resource] then
        zones[resource] = {}
    end
    if not interactData.coords then
        print('qb-interact: No coords defined for interact zone!')
        return
    end
    if not interactData.options or #interactData.options == 0 then
        print('qb-interact: No options defined for interact zone!')
        return
    end
    if not interactData.name then
        print('qb-interact: No name defined for interact zone!')
        return
    end
    addZones(resource, interactData)
    return true
end

exports('addInteractZone', addInteractZone)

--- @PARAMS entity number
--- @PARAMS zoneOptions {length = number, width = number, height = number, name = string, options = array}
--- @RETURN boolean
--- @DESCRIPTION Adds an interactable zone attached to a specific entity with given options.
local function addEntityZone(entity, zoneOptions)
    if not entity or not DoesEntityExist(entity) then
        print('qb-interact: Invalid entity provided for entity zone!')
        return
    end
    local coords = GetEntityCoords(entity)
    zoneOptions.coords = vector4(coords.x, coords.y, coords.z, GetEntityHeading(entity))
    if not zoneOptions.options or #zoneOptions.options == 0 then
        print('qb-interact: No options defined for entity zone!')
        return
    end
    zoneOptions.name = entity
    if not zoneOptions.length then
        zoneOptions.length = 2.0
    end
    if not zoneOptions.width then
        zoneOptions.width = 2.0
    end
    if not zoneOptions.height then
        zoneOptions.height = 2.0
    end
    addInteractZone(zoneOptions)
    return true
end

exports('addEntityZone', addEntityZone)


local function removeInteractZones(name)
    local resource = GetInvokingResource() or GetCurrentResourceName()
    if not zones[resource] then
        return
    end
    if zones[resource][name] then
        zones[resource][name]:destroy()
        zones[resource][name] = nil
    end
    return true
end

exports('removeInteractZones', removeInteractZones)

AddEventHandler('onResourceStop', function(resource)
    if zones[resource] then
        for k, v in pairs(zones[resource]) do
            v:destroy()
        end
        zones[resource] = nil
    end
    if activeScript == resource then
        SendNUIMessage({
            action = 'hideUI',
        })
        activeOptions = {}
        inLoop = false
        activeScript = ''
    end
end)

--- @PARAMS model string
--- @PARAMS zoneOptions {length = number, width = number, height = number, name = string, options = array}
--- @DESCRIPTION Adds interactable zones to all objects matching the specified model with given options.

local function addObjectModel(model, zoneOptions)
    local objectList = GetGamePool('CObject')
    for k, v in pairs(objectList) do
        if GetEntityModel(v) == GetHashKey(model) then
            addEntityZone(v, zoneOptions)
        end
    end
end
exports('addObjectModel', addObjectModel)


--- @PARAMS model string
--- @PARAMS zoneOptions {length = number, width = number, height = number, name = string, options = array}
--- @DESCRIPTION Adds interactable zones to all peds matching the specified model with given options.
local function addPedModel(model, zoneOptions)
    local pedList = GetGamePool('CPed')
    for k, v in pairs(pedList) do
        if GetEntityModel(v) == GetHashKey(model) then
            addEntityZone(v, zoneOptions)
        end
    end
end
exports('addPedModel', addPedModel)
