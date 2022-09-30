local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function PlayATMAnimation(animation)
    local playerPed = PlayerPedId()
    if animation == 'enter' then
        RequestAnimDict('amb@prop_human_atm@male@enter')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do
            Wait(0)
        end
        TaskPlayAnim(playerPed, 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end

    if animation == 'exit' then
        RequestAnimDict('amb@prop_human_atm@male@exit')
        while not HasAnimDictLoaded('amb@prop_human_atm@male@exit') do
            Wait(0)
        end
        TaskPlayAnim(playerPed, 'amb@prop_human_atm@male@exit', "exit", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end
end

-- Events

RegisterNetEvent("hidemenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
end)

RegisterNetEvent('qb-atms:client:updateBankInformation', function(banking)
    SendNUIMessage({
        status = "loadBankAccount",
        information = banking
    })
end)

-- ox_target
if Config.UseTarget then
    CreateThread(function()
        local options = {
            {
                  name = 'ox:option1',
                  icon = 'fas fa-credit-card',
                  label = 'Use ATM',
                  serverEvent = 'qb-atms:server:enteratm',
                  canInteract = function(entity, coords, distance)
                      return QBCore.Functions.HasItem('visa') or QBCore.Functions.HasItem('mastercard')
                  end
              }
          }
          exports.ox_target:addModel(Config.ATMModels, options)
    end)
end

RegisterNetEvent('qb-atms:client:loadATM', function(cards)
    if cards and cards[1] then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed, true)
        for _, v in pairs(Config.ATMModels) do
            local hash = joaat(v)
            local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
            if atm then
                PlayATMAnimation('enter')
                if lib.progressBar({
                    duration = 1500,
                    label = 'Accessing ATM',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                }) then
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        status = "openATMFrontScreen",
                        cards = cards,
                    })
                else
                    lib.notify({
                        id = 'stop_atm',
                        title = 'Failed!',
                        position = 'top-right',
                        style = {
                            backgroundColor = '#141517',
                            color = '#909296'
                        },
                        icon = 'xmark',
                        iconColor = '#C53030'
                    })
                end
            end
        end
    else
        lib.notify({
            id = 'no_atm_card',
            title = 'Failed!',
            description = 'Please visit a branch to order a card',
            position = 'top-right',
            style = {
                backgroundColor = '#141517',
                color = '#909296'
            },
            icon = 'xmark',
            iconColor = '#C53030'
        })
    end
end)

-- Callbacks

RegisterNUICallback("NUIFocusOff", function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "closeATM"
    })
    PlayATMAnimation('exit')
end)

RegisterNUICallback("playATMAnim", function()
    local anim = 'amb@prop_human_atm@male@idle_a'
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), anim, "idle_a", 1.0,-1.0, 3000, 1, 1, true, true, true)
end)

RegisterNUICallback("doATMWithdraw", function(data)
    if data then
        TriggerServerEvent('qb-atms:server:doAccountWithdraw', data)
    end
end)

RegisterNUICallback("loadBankingAccount", function(data)
    QBCore.Functions.TriggerCallback('qb-atms:server:loadBankAccount', function(banking)
        if banking and type(banking) == "table" then
            SendNUIMessage({
                status = "loadBankAccount",
                information = banking
            })
        else
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
        end
    end, data.cid, data.cardnumber)
end)

RegisterNUICallback("removeCard", function(data)
    QBCore.Functions.TriggerCallback('qb-debitcard:server:deleteCard', function(hasDeleted)
        if hasDeleted then
            SetNuiFocus(false, false)
            SendNUIMessage({
                status = "closeATM"
            })
            lib.notify({
                id = 'card_deletes',
                title = 'Success!',
                description = 'Card has been deleted',
                position = 'top-right',
                style = {
                    backgroundColor = '#141517',
                    color = '#909296'
                },
                icon = 'check',
                iconColor = '#07c70d '
            })
        else
            lib.notify({
                id = 'failed_delete_card',
                title = 'Failed to delete card.',
                position = 'top-right',
                style = {
                    backgroundColor = '#141517',
                    color = '#909296'
                },
                icon = 'xmark',
                iconColor = '#C53030'
            })
        end
    end, data)
end)
