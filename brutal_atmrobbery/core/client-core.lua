Core = nil

if Config['Core']:upper() == 'ESX' then
    
    Core = exports['es_extended']:getSharedObject()
    TSCB = Core.TriggerServerCallback
    PlayerDiedHealth = 0

elseif Config['Core']:upper() == 'QBCORE' then

    Core = exports['qb-core']:GetCoreObject()
    TSCB = Core.Functions.TriggerCallback
    PlayerDiedHealth = 100

end
