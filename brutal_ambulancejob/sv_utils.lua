--local YourWebhook = 'FIVE LEAKS WEBHOOK'  -- help: https://docs.brutalscripts.com/site/others/discord-webhook

function GetWebhook()
    return YourWebhook
end

-- Buy here: (4€+VAT) https://store.brutalscripts.com
function notification(source, title, text, time, type)
    if Config.BrutalNotify then
        TriggerClientEvent('brutal_notify:SendAlert', source, title, text, time, type)
    else
        TriggerClientEvent('brutal_ambulancejob:client:DefaultNotify', text)
    end
end

function ClearPlayerInventory(source)
    if Config.Inventory:lower() == 'ox_inventory' then
        exports.ox_inventory:ClearInventory(source)
    elseif Config.Inventory:lower() == 'quasar_inventory' then
        local saveItems = {
            'id_card', -- Add here the items that you do NOT want to be deleted
            'phone',
        }
        exports['qs-inventory']:ClearInventory(source, saveItems)
        local weapons = exports['qs-inventory']:GetWeaponList()
        for k,v in pairs(weapons) do
            RemoveItem(source, v.name, 1)
        end
    elseif Config.Inventory:lower() == 'qb_inventory' then
        exports['qb-inventory']:ClearInventory(source)
    elseif Config['Core']:upper() == 'ESX' then
        local ESX = Core
        local xPlayer = ESX.GetPlayerFromId(source)
        for i=1, #xPlayer.inventory, 1 do
            if xPlayer.inventory[i].count > 0 then
                xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
            end
        end
    end
end

ESX = Core
QBCore = Core

if Config.Core:upper() == 'QBCORE' then
    RegisterNetEvent('hospital:server:resetHungerThirst', function()
        local Player = QBCore.Functions.GetPlayer(source)
    
        if not Player then return end
    
        Player.Functions.SetMetaData('hunger', 100)
        Player.Functions.SetMetaData('thirst', 100)
    
        TriggerClientEvent('hud:client:UpdateNeeds', source, 100, 100)
    end)
end

function StaffCheck(source, AdminGroups)
    local staff = false

    if Config.Core:upper() == 'ESX'then
        local player = Core.GetPlayerFromId(source)
        local playerGroup = player.getGroup()

        for i, Group in ipairs(AdminGroups) do
            if playerGroup == Group then
                staff = true
                break
            end
        end
    elseif Config.Core:upper() == 'QBCORE' then
        local player = Core.Functions.GetPlayer(source)

        for i, Group in ipairs(AdminGroups) do
            if Core.Functions.HasPermission(source, Group) or IsPlayerAceAllowed(source, Group) then
                staff = true
                break
            end
        end
    end

    return staff
end