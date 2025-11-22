CanRobbery = true

RUI(Config['Item'], function(source)
    TriggerClientEvent('brutal_atm_robbery:client:UseItem', source)
end)

RegisterServerEvent("brutal_atm_robbery:server:RemoveItem")
AddEventHandler("brutal_atm_robbery:server:RemoveItem", function(item)
    RemoveItem(source, item,1)
end)

RegisterServerEvent('brutal_atm_robbery:server:Timer')
AddEventHandler('brutal_atm_robbery:server:Timer', function()
    CanRobbery = false
    Citizen.Wait(1000 * 60 * Config['NextRobbery'])
    CanRobbery = true
end)

RESCB("brutal_atm_robbery:server:GetCops",function(source,cb)
	Citizen.Wait(1)

    local Players = GetPlayersFunction()
	local policeOnline = 0
	for i = 1, #Players do
        for ii=1, #Config['CopJobs'] do
            if GetPlayerJobFunction(Players[i]) == Config['CopJobs'][ii] then
                policeOnline = policeOnline + 1
             end
         end
	end

	if policeOnline >= Config['RequiredCopsCount'] then
        if CanRobbery then
            cb(true)
        else
            TriggerClientEvent('brutal_atm_robbery:client:ServerNotify', source, Config['Notification'][4][1], Config['Notification'][4][2], Config['Notification'][4][3], Config['Notification'][4][4])
            cb(false)
        end
	else
	TriggerClientEvent('brutal_atm_robbery:client:ServerNotify', source, Config['Notification'][3][1], Config['Notification'][3][2], Config['Notification'][3][3], Config['Notification'][3][4])
    cb(false)
	end
end)

RegisterServerEvent('brutal_atm_robbery:server:AddPlayerMoney')
AddEventHandler('brutal_atm_robbery:server:AddPlayerMoney', function(Reward)
    AddMoneyFunction(source, Reward)
    TriggerClientEvent('brutal_atm_robbery:client:ServerNotify', source, Config['Notification'][5][1], "".. Config['Notification'][5][2] .. " ".. Reward .. " ".. Config['MoneySymbol'] .. "", Config['Notification'][5][3], Config['Notification'][5][4])
end)