OneSync = GetConvar("onesync", "off")
if (OneSync ~= "off" and OneSync ~= "legacy") then 
    OneSync = 'infinite'
end

RESCB("brutal_ambulancejob:server:getDeathStatus",function(source,cb)
    local death = false

    if Config.SaveDeathStatus then
        if Config['Core']:upper() == 'ESX' then
            MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', { ['@identifier'] = GetIdentifier(source)}, function(results)
                if results[1].is_dead == true or results[1].is_dead == 1 then
                    death = true
                end
            end)
        elseif Config['Core']:upper() == 'QBCORE' then
            death = GetPlayerDeathMetaData(source) or false
        end
    end
    
    Citizen.Wait(1000)
    cb({name = GetPlayerNameFunction(source), death = death})
end)

if Config['Core']:upper() == 'ESX' then
    TriggerEvent('esx_society:registerSociety', Config.AmbulanceJob.Job, Config.AmbulanceJob.Label, 'society_'..Config.AmbulanceJob.Job, 'society_'..Config.AmbulanceJob.Job, 'society_'..Config.AmbulanceJob.Job, {type = 'public'})

    RegisterNetEvent(onPlayerDeath)
    AddEventHandler(onPlayerDeath, function()
        local src = source
        TriggerClientEvent('brutal_ambulancejob:client:onPlayerDeath', src)
    end)
elseif Config['Core']:upper() == 'QBCORE' then
    RegisterNetEvent("onPlayerDeath")
    AddEventHandler("onPlayerDeath", function()
        local src = source
        TriggerClientEvent('brutal_ambulancejob:client:onPlayerDeath', src)
    end)
end

RegisterServerEvent('brutal_ambulancejob:server:setDeathStatus')
AddEventHandler('brutal_ambulancejob:server:setDeathStatus', function(deathStatus)
    local identifier = GetIdentifier(source)

    if Config.SaveDeathStatus then
        if Config['Core']:upper() == 'ESX' then
            if deathStatus then
                MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', {1, identifier})
            elseif deathStatus == false then
                MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', {0, identifier})
            end
        elseif Config['Core']:upper() == 'QBCORE' then
            SetPlayerDeathMetaData(source, deathStatus)
        end
    end

    if deathStatus == false then
        for k,v in pairs(Calls) do
            if v.playerid == source then
                Calls[k].closed = true
                TriggerClientEvent('brutal_ambulancejob:client:RemoveCitizenCallBlip', -1, k)

            end
        end
    end
end)

RegisterServerEvent('brutal_ambulancejob:server:clearinventory')
AddEventHandler('brutal_ambulancejob:server:clearinventory', function()
    if Config.ClearInventory then ClearPlayerInventory(source) end
end)

-----------------------------------------------------------
---------------------| Citizen Call |----------------------
-----------------------------------------------------------

Calls = {}

RegisterServerEvent('brutal_ambulancejob:server:citizencall')
AddEventHandler('brutal_ambulancejob:server:citizencall', function(type, data1, data2, data3)
    local src = source
    if type == 'create' then
        Calls[#Calls+1] = {
            playerid = src,
            text = data1,
            coords = data2,
            street = data3,
            medicers = {},
            closed = false,
            reason = ''
        }
        if data1 ~= nil then
            DiscordWebhook('CallOpen', '**'.. Config.Webhooks.Locale['Callid'] ..':** #'..#Calls..'\n**'.. Config.Webhooks.Locale['Street'] ..':** '..data3..'\n**'.. Config.Webhooks.Locale['Coords'] ..':** '..math.floor(data2[1])..' '..math.floor(data2[2])..' '..math.floor(data2[3])..'\n**'.. Config.Webhooks.Locale['PlayerName']..':** '.. data1..' ['.. src ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(src))
        end

        TriggerClientEvent('brutal_ambulancejob:client:SendNotify', src, Config.Notify[8][1], Config.Notify[8][2], Config.Notify[8][3], Config.Notify[8][4])

        TriggerClientEvent('brutal_ambulancejob:client:CitizenCallArived', -1, #Calls, data3)
    elseif type == 'accept' then
        table.insert(Calls[data1].medicers, {id = src, name = GetPlayerNameFunction(src)})
    elseif type == 'close' then
        Calls[data1].closed = true
        Calls[data1].reason = data2
        DiscordWebhook('CallClose', '**'.. Config.Webhooks.Locale['Callid'] ..':** #'..data1..'\n**'.. Config.Webhooks.Locale['Text'] ..':** '..Calls[data1].text..'\n\n**__'.. Config.Webhooks.Locale['Assistant']..'__**\n**'.. Config.Webhooks.Locale['CloseReason']..':** '.. Calls[data1].reason ..'\n**'.. Config.Webhooks.Locale['PlayerName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source))
        TriggerClientEvent('brutal_ambulancejob:client:RemoveCitizenCallBlip', -1, data1)
    end

    TriggerClientEvent('brutal_ambulancejob:client:CitizenCallRefreshTable', src, Calls)
end)

RESCB("brutal_ambulancejob:server:GetCalls",function(source, cb)
    cb(Calls)
end)


-----------------------------------------------------------
-----------------------| Invoices |------------------------
-----------------------------------------------------------

RESCB("brutal_ambulancejob:server:GetInvoiceTypes",function(source, cb, targetID)
    MySQL.Async.fetchAll('SELECT * FROM ambulance_invoice_types', {}, function(invoices_table)
        if targetID ~= nil and GetPlayerPing(targetID) > 0 then
		    cb({invoices = invoices_table, targetname = GetPlayerNameFunction(targetID)})
        else
            cb({invoices = invoices_table, targetname = '-'})
        end
	end)
end)

RegisterServerEvent('brutal_ambulancejob:server:CreateNewInvoiceType')
AddEventHandler('brutal_ambulancejob:server:CreateNewInvoiceType', function(Label, Amount)
    MySQL.insert('INSERT INTO ambulance_invoice_types (label, amount) VALUES (?, ?)', {Label, Amount})
end)

RegisterServerEvent('brutal_ambulancejob:server:RemoveInvoiceType')
AddEventHandler('brutal_ambulancejob:server:RemoveInvoiceType', function(id)
    MySQL.insert('DELETE FROM ambulance_invoice_types WHERE `id` = ?', {id})
end)

RegisterServerEvent('brutal_ambulancejob:server:GiveInvoice')
AddEventHandler('brutal_ambulancejob:server:GiveInvoice', function(targetID, label, price)
    if GetPlayerPing(targetID) > 0 then
        local targetIdentifier = GetIdentifier(targetID)
        local targetname = GetPlayerNameFunction(targetID)
        local job = Config.AmbulanceJob.Job
        local jobname = Config.AmbulanceJob.Label

        if Config.Billing == false then
            RemoveAccountMoney(targetID, 'bank', price)
            TriggerClientEvent('brutal_ambulancejob:client:SendNotify', targetID, Config.Notify[19][1], Config.Notify[19][2]..' '..price..''..Config.MoneyForm, Config.Notify[19][3], Config.Notify[19][4])
            
            if Config['Core']:upper() == 'ESX' then
                local society = exports['esx_society']:GetSociety(Config.AmbulanceJob.Job)
                TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                    account.addMoney(price)
                end)
            else
                exports['qb-management']:AddMoney(Config.AmbulanceJob.Job, price)
            end
        elseif Config.Billing:lower() == 'esx_billing' then
            MySQL.insert('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)', {targetIdentifier, 'society_'..job, 'society', 'society_'..job, label, price})
        elseif Config.Billing:lower() == 'okokbilling' then
            MySQL.insert('INSERT INTO okokbilling (ref_id, fees_amount, receiver_identifier, receiver_name, author_identifier, author_name, society, society_name, item, invoice_value, status, notes, sent_date, limit_pay_date) VALUES (CONCAT("OK", UPPER(LEFT(UUID(), 8))), 0, @receiver_identifier, @receiver_name, @author_identifier, @author_name, @society, @society_name, @item, @invoice_value, @status, @notes, CURRENT_TIMESTAMP(), DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY))', {
                ['@receiver_identifier'] = targetIdentifier,
                ['@receiver_name'] = targetname,
                ['@author_identifier'] = 'society_'..job,
                ['@author_name'] = label,
                ['@society'] = 'society_'..job,
                ['@society_name'] = jobname,
                ['@item'] = label,
                ['@invoice_value'] = price,
                ['@status'] = 'unpaid',
                ['@notes'] = ''
            })
        elseif Config.Billing:lower() == 'jaksam_billing' then
            MySQL.insert('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)', {targetIdentifier, 'society_'..job, 'society', 'society_'..job, label, price})
        end

        TriggerClientEvent('brutal_ambulancejob:client:SendNotify', source, Config.Notify[11][1], Config.Notify[11][2], Config.Notify[11][3], Config.Notify[11][4])
        DiscordWebhook('InvoiceCreated', '**'.. Config.Webhooks.Locale['Text'] ..':** '..label..'\n**'.. Config.Webhooks.Locale['Amount'] ..':** '..price..' '..Config.MoneyForm..'\n\n**__'.. Config.Webhooks.Locale['Receiver']..'__**\n**'.. Config.Webhooks.Locale['PlayerName'] ..':** '..targetname..'\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '..targetIdentifier..'\n\n**__'.. Config.Webhooks.Locale['Assistant']..'__**\n**'.. Config.Webhooks.Locale['Job']..':** '.. job ..'\n**'.. Config.Webhooks.Locale['PlayerName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source))
    end
end)

-----------------------------------------------------------
----------------------| Medicer menu |---------------------
-----------------------------------------------------------

RegisterServerEvent('brutal_ambulancejob:server:MedicerMenuGetDamageData')
AddEventHandler('brutal_ambulancejob:server:MedicerMenuGetDamageData', function(Target)
    TriggerClientEvent('brutal_ambulancejob:client:MedicerMenuGetDamageData', Target, Target, source)
end)

RegisterServerEvent('brutal_ambulancejob:server:MedicerMenuSendDamageData')
AddEventHandler('brutal_ambulancejob:server:MedicerMenuSendDamageData', function(Target, Source, DamagesTable, DeathStatus)
    TriggerClientEvent('brutal_ambulancejob:client:MedicerMenuSendDamageData', Source, Target, DamagesTable, DeathStatus)
end)

RESCB("brutal_ambulancejob:server:getMedicerItems",function(source, cb)
    local src = source
    local ItemsTable = {}
    for k,v in pairs(Config.MedicerItems) do
        if GetItemCount(src, v) > 0 then
            ItemsTable[k] = v
        else
            ItemsTable[k] = false
        end
    end
    cb(ItemsTable)
end)

RESCB("brutal_ambulancejob:server:removeMedicerItems",function(source, cb, item)
    if item == "head_heal" then
        item = Config.MedicerItems.Head
    elseif item == "body_heal" then
        item = Config.MedicerItems.Body
    elseif item == "arm_heal" then
        item = Config.MedicerItems.Arms
    elseif item == "leg_heal" then
        item = Config.MedicerItems.Legs
    elseif item == "blood" then
        item = Config.MedicerItems.Bandage
    elseif item == "revive" then
        item = Config.MedicerItems.Medikit
    end

    if GetItemCount(source, item) > 0 then
        RemoveItem(source, item, 1)
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('brutal_ambulancejob:server:MedicerMenuUseItem')
AddEventHandler('brutal_ambulancejob:server:MedicerMenuUseItem', function(Target, Item, Part)
    TriggerClientEvent('brutal_ambulancejob:client:MedicerMenuUseItem', Target, Item, Part)
end)

RegisterServerEvent('brutal_ambulancejob:server:MedicerMenuAnims')
AddEventHandler('brutal_ambulancejob:server:MedicerMenuAnims', function(Target, AnimType)
    if AnimType == "revive" and Config.ReviveReward > 0 then
        Citizen.CreateThread(function()
            Citizen.Wait(1000*57)
            AddMoneyFunction(Target, 'bank', Config.ReviveReward)
            TriggerClientEvent('brutal_ambulancejob:client:SendNotify', Target, Config.Notify[24][1], Config.Notify[24][2]..' '..Config.ReviveReward..''..Config.MoneyForm, Config.Notify[24][3], Config.Notify[24][4])
        end)
    end

    TriggerClientEvent('brutal_ambulancejob:client:MedicerMenuAnims', Target, source, AnimType)
end)

-----------------------------------------------------------
-------------------------| shop |--------------------------
-----------------------------------------------------------

RESCB("brutal_ambulancejob:server:GetPlayerMoney",function(source,cb)
    local wallet = {money = GetAccountMoney(source, 'money'), bank = GetAccountMoney(source, 'bank')}
    cb(wallet)
end)

RegisterServerEvent('brutal_ambulancejob:server:AddItem')
AddEventHandler('brutal_ambulancejob:server:AddItem', function(ItemTable, Paytype)
    local Text = ''
    local TotalMoney = 0
    for k, v in pairs(ItemTable) do
        if Text == '' then
            Text = v.amount..'x '..v.label
        else
            Text = Text..', '..v.amount..'x '..v.label
        end
        if v.price ~= nil then 
            TotalMoney = TotalMoney + v.price * v.amount
        end

        AddItem(source, v.item, v.amount)
    end

    DiscordWebhook('ItemBought', '**'.. Config.Webhooks.Locale['PlayerName']..':** '.. GetPlayerNameFunction(source)..' ['.. source ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(source) ..'\n**'.. Config.Webhooks.Locale['Items'] ..':** '..Text)
    if TotalMoney == 0 then
        TriggerClientEvent('brutal_ambulancejob:client:SendNotify', source, Config.Notify[29][1], Config.Notify[29][2]..' '..Text, Config.Notify[29][3], Config.Notify[29][4])
    else
        RemoveAccountMoney(source, Paytype, TotalMoney)
        TriggerClientEvent('brutal_ambulancejob:client:SendNotify', source, Config.Notify[29][1], Config.Notify[29][2]..' '..Text..''..Config.Notify[28][2]..' '..TotalMoney..''..Config.MoneyForm, Config.Notify[29][3], Config.Notify[29][4])
    end
end)


-----------------------------------------------------------
----------------------| duty status |----------------------
-----------------------------------------------------------

InDuty = {}

RegisterNetEvent("brutal_ambulancejob:server:GetDutyStatus")
AddEventHandler('brutal_ambulancejob:server:GetDutyStatus', function(source, playerJob, cb)
    if Config.AmbulanceJob.Job == playerJob then
        if InDuty[source] then
            return cb(true)
        else
            return cb(false)
        end
    else
        return cb(true)
    end
end)

RegisterNetEvent("brutal_ambulancejob:server:SetDutyStatus")
AddEventHandler("brutal_ambulancejob:server:SetDutyStatus", function(status, useblip)
    local src = source

    InDuty[src] = status

    if useblip then
        if OneSync == 'infinite' then
            Citizen.CreateThread(function()
                while InDuty[src] do
                    local Table = {}
                    for k,v in pairs(InDuty) do
                        if v == true and k ~= src then
                            local playerPed = GetPlayerPed(k)
                            local coords = GetEntityCoords(playerPed)
                            local heading = GetEntityHeading(playerPed)
                            table.insert(Table, {
                                label = Config.Locales.Colleague,
                                location = {
                                    x = coords.x,
                                    y = coords.y,
                                    z = coords.z,
                                    h = heading
                                }
                            })
                        end
                    end

                    TriggerClientEvent('brutal_ambulancejob:client:updateBlip', src, OneSync, Table)
                    Citizen.Wait(5000)
                end
            end)
        else
            for k,v in pairs(InDuty) do
                if InDuty[k] then
                    TriggerClientEvent('brutal_ambulancejob:client:updateBlip', k, OneSync, InDuty)
                end
            end
        end
    end

    local count = 0
    for k,v in pairs(InDuty) do
        if v then
            count = count + 1
        end
    end
    TriggerClientEvent('brutal_ambulancejob:client:updateAvailabemedicers', -1, count)
end)


AddEventHandler('playerDropped', function()
    InDuty[source] = false

    local count = 0
    for k,v in pairs(InDuty) do
        if v then
            count = count + 1
        end
    end
    TriggerClientEvent('brutal_ambulancejob:client:updateAvailabemedicers', -1, count)
end)


-----------------------------------------------------------
------------------------| others |-------------------------
-----------------------------------------------------------

RegisterNetEvent("brutal_ambulancejob:server:carry")
AddEventHandler("brutal_ambulancejob:server:carry", function(Target)
    TriggerClientEvent('brutal_ambulancejob:client:carry', Target, source)
end)

Citizen.CreateThread(function()
    for i = 1, #Config.HealItems do
        RUI(Config.HealItems[i].item, function(source)
            RemoveItem(source, Config.HealItems[i].item, 1)
            TriggerClientEvent('brutal_ambulancejob:client:usedHealItem', source, Config.HealItems[i].value, Config.HealItems[i].anim)
        end)
    end
end)

RegisterServerEvent('brutal_ambulancejob:server:RemoveMoney')
AddEventHandler('brutal_ambulancejob:server:RemoveMoney', function(account, amount)
    RemoveAccountMoney(source, account, amount)
end)

RegisterNetEvent("brutal_ambulancejob:server:puton")
AddEventHandler("brutal_ambulancejob:server:puton", function(Target)
    TriggerClientEvent('brutal_ambulancejob:client:puton', Target, source)
end)

RegisterNetEvent("brutal_ambulancejob:server:putonBED")
AddEventHandler("brutal_ambulancejob:server:putonBED", function(Target)
    TriggerClientEvent('brutal_ambulancejob:client:putonBED', Target)
end)

if Config['Core']:upper() == 'QBCORE' then
    QBCore = Core

    RegisterServerEvent("brutal_ambulancejob:server:SyncDutyStatus")
    AddEventHandler("brutal_ambulancejob:server:SyncDutyStatus", function(status)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end
        Player.Functions.SetJobDuty(status)

        TriggerEvent('QBCore:Server:SetDuty', src, status)
        TriggerClientEvent('QBCore:Client:SetDuty', src, status)
    end)
end

-----------------------------------------------------------
--------------------| discord webhook |--------------------
-----------------------------------------------------------

function DiscordWebhook(TYPE, MESSAGE)
    if Config.Webhooks.Use then
        local information = {
            {
                ["color"] = Config.Webhooks.Colors[TYPE],
                ["author"] = {
                    ["icon_url"] = 'https://i.ibb.co/KV7XX6m/brutal-scripts.png',
                    ["name"] = 'Brutal Ambulance Job - Logs',
                },
                ["title"] = '**'.. Config.Webhooks.Locale[TYPE] ..'**',
                ["description"] = MESSAGE,
                ["fields"] = {
                    {
                        ["name"] = Config.Webhooks.Locale['Time'],
                        ["value"] = os.date('%d/%m/%Y - %X')
                    }
                },
                ["footer"] = {
                    ["text"] = 'Brutal Scripts - Made by Keres & Dév',
                    ["icon_url"] = 'https://i.ibb.co/KV7XX6m/brutal-scripts.png'
                }
            }
        }
        PerformHttpRequest(GetWebhook(), function(err, text, headers) end, 'POST', json.encode({avatar_url = IconURL, username = BotName, embeds = information}), { ['Content-Type'] = 'application/json' })
    end
end