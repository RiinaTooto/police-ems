----------------------------------------------------------------------------------------------
------------------------------------| BRUTAL ATM ROBBERY |------------------------------------
----------------------------------------------------------------------------------------------

Config = {
    ['Core'] = 'ESX', --  -- ESX / QBCORE | Other core setting on the 'core' folder and the client and server utils.lua
    ['BrutalNotify'] = false, -- Buy here: (4€+VAT) https://store.brutalscripts.com | Or set up your own notify (notification function)
    ['GiveBlackMoney'] = true, -- true / false | ONLY IN ESX - in qb you can edit: core/server-core.lua >> line 61.
    ['NextRobbery'] = 5,  -- minutes
    ['Item'] = 'drill',
    ['Models'] = {'prop_atm_03', 'prop_fleeca_atm', 'prop_atm_02'},
    ['RequiredCopsCount'] = 0,
    ['CopJobs'] = {'police', 'sheriff', 'fbi'},
    ['BlipTime'] = 2, -- minutes
    ['Reward'] = { ['Min'] = 10000, ['Max'] = 20000 },
    ['Blips'] = {
        [1] = { label = 'ATM Robbery', size = 1.0, sprite = 161, colour = 1},
    },

    ['MoneySymbol'] = '$',
    ['Notification'] = {
        
        [1] =  {'ATM Robbery', "Robbery Failed!", 5000, 'info'},
        [2] =  {'ATM Robbery', "There is an ATM robbery in the City! Marked on the map!", 5000, 'info'},
        [3] =  {'ATM Robbery', "Not enough Cops in the City!", 5000, 'error'},
        [4] =  {'ATM Robbery', "You can't start the robbery now!", 5000, 'error'},
        [5] =  {'ATM Robbery', "You have got", 5000, 'info'},
    }
}
