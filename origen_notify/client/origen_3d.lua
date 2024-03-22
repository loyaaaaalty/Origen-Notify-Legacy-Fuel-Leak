local notifys = {}

function GenerateId()
    local id = GetGameTimer() .. math.random(1000, 9999)
    return id
end

function CreateHelp(key, text)
    if not key then
        return
    end

    local id = GenerateId()

    table.insert(notifys, {
        id = id,
        key = key,
        text = text
    })

    SendNUIMessage({
        action = "CreateHelp",
        id = id,
        text = text,
        key = key
    })

    return id
end

function UpdateHelp(id, key, text)
    for i = 1, #notifys do
        if notifys[i].id == id then
            notifys[i].key = key
            notifys[i].text = text
            break
        end
    end
    SendNUIMessage({
        action = "UpdateHelp",
        id = id,
        text = text,
        key = key
    })
end

function RemoveHelp(id)
    for i = 1, #notifys do
        if notifys[i].id == id then
            table.remove(notifys, i)
            break
        end
    end
    SendNUIMessage({
        action = "RemoveHelp",
        id = id
    })
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(250)

        if #notifys > 0 then
            local coordX, coordY = GetNuiCursorPosition()

            SendNUIMessage({
                action = "TickHelp",
                x = coordX,
                y = coordY,
                hide = IsPauseMenuActive()
            })
        end
    end
end)

RegisterNetEvent("origen_notify:CreateHelp", CreateHelp)
RegisterNetEvent("origen_notify:UpdateHelp", UpdateHelp)
RegisterNetEvent("origen_notify:RemoveHelp", RemoveHelp)

exports("CreateHelp", CreateHelp)
exports("UpdateHelp", UpdateHelp)
exports("RemoveHelp", RemoveHelp)