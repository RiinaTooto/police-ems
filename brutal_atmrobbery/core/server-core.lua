Core = nil

if Config['Core']:upper() == 'ESX' then
--------------------------------------------------------------------------
---------------------------------| ESX |----------------------------------
--------------------------------------------------------------------------

    Core = exports['es_extended']:getSharedObject()

    RESCB = Core.RegisterServerCallback
    GETPFI = Core.GetPlayerFromId
    RUI = Core.RegisterUsableItem

    function GetPlayersFunction()
        return Core.GetPlayers()
    end

    function AddMoneyFunction(source, amount)
        local xPlayer = GETPFI(source)

        if Config['GiveBlackMoney'] then
            xPlayer.addAccountMoney('black_money', amount)
        else
            xPlayer.addAccountMoney('money', amount)
        end
    end

    function GetPlayerJobFunction(source)
        local xPlayer = GETPFI(source)
        PlayerJob = xPlayer.job.name
        return PlayerJob
    end

    function RemoveItem(source, item, amount)
        local xPlayer = GETPFI(source)
        xPlayer.removeInventoryItem(item, amount)
    end

    function GetIdentifierFunction(source)
        local xPlayer = GETPFI(source)
        return xPlayer.identifier
    end

elseif Config['Core']:upper() == 'QBCORE' then
--------------------------------------------------------------------------
--------------------------------| QBCORE |--------------------------------
--------------------------------------------------------------------------

    Core = exports['qb-core']:GetCoreObject()
    
    RESCB = Core.Functions.CreateCallback
    GETPFI = Core.Functions.GetPlayer
    RUI = Core.Functions.CreateUseableItem

    function GetPlayersFunction()
        return Core.Functions.GetPlayers()
    end

    function AddMoneyFunction(source, amount)
        local xPlayer = GETPFI(source)
        xPlayer.Functions.AddMoney('cash', amount)
    end

    function GetPlayerJobFunction(source)
        local xPlayer = GETPFI(source)
        PlayerJob = xPlayer.PlayerData.job.name
        return PlayerJob
    end

    function RemoveItem(source, item, amount)
        local xPlayer = GETPFI(source)
        xPlayer.Functions.RemoveItem(item, amount)
    end

    function GetIdentifierFunction(source)
        local xPlayer = GETPFI(source)
        return xPlayer.PlayerData.citizenid
    end
    
end