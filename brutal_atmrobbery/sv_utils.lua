--local YourWebhook = 'FIVE LEAKS WEBHOOK'  -- help: https://docs.brutalscripts.com/site/others/discord-webhook

function GetWebhook()
    return YourWebhook
end

-- Buy here: (4€+VAT) https://store.brutalscripts.com
function notification(source, title, text, time, type)
    if Config.BrutalNotify then
        TriggerClientEvent('brutal_notify:SendAlert', source, title, text, time, type)
    else
        TriggerClientEvent('brutal_shop_robbery:client:DefaultNotify', text)
    end
end

RegisterServerEvent("brutal_atm_robbery:server:PoliceAlert")
AddEventHandler("brutal_atm_robbery:server:PoliceAlert", function(coords)
    local source = source
	local xPlayers = GetPlayersFunction()
	
	for i=1, #xPlayers, 1 do
        for ii=1, #Config['CopJobs'] do
            if GetPlayerJobFunction(xPlayers[i]) == Config['CopJobs'][ii] then
            TriggerClientEvent("brutal_atm_robbery:client:PoliceAlertBlip", xPlayers[i], coords)
            end
        end
    end
end)
