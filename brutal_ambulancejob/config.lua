----------------------------------------------------------------------------------------------
----------------------------------| BRUTAL AMBULANCE JOB :) |---------------------------------
----------------------------------------------------------------------------------------------

--[[
Hi, thank you for buying our script, We are very grateful!

For help join our Discord server:     https://discord.gg/85u2u5c8q9
More informations about the script:   https://docs.brutalscripts.com
--]]

Config = {
    Core = 'ESX',  -- 'ESX' / 'QBCORE' | Other core setting on the 'core' folder.
    Inventory = 'ox_inventory', -- 'ox_inventory' / 'qb_inventory' / 'quasar_inventory' / 'chezza_inventory' / 'core_inventory' // Custom can be add in the cl_utils.lua!!!
    Billing = true, -- 'okokBilling' / 'esx_billing' / 'jaksam_billing' | false = immediate deduction from the player's bank account
    TextUI = 'okokTextUI', -- 'ox_lib' / 'okokTextUI' / 'ESXTextUI' / 'QBDrawText' // Custom can be add in the cl_utils.lua!!!
    ProgressBar = 'mythic_progbar', -- 'progressBars' / 'pogressBar' / 'mythic_progbar' // Custom can be add in the cl_utils.lua!!!
    BrutalNotify = true, -- Buy here: (4€+VAT) https://store.brutalscripts.com | Or set up your own notify >> cl_utils.lua
    SteamName = false, -- true = Steam name | false = character name
    DateFormat = '%d/%m/%Y', -- Date format
    CustomOutfitMenu = false, -- If it's true, it will open a custom outfit menu, what you can edit in the cl_utils.lua line 103.

    Bleeding = true,
    InjuredWalk = true,

    DeathTime = 1800, -- time til respawn is available
    WaitTime = 60,   -- time til the player bleeds out
    ReviveKey = 55,
    SaveDeathStatus = true,
    DeathAnimation = {use = true, animDictionary = 'dead', animName = 'dead_a'},
    ReviveReward = 5000, -- set to 0 if you don't want to use it.
    ClearInventory = true, -- true / false | Function editable: sv_utils.lua
    DisableControls = {170,168,24,257,25,263,32,34,31,30,45,22,44,37,23,288,289,170,167,73,199,59,71,72,36,47,264,257,140,141,142,143,75,249},
    ReviveCoords = {
        -- GABZ Hospital Coords
        -- vector4(-1868.55, -329.9, 50.19, 324.99),
        -- vector4(-1868.66, -323.28, 50.19, 144.14),

        -- QBCore Hospital Coords
        vector4(307.0526, -595.1317, 43.2841, 252.3702),
    },

    MedicerItems = {
        Head = 'head_bandage',
        Arms = 'arm_wrap',
        Legs = 'leg_plaster',
        Body = 'body_bandage',
        Bandage = 'bandage',
        Medikit = 'medikit',
    },

    HealItems = {
        {item = 'small_heal', value = 20, anim = false},
        {item = 'big_heal', value = 50, anim = true},
        -- more addable
    },

    Elevators = {
        {firstCoords = vector4(-1842.79, -341.59, 49.45, 320.1), secondCoords = vector4(-1836.88, -337.27, 53.78, 85.72)},
        {firstCoords = vector4(-1836.79, -337.2, 53.78, 316.32), secondCoords = vector4(-1843.34, -342.23, 49.45, 318.28)},
        {firstCoords = vector4(-1839.46, -335.04, 53.78, 136.21), secondCoords = vector4(-1829.06, -336.67, 84.06, 324.91)},
        {firstCoords = vector4(-1829.06, -336.67, 84.06, 324.91), secondCoords = vector4(-1839.46, -335.04, 53.78, 136.21)},
		{firstCoords = vector4(-1096.33, -850.36, 19.0, 217.82), secondCoords = vector4(-1066.47, -833.2, 27.04, 45.2)}, ---Policia
		{firstCoords = vector4(-1066.47, -833.2, 27.04, 45.2), secondCoords = vector4(-1096.33, -850.36, 19.0, 217.82)}, ---Policia
		{firstCoords = vector4(-1065.94, -834.14, 19.04, 215.4), secondCoords = vector4(-1096.09, -850.19, 30.76, 215.4)}, ---Policia2
		{firstCoords = vector4(-1096.09, -850.19, 30.76, 215.4), secondCoords = vector4(-1065.94, -834.14, 19.04, 215.4)}, ---Policia	2	
    },

    NPCMedicersOnlyAllowHelpWhenThereIsNoMedicsAvailable = true,
    NPCMedicers = {
        -- GABZ Hospital Coords
        {price = 1000, time = 30, coords = vector3(307.00, -595.09, 43.28), bedcoords = vector3(317.7270, -585.3508, 44.2040), bedheading = 338.0, prop = 'v_med_bed2'},

        -- QBCore Hospital Coords
       -- {price = 100, time = 30, coords = vector3(355.2057, -593.0265, 43.3150), bedcoords = vector3(354.23, -592.67, 42.88), bedheading = 338.0, prop = 'v_med_bed2'},
    },

    MedicItems = {
        ['ecg'] = {prop = 'prop_ld_purse_01', pos = {0.10, 0.0, 0.0, 0.0, 280.0, 53.0}},
        ['bag'] = {prop = 'prop_ld_bomb', pos = {0.39, 0.0, 0.0, 0.0, 266.0, 60.0}},
    },

    WheelchairVehicle = 'iak_wheelchair', -- DOWNLOAD FROM THE DOCS: https://docs.brutalscripts.com/
    Stretcher = {
        Vehicles = {
            {model = 'ambulance', xPos = 0.0, yPos = -3.0, zPos = 0.32, xRot = 0.0, yRot = 0.0, zRot = 90.0,      offsetY = -6.0 },
            {model = 'fdnyambo', xPos = 0.0, yPos = -3.0, zPos = 0.7, xRot = 0.0, yRot = 0.0, zRot = 0.0,         offsetY = -7.0 },
        },
    },

    AmbulanceJob = {
        Label = 'Pillbox Hospital',
        Job = 'ambulance', -- Job name

        Blip = {coords = vector3(307.0782, -595.1002, 43.2841), use = true, color = 2, sprite = 61, size = 0.75}, -- Job blip
        Marker = {use = true, marker = 20, rgb = {233, 88, 69}, bobUpAndDown = true, rotate = false},
        
        Duty = vector3(-1852.59, -338.56, 49.44), -- Duty ON / OFF coords
        DutyBlips = true, -- With this the cops can see the other cops in the map.

        Cloakrooms = {
            -- GABZ Hospital Coords
            vector3(303.9440, -600.4677, 43.2841),

            -- QBCore Hospital Coords
            --vector3(309.7783, -602.8839, 43.2918),

            
            -- You can add more...
        },

        Armorys = {
            -- GABZ Hospital Coords
             vector3(298.3326, -599.1968, 43.2841),

            -- QBCore Hospital Coords
            --vector3(298.6365, -599.4954, 43.2921),


            -- You can add more...
        },

        BossMenu = {
            grades = {3,4},
            coords = {
                -- GABZ Hospital Coords
                 vector3(341.4731, -589.8037, 43.2841),

                -- QBCore Hospital Coords
                -- vector3(310.4246, -599.5806, 43.2918),

            
                -- You can add more...
            },
        },

        Garages = {
            {
                Label = 'Garage I.',
                menu = vector3(296.0435, -614.3528, 43.4332),
                spawn = vector4(294.3420, -610.1584, 43.0086, 69.7166),
                deposit = vector3(294.3420, -610.1584, 43.0086),

                vehicles = {
                    ['ambulance'] = {
                        Label = 'Ambulance',
                        minRank = 0
                    },
                    
                    ['sprintermedic'] = {
                        Label = 'Sprinter Medic',
                        minRank = 0
                    },
                    
                    ['e63amgmedic'] = {
                        Label = 'Amg 63',
                        minRank = 1
                    },
                    
                    ['gle53medic'] = {
                        Label = 'AMG 53',
                        minRank = 2
                    },
                }
            },

            {
                Label = 'Helicopter Garage',
                menu = vector3(348.3348, -596.7404, 74.1617),
                spawn = vector4(350.9515, -587.6812, 74.1617, 255.0893),
                deposit = vector3(350.9514, -587.6812, 74.1617),

                vehicles = {
                    ['polmav'] = {
                        Label = 'Ambulance Helicopter',
                        minRank = 2
                    },
                }
            },

            -- You can add more...
        },

        Shop = {
            -- minGrade = The minimum grade to access to buy the item.
            {item = 'bandage', label = 'Bandage', price = 0, minGrade = 0},
            {item = 'medikit', label = 'Medikit', price = 0, minGrade = 0},
            {item = 'head_bandage', label = 'Head Bandage', price = 0, minGrade = 0},
            {item = 'arm_wrap', label = 'Arm Wrap', price = 0, minGrade = 0},
            {item = 'leg_plaster', label = 'Leg Plaster', price = 0, minGrade = 0},
            {item = 'body_bandage', label = 'Body Bandage', price = 0, minGrade = 0},
        },
    },

    Commands = {
        -- For cops

        Duty = {
            Use = true,
            Command = 'aduty', 
            Suggestion = 'Entering/Exiting duty'
        },

        JobMenu = {
            Command = 'emsjobmenu', 
            Control = 'HOME',  -- Controls list:  https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
            Suggestion = 'Open Job Menu'
        },

        MedicerMenu = {
            Command = 'medicmenu', 
            Suggestion = 'Open Medicer Menu'
        },

        MDT = {
            Use = true, -- if false here you can add your custom MDT >> cl_utils
            Command = 'emsmdt', 
            Control = 'END',  -- Controls list:  https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
            Suggestion = 'Open MDT Menu'
        },

        MedicCall = {
            Command = 'auxilio', 
            Suggestion = 'To get Medic help',
        },

        Bed = {
            Use = true,
            Command = 'bed', 
            Suggestion = 'To use the closest Bed',
            Objects = {'v_med_bed2', 'v_med_bed1', 'v_med_emptybed', -1519439119, -289946279}
        }
    },

    AdminCommands = {
        Revive = {Use = true, Command = 'revive', Suggestion = 'To revive a player', AdminGroups = {'superadmin', 'admin', 'mod', 'god'}}, -- /revive [me / all / PlayerID]
        Heal = {Use = true, Command = 'heal', Suggestion = 'To heal a player', AdminGroups = {'superadmin', 'admin', 'mod', 'god'}}, -- /heal [me / PlayerID]
        Kill = {Use = true, Command = 'kill', Suggestion = 'To kill a player', AdminGroups = {'superadmin', 'admin', 'mod', 'god'}}, -- /kill [me / PlayerID]
    },

    -----------------------------------------------------------
    -----------------------| TRANSLATE |-----------------------
    -----------------------------------------------------------

    MoneyForm = '$', -- Money form

    Locales = {
        CloakRoom = 'Wardrobe',
        GarageMenu = 'Garage Menu',

        Animations = 'Animations',
        Carry = 'Carry',
        Wheelchair = 'Wheelchair',
        Ecg = 'Ecg',
        Bag = 'Medbag',
        Stretcher = 'Stretcher',
        Spawn = 'Generate and delete',
        PutOn = 'put/lower',
        Bed = 'Putting/removing the bed',
        Push = 'Push and release',
        PutIn = 'put/remove',
        MDT = 'MDT',
        MedicerMenu = 'Medical menu',

        Colleague = 'Co-worker',
    },

    Progressbar = {
        DutyOFF = 'Duty OFF...',
        DutyON = 'Duty ON...',
    },

    Texts = {
        [1] = {'[E] - To open the clothing menu', 38},
        [2] = {'[E] - To open the armory menu', 38},
        [3] = {'[E] - To open the garage menu', 38},
        [4] = {'[E] - To deposit the vehicle', 38},
        [5] = {'[E] - To open the boss menu', 38},
        [6] = {'[E] - To use the elevator', 38},
        [7] = {'[E] - Enter service', '[E] - Go out of service', 38},
        [8] = {'[E] - To use the bed', 38},
        [9] = {'[X] - leave the bed', 73},
        [10] = {'[E] - medical treatment for', 38},
    },
    
    -- Notify function EDITABLE >> cl_utils.lua
    Notify = { 
        [1] = {"Ambulance Job", "You don't have permission!", 5000, "error"},
        [2] = {"Ambulance Job", "No vehicle available for your rank.", 5000, "error"},
        [3] = {"Ambulance Job", "Something is in the way!", 5000, "error"},
        [4] = {"Ambulance Job", "Invalid ID!", 5000, "error"},
        [5] = {"Ambulance Job", "Duty: <b>ON", 5000, "info"},
        [6] = {"Ambulance Job", "Duty: <b>OFF", 5000, "info"},
        [7] = {"Ambulance Job", "Citizen Call <br>Street: ", 6000, "info"},
        [8] = {"Ambulance Job", "You have successfully submitted!", 6000, "success"},
        [9] = {"Ambulance Job", "Please DO NOT SPAM!", 8000, "error"},
        [10] = {"Ambulance Job", "You must be on duty!", 8000, "error"},
        [11] = {"Ambulance Job", "You have successfully created a fine!", 6000, "success"},
        [12] = {"Ambulance Job", "You don't have enough money!", 5000, "error"},
        [13] = {"Ambulance Job", "You don't have the item!", 5000, "error"},
        [14] = {"Ambulance Job", "No one is near.", 5000, "error"},
        [15] = {"Ambulance Job", "No bed near you!", 5000, "error"},
        [16] = {"Ambulance Job", "You have successfully used the Heal Item!", 5000, "success"},
        [17] = {"Ambulance Job", "You do not need it!", 5000, "info"},
        [18] = {"Ambulance Job", "Somebody is already pushing the Stretcher!", 5000, "error"},
        [19] = {"Ambulance Job", "You paid for medical treatment:", 5000, "info"},
        [20] = {"Ambulance Job", "There isn't any stretcher near you!", 5000, "error"},
        [21] = {"Ambulance Job", "The vehicle is too far from you!", 5000, "error"},
        [22] = {"Ambulance Job", "The stretcher is in the vehicle!", 5000, "error"},
        [23] = {"Ambulance Job", "There is available medicer(s)!", 5000, "error"},
        [24] = {"Ambulance Job", "Revive Reward:", 5000, "success"},
        [25] = {"Ambulance Job", "This vehicle is not usable.", 5000, "error"},
        [26] = {"Ambulance Job", "The stretcher is not free!", 5000, "error"},
        [27] = {"Ambulance Job", "The bed is not free!", 5000, "error"},
        [28] = {"Ambulance Job", "<br>You spent:<b>", 5000, "info"},
        [29] = {"Ambulance Job", "You got: ", 5000, "info"},
        [30] = {"Ambulance Job", "You have to wait to heal again!", 5000, "error"},
    },
    
    Webhooks = {
        Use = true, -- Use webhooks? true / false
        Locale = {
            ['ItemBought'] = 'Item Bought',
            ['CallOpen'] = 'Call - Open',
            ['CallClose'] = 'Call - Close',
            ['InvoiceCreated'] = 'Invoice Created',
            ['AdminCommand'] = 'Admin Command',

            ['PlayerName'] = 'Player Name',
            ['AdminName'] = 'Admin Name',
            ['Identifier'] = 'Identifier',
            ['Items'] = 'Items',
            ['Text'] = 'Text',
            ['Callid'] = 'Call ID',
            ['Coords'] = 'Coords',
            ['Assistant'] = 'Assistant',
            ['CloseReason'] = 'Close Reason',
            ['Receiver'] = 'Receiver',
            ['Amount'] = 'Amount',
            ['Job'] = 'Job',
            ['Reason'] = 'Reason',
            ['Street'] = 'Street',
            ['Coords'] = 'Coords',
            ['Command'] = 'Command',

            ['Time'] = 'Time ⏲️'
        },

        -- To change a webhook color you need to set the decimal value of a color, you can use this website to do that - https://www.mathsisfun.com/hexadecimal-decimal-colors.html
        Colors = {
            ['ItemBought'] = 10155240,
            ['CallOpen'] = 3145631, 
            ['CallClose'] = 16711680,
            ['InvoiceCreated'] = 10155240,
            ['AdminCommand'] = 10155240,
        }
    },

    -----------------------------------------------------------
    -----------------------| UNIFORMS |------------------------
    -----------------------------------------------------------

    CitizenWear = {label = "Citizen Wear"},

    Uniforms = {
        {
            label = 'Ambulance Dress', -- Uniform Label
            jobs = {
                -- Job = job name, grades = grades
                {job = 'ambulance', grades = {0,1,2,3}},
                -- More jobs
            },
            male = {
                ['t-shirt'] = {item = 15, texture = 0},
                ['torso2'] = {item = 13, texture = 3},
                ['arms'] = {item = 92, texture = 0},
                ['pants'] = {item = 24, texture = 5},
                ['shoes'] = {item = 9, texture = 0},
                ['hat'] = {item = 8, texture = 0},
                ['accessory'] = {item = 0, texture = 0},
                ['ear'] = {item = -1, texture = 0},
                ['decals'] = {item = 0, texture = 0},
                ['mask'] = {item = 0, texture = 0}
            },
            female = {
                ['t-shirt'] = {item = 75, texture = 3},
                ['torso2'] = {item = 73, texture = 0},
                ['arms'] = {item = 14, texture = 0},
                ['pants'] = {item = 37, texture = 5},
                ['shoes'] = {item = 1, texture = 0},
                ['hat'] = {item = -1, texture = 0},
                ['accessory'] = {item = 0, texture = 0},
                ['ear'] = {item = -1, texture = 0},
                ['decals'] = {item = 0, texture = 0},
                ['mask'] = {item = 0, texture = 0}
            },
        },
    },
}