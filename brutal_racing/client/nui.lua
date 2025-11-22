RegisterNUICallback("UseButton", function(data)
	if data.action == "CreateParty" then
		data.MaxPlayers = tonumber(data.MaxPlayers)
		data.MinPlayers = tonumber(data.MinPlayers)
		data.MaxLaps = tonumber(data.MaxLaps)
		data.MoneyAmount = tonumber(data.MoneyAmount)
		TriggerServerEvent('brutal_racing:server:CreateParty', data.Party, data.MaxPlayers, data.MinPlayers, data.MaxLaps, data.Accessibility, data.MoneyAmount, data.AccValue, data.Model+1)
		CreatedParty(data.Party)
	elseif data.action == "StartParty" then
		TriggerServerEvent('brutal_racing:server:StartParty', data.Party)
	elseif data.action == "JoinParty" then
		TriggerServerEvent('brutal_racing:server:JoinParty', data.Party)
	elseif data.action == "CancelParty" then
		TriggerServerEvent('brutal_racing:server:CancelParty', data.Party)
	elseif data.action == "AcceptJoin" then
		data.PlayerID = tonumber(data.PlayerID)
		TriggerServerEvent('brutal_racing:server:AcceptJoin', data.Party, data.PlayerID)
	elseif data.action == "KickPlayer" then
		data.PlayerID = tonumber(data.PlayerID)
		TriggerServerEvent('brutal_racing:server:KickPlayer', data.Party, data.PlayerID)
	elseif data.action == "LeaveParty" then
		TriggerServerEvent('brutal_racing:server:LeaveParty', data.Party)
	elseif data.action == "close" then
		MenuOpen = false
		SetNuiFocus(false,false)
    end
end)
