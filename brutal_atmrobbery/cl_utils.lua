function notification(title, text, time, type)
    if Config.BrutalNotify then
        exports['brutal_notify']:SendAlert(title, text, time, type)
    else
        -- Put here your own notify and set the Config.BrutalNotify to false
        TriggerEvent('brutal_shop_robbery:client:DefaultNotify', text)
    end
end

RegisterNetEvent('brutal_shop_robbery:client:DefaultNotify')
AddEventHandler('brutal_shop_robbery:client:DefaultNotify', function(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(0,1)

    -- Default ESX Notify:
    --TriggerEvent('esx:showNotification', text)

    -- Default QB Notify:
    --TriggerEvent('QBCore:Notify', text, 'info', 5000)
end)

RegisterNetEvent('brutal_atm_robbery:client:PoliceAlertBlip')
AddEventHandler('brutal_atm_robbery:client:PoliceAlertBlip', function(coords)

    -- notify function
    notification(Config['Notification'][2][1], Config['Notification'][2][2], Config['Notification'][2][3], Config['Notification'][2][4])
    
    -- blip for the cops
    AlertAtm = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(AlertAtm, Config['Blips'][1]['sprite'])
    SetBlipScale(AlertAtm, Config['Blips'][1]['size'])
    SetBlipColour(AlertAtm, Config['Blips'][1]['colour'])
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config['Blips'][1]['label'])
    EndTextCommandSetBlipName(AlertAtm)

    Citizen.Wait(1000*60*Config['BlipTime'])
    RemoveBlip(AlertAtm)
end)