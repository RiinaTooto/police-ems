if Config.AdminCommands.Revive.Use then
    TriggerEvent('chat:addSuggestion', '/'.. Config.AdminCommands.Revive.Command ..'', Config.AdminCommands.Revive.Suggestion)
end

if Config.AdminCommands.Kill.Use then
    TriggerEvent('chat:addSuggestion', '/'.. Config.AdminCommands.Heal.Command ..'', Config.AdminCommands.Heal.Suggestion)

    RegisterNetEvent('brutal_ambulancejob:server:kill', function()
        SetEntityHealth(PlayerPedId(), 0)
    end)
end

if Config.AdminCommands.Heal.Use then
    TriggerEvent('chat:addSuggestion', '/'.. Config.AdminCommands.Kill.Command ..'', Config.AdminCommands.Kill.Suggestion)

    RegisterNetEvent('brutal_ambulancejob:server:heal', function()
        local playerPed = PlayerPedId()
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    end)
end