if Config.AdminCommands.Revive.Use then
    RegisterCommand(Config.AdminCommands.Revive.Command, function(source, args, rawCommand)
        if StaffCheck(source, Config.AdminCommands.Revive.AdminGroups) then
            if args[1] == 'me' or args[1] == 'ME' or args[1] == 'mE' or args[1] == 'Me' then
                args[1] = source
            elseif args[1] == 'all' or args[1] == 'ALL' or args[1] == 'aLL' or args[1] == 'All' then
                args[1] = -1
            end

            if args[1] == -1 then
                TriggerClientEvent('brutal_ambulancejob:revive', args[1])
                DiscordWebhook('AdminCommand', ''.. Config.Webhooks.Locale['Command']..':** /'..Config.AdminCommands.Revive.Command..' all\n**'.. Config.Webhooks.Locale['AdminName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source))
            elseif type(tonumber(args[1])) == 'number' and GetPlayerPing(tonumber(args[1])) > 0 then
                TriggerClientEvent('brutal_ambulancejob:revive', tonumber(args[1]))
                DiscordWebhook('AdminCommand', ''.. Config.Webhooks.Locale['Command']..':** /'..Config.AdminCommands.Revive.Command..' '..tonumber(args[1])..'\n**'.. Config.Webhooks.Locale['AdminName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source))
            else
                TriggerClientEvent('brutal_ambulancejob:client:SendNotify', source, Config.Notify[4][1], Config.Notify[4][2], Config.Notify[4][3], Config.Notify[4][4])
            end
        end
    end)
end

if Config.AdminCommands.Kill.Use then
    RegisterCommand(Config.AdminCommands.Kill.Command, function(source, args, rawCommand)
        if StaffCheck(source, Config.AdminCommands.Kill.AdminGroups) then
            if args[1] == 'me' or args[1] == 'ME' or args[1] == 'mE' or args[1] == 'Me' then
                args[1] = source
            end

            if type(tonumber(args[1])) == 'number' and GetPlayerPing(tonumber(args[1])) > 0 then
                TriggerClientEvent('brutal_ambulancejob:server:kill', tonumber(args[1]))
                DiscordWebhook('AdminCommand', ''.. Config.Webhooks.Locale['Command']..':** /'..Config.AdminCommands.Kill.Command..' '..tonumber(args[1])..'\n**'.. Config.Webhooks.Locale['AdminName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source))
            else
                TriggerClientEvent('brutal_ambulancejob:client:SendNotify', source, Config.Notify[4][1], Config.Notify[4][2], Config.Notify[4][3], Config.Notify[4][4])
            end
        end
    end)
end

if Config.AdminCommands.Heal.Use then
    RegisterCommand(Config.AdminCommands.Heal.Command, function(source, args, rawCommand)
        if StaffCheck(source, Config.AdminCommands.Heal.AdminGroups) then
            if args[1] == 'me' or args[1] == 'ME' or args[1] == 'mE' or args[1] == 'Me' then
                args[1] = source
            end

            if type(tonumber(args[1])) == 'number' and GetPlayerPing(tonumber(args[1])) > 0 then
                TriggerClientEvent('brutal_ambulancejob:server:heal', tonumber(args[1]))
                DiscordWebhook('AdminCommand', ''.. Config.Webhooks.Locale['Command']..':** /'..Config.AdminCommands.Heal.Command..' '..tonumber(args[1])..'\n**'.. Config.Webhooks.Locale['AdminName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source))
            else
                TriggerClientEvent('brutal_ambulancejob:client:SendNotify', source, Config.Notify[4][1], Config.Notify[4][2], Config.Notify[4][3], Config.Notify[4][4])
            end
        end
    end)
end