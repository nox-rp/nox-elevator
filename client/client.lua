local resourceName = GetCurrentResourceName()
local mode = (Config and Config.Mode) or 'standalone'
local elevators = (Config and Config.Elevators) or {}
local registeredTargets = {}
local standalonePoints = {}

local function debugPrint(...)
    if Config and Config.Debug then
        print('[nox-elevator]', ...)
    end
end

local function ensureVector3(value)
    if value == nil then
        return nil
    end

    local t = type(value)

    if t == 'vector3' then
        return value
    end

    if t == 'vector4' then
        return vector3(value.x + 0.0, value.y + 0.0, value.z + 0.0)
    end

    if t == 'table' then
        local x = value.x or value[1]
        local y = value.y or value[2]
        local z = value.z or value[3]
        if x and y and z then
            return vector3(x + 0.0, y + 0.0, z + 0.0)
        end
    end

    if t == 'string' then
        local x, y, z = value:match('([^,]+),([^,]+),([^,]+)')
        if x and y and z then
            return vector3(tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0)
        end
    end

    return nil
end

local function openElevatorMenu(id)
    local cfg = elevators[id]
    if not cfg or not cfg.floors or #cfg.floors == 0 then
        debugPrint('invalid elevator config for', id)
        return
    end

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'OPEN_MENU',
        elevatorId = id,
        label = cfg.label or id,
        description = cfg.description,
        displayFloor = cfg.displayFloor,
        floors = cfg.floors
    })
end

local function closeElevatorMenu()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'CLOSE_MENU'
    })
end

local function teleportToFloor(elevatorId, floorId)
    local cfg = elevators[elevatorId]
    if not cfg or not cfg.floors then
        return
    end

    local floor
    for _, f in ipairs(cfg.floors) do
        if f.id == floorId or f.id == tonumber(floorId) then
            floor = f
            break
        end
    end

    if not floor then
        debugPrint('floor not found', elevatorId, floorId)
        return
    end

    local coords = ensureVector3(floor.coords)
    if not coords then
        debugPrint('invalid coords for floor', elevatorId, floorId)
        return
    end

    local heading
    if floor.heading ~= nil then
        heading = floor.heading
    elseif type(floor.coords) == 'vector4' then
        heading = floor.coords.w
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        SetEntityCoords(veh, coords.x, coords.y, coords.z, false, false, false, true)
        if heading then
            SetEntityHeading(veh, heading + 0.0)
        end
    else
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        if heading then
            SetEntityHeading(ped, heading + 0.0)
        end
    end
end

RegisterNUICallback('selectFloor', function(data, cb)
    if data and data.elevatorId and data.floorId then
        local floorId = tostring(data.floorId)
        if floorId:upper() == 'BELL' then
            TriggerServerEvent('nox-elevator:bell', data.elevatorId)
            if cb then
                cb({ ok = true })
            end
            return
        end

        teleportToFloor(data.elevatorId, data.floorId)
    end
    closeElevatorMenu()
    if cb then
        cb({ ok = true })
    end
end)

RegisterNUICallback('close', function(_, cb)
    closeElevatorMenu()
    if cb then
        cb({ ok = true })
    end
end)

local function setupOxTarget()
    if not Config or Config.Mode ~= 'ox_target' then
        return
    end

    if GetResourceState('ox_target') ~= 'started' then
        debugPrint('ox_target is not started, falling back to standalone mode')
        mode = 'standalone'
        return
    end

    local oxTargetCfg = Config.OxTarget or {}
    for id, cfg in pairs(elevators) do
        local label = oxTargetCfg.Label or (cfg.label or 'Use elevator')
        local icon = oxTargetCfg.Icon or 'fa-solid fa-elevator'
        local distance = oxTargetCfg.Distance or 2.0

        local function addZone(coords, pointCfg)
            local size = ensureVector3(pointCfg and pointCfg.size) or vector3(1.0, 1.0, 1.0)
            local rotation = (pointCfg and pointCfg.rotation) or 0.0

            local zoneId = exports.ox_target:addBoxZone({
                coords = coords,
                size = size,
                rotation = rotation + 0.0,
                debug = (pointCfg and pointCfg.debug) or false,
                options = {
                    {
                        name = 'nox-elevator:' .. id,
                        label = label,
                        icon = icon,
                        distance = distance,
                        onSelect = function()
                            openElevatorMenu(id)
                        end
                    }
                }
            })
            registeredTargets[#registeredTargets + 1] = zoneId
        end

        local point = cfg.point
        if point and point.coords then
            local coords = ensureVector3(point.coords)
            if coords then
                addZone(coords, point)
            end
        end

        local floors = cfg.floors
        if floors then
            for _, floor in ipairs(floors) do
                local floorPoint = floor.point
                if floorPoint and floorPoint.coords then
                    local coords = ensureVector3(floorPoint.coords)
                    if coords then
                        addZone(coords, floorPoint)
                    end
                end
            end
        end
    end
end

local function draw3dText(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then
        return
    end

    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function setupStandalone()
    if mode ~= 'standalone' then
        return
    end

    for id, cfg in pairs(elevators) do
        local point = cfg.point
        if point and point.coords then
            local coords = ensureVector3(point.coords)
            if coords then
                standalonePoints[#standalonePoints + 1] = {
                    id = id,
                    coords = coords
                }
            end
        end

        local floors = cfg.floors
        if floors then
            for _, floor in ipairs(floors) do
                local floorPoint = floor.point
                if floorPoint and floorPoint.coords then
                    local coords = ensureVector3(floorPoint.coords)
                    if coords then
                        standalonePoints[#standalonePoints + 1] = {
                            id = id,
                            coords = coords
                        }
                    end
                end
            end
        end
    end

    if #standalonePoints == 0 then
        return
    end

    local standaloneCfg = Config.Standalone or {}
    local key = standaloneCfg.Key or 38
    local interactDistance = standaloneCfg.InteractDistance or 1.5
    local markerDistance = standaloneCfg.MarkerDistance or 15.0
    local drawMarker = standaloneCfg.DrawMarker ~= false
    local markerType = standaloneCfg.MarkerType or 2
    local markerSize = standaloneCfg.MarkerSize or { x = 0.4, y = 0.4, z = 0.4 }
    local markerColor = standaloneCfg.MarkerColor or { r = 120, g = 120, b = 255, a = 180 }
    local helpText = standaloneCfg.HelpText or '[E] Use elevator'

    CreateThread(function()
        while true do
            local wait = 1000
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local nearestId
            local nearestCoords
            local nearestDist = interactDistance + 0.1

            for _, data in ipairs(standalonePoints) do
                local dist = #(pCoords - data.coords)
                if dist < markerDistance then
                    wait = 0
                    if drawMarker then
                        DrawMarker(
                            markerType,
                            data.coords.x, data.coords.y, data.coords.z,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            markerSize.x or 0.4,
                            markerSize.y or 0.4,
                            markerSize.z or 0.4,
                            markerColor.r or 120,
                            markerColor.g or 120,
                            markerColor.b or 255,
                            markerColor.a or 180,
                            false, false, 2, false, nil, nil, false
                        )
                    end

                    if dist < nearestDist then
                        nearestId = data.id
                        nearestCoords = data.coords
                        nearestDist = dist
                    end
                end
            end

            if nearestId and nearestCoords then
                draw3dText(nearestCoords + vector3(0.0, 0.0, markerSize.z or 0.4), helpText)

                if IsControlJustPressed(0, key) then
                    openElevatorMenu(nearestId)
                end
            end

            Wait(wait)
        end
    end)
end

CreateThread(function()
    if next(elevators) == nil then
        debugPrint('no elevators configured')
        return
    end

    if mode == 'ox_target' then
        setupOxTarget()
    else
        setupStandalone()
    end
end)
