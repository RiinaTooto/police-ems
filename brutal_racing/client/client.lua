MenuOpen = false
CurrentMenu = nil
MemberID = nil
TodayRecords = {}
Top25Records = {}
PartyLists = {}
GetData = false 
FinishRace = true

Citizen.CreateThread(function()
	Citizen.Wait(1000*1)
	if GetCurrentResourceName() ~= 'brutal_racing' then
		while true do
			Citizen.Wait(1)
			print("^7This script was created by ^1Brutal Scripts!^7 Please rename back to: ^3'brutal_racing'")
		end
	end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1500)
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        sleep = 1000
        
        if MenuOpen == false and FinishRace then
            for k, v in pairs(Config.Races) do
                local distance = (coords - vector3(v.StartPlace.x, v.StartPlace.y, v.StartPlace.z))
                local marker = Config.Races[k].OpenMenuMarker
                if (#distance < marker.distance) then
                    sleep = 1
                    DrawMarker(marker.sprite, v.StartPlace.x, v.StartPlace.y, v.StartPlace.z-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, marker.sizes.x,marker.sizes.y,marker.sizes.z, v.MenuColor.r, v.MenuColor.g, v.MenuColor.b, marker.brightness, marker.upanddown, false, true, marker.rotation, nil, true)

                    if (#distance < marker.opendistance) then
                        sleep = 1
    
                        ShowHelpText(v.StartPlace.x, v.StartPlace.y, v.StartPlace.z, v.MenuText)
                        if IsControlJustReleased(0, 38) then
                            if IsInVehicle() == false then
                                if GetData then
                                    MenuOpenFunction(k)
                                elseif GetData == false then
                                    TriggerServerEvent('brutal_racing:server:ServerJoinGetData', k)
                                end
                            else
                                SendNotify(13)
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.Races) do
        local PlaceBlip = AddBlipForCoord(Config.Races[k].StartPlace.x,Config.Races[k].StartPlace.y,Config.Races[k].StartPlace.z)
        SetBlipSprite(PlaceBlip, v.Blip.sprite)
        SetBlipScale(PlaceBlip, v.Blip.size)
        SetBlipColour(PlaceBlip, v.Blip.color)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(k)
        EndTextCommandSetBlipName(PlaceBlip)
        SetBlipAsShortRange(PlaceBlip, true)
    end
end)

function MenuOpenFunction(Party)
    MenuOpen = true
    CurrentMenu = Party
    if PartyLists[Party].leader == GetPlayerServerId(PlayerId()) then
        SetNuiFocus(true,true)
        SendNUIMessage({
            action = "OpenStartMenu", 
            Party = Party, 
            TodayRecords = TodayRecords, 
            Top25Records = Top25Records, 
            PlayerName = GetPlayerNameFunction(),
            MyServerID = GetPlayerServerId(PlayerId()),
            PartyLists = PartyLists
        })
    elseif PartyLists[Party].created then
        SetNuiFocus(true,true)
        SendNUIMessage({
            action = "OpenJoinMenu", 
            Party = Party, 
            TodayRecords = TodayRecords, 
            Top25Records = Top25Records, 
            PlayerName = GetPlayerNameFunction(),
            MyServerID = GetPlayerServerId(PlayerId()),
            PartyLists = PartyLists,
            Vehicles = Config.Races[Party].Vehicles
        })
    else
        SetNuiFocus(true,true)
        SendNUIMessage({
            action = "OpenCreateMenu", 
            Party = Party, 
            TodayRecords = TodayRecords, 
            Top25Records = Top25Records, 
            MaxPlayers = #Config.Races[Party].StartPositions, 
            MinPlayers = Config.Races[Party].MinimumPlayerToStart, 
            MaxLaps = Config.Races[Party].MaximumLaps,
            PlayerName = GetPlayerNameFunction(),
            MyServerID = GetPlayerServerId(PlayerId()),
            PartyLists = PartyLists,
            Vehicles = Config.Races[Party].Vehicles
        })
    end
end

RegisterNetEvent('brutal_racing:client:ServerJoinGetData')
AddEventHandler('brutal_racing:client:ServerJoinGetData', function(NewTodayRecords, NewTop25Records, NewPartyLists, Party)
    TodayRecords = NewTodayRecords
    Top25Records = NewTop25Records
    PartyLists = NewPartyLists
    GetData = true
    SendNUIMessage({action = "Core", Core = Config.Core})
    MenuOpenFunction(Party)
end)

RegisterNetEvent('brutal_racing:client:ReopenPanel')
AddEventHandler('brutal_racing:client:ReopenPanel', function(Party, NewPartyLists)
    PartyLists = NewPartyLists
    if MenuOpen and CurrentMenu == Party then
        SendNUIMessage({
            action = "OpenCreateMenu", 
            Party = Party, 
            TodayRecords = TodayRecords, 
            Top25Records = Top25Records, 
            MaxPlayers = #Config.Races[Party].StartPositions, 
            MinPlayers = Config.Races[Party].MinimumPlayerToStart, 
            MaxLaps = Config.Races[Party].MaximumLaps,
            PlayerName = GetPlayerNameFunction(),
            MyServerID = GetPlayerServerId(PlayerId()),
            PartyLists = PartyLists,
            Vehicles = Config.Races[Party].Vehicles
        })
    end
end)

RegisterNetEvent('brutal_racing:client:ClosePanel')
AddEventHandler('brutal_racing:client:ClosePanel', function()
    if MenuOpen then
        SetNuiFocus(false,false)
        SendNUIMessage({action = "ClosePanel"})
        MenuOpen = false
    end
end)

RegisterNetEvent('brutal_racing:client:CreatedPartyMenuReopen')
AddEventHandler('brutal_racing:client:CreatedPartyMenuReopen', function(Party, NewPartyLists)
    PartyLists = NewPartyLists
    if MenuOpen and CurrentMenu == Party then
        if PartyLists[Party].leader ~= GetPlayerServerId(PlayerId()) then
            SendNUIMessage({
                action = "OpenJoinMenu", 
                Party = Party, 
                TodayRecords = TodayRecords, 
                Top25Records = Top25Records, 
                PlayerName = GetPlayerNameFunction(),
                MyServerID = GetPlayerServerId(PlayerId()),
                PartyLists = PartyLists,
                Vehicles = Config.Races[Party].Vehicles
            })
        else
            SendNUIMessage({
                action = "OpenStartMenu", 
                Party = Party, 
                TodayRecords = TodayRecords, 
                Top25Records = Top25Records, 
                PlayerName = GetPlayerNameFunction(),
                MyServerID = GetPlayerServerId(PlayerId()),
                PartyLists = PartyLists
            })
        end
    end
end)

RegisterNetEvent('brutal_racing:client:JoinParty')
AddEventHandler('brutal_racing:client:JoinParty', function(Party, MemberID, Rounds)
    TriggerEvent('brutal_racing:client:ClosePanel')

    Details = {
        Party = Party, 
        MemberID = MemberID, 
        StartRounds = Rounds,
        Rounds = Rounds,
        CheckPoint = 1,
        Time = 0,
        Times = {},
        Blips = {},
        PlayerBlips = {}
    }
    
    MyVehicle = CreateVeh(Config.Races[Details.Party].Vehicles[PartyLists[Party].createdata.Model].Model, Config.Races[Details.Party].StartPositions[Details.MemberID])
    SetBlips()

    -- Add Players Blip
    if Config.Races[Party].Blips.Racer.Use then
        for i = 1,#PartyLists[Details.Party].members do
            if GetPlayerServerId(PlayerId()) ~= PartyLists[Party].members[i].ID then
                local player = GetPlayerPed(GetPlayerFromServerId(PartyLists[Party].members[i].ID))

                local Blip = AddBlipForEntity(player)
                SetBlipSprite(Blip, Config.Races[Party].Blips.Racer.sprite)
                SetBlipScale(Blip, Config.Races[Party].Blips.Racer.size)
                SetBlipColour(Blip, Config.Races[Party].Blips.Racer.color)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.Races[Party].Blips.Racer.label)
                EndTextCommandSetBlipName(Blip)
                SetBlipAsShortRange(Blip, true)

                table.insert(Details.PlayerBlips, Blip)
            end
        end
    end
    
    SpecID = 1
    FinishRace = false
    DisableControls()
    Countdown(Config.Races[Details.Party].MenuColor.r, Config.Races[Details.Party].MenuColor.g, Config.Races[Details.Party].MenuColor.b, Config.Races[Details.Party].Countdown, true)
    Citizen.Wait(1000*Config.Races[Details.Party].Countdown)
    FreezeEntityPosition(MyVehicle, false)

    SendNUIMessage({action = "Rounds", Rounds = Details.Rounds})
    SendNUIMessage({action = "StartTimer"})

    Citizen.CreateThread(function()
        while FinishRace == false do
            Citizen.Wait(1000)
            Details.Time += 1
        end
    end)

    if Config.AfkKick.Use then
        local OLDCOORDS = GetEntityCoords(PlayerPedId())
        Citizen.CreateThread(function()
            while FinishRace == false do
                Citizen.Wait(1000*Config.AfkKick.CheckTime)
                CURRENTCOORDS = GetEntityCoords(PlayerPedId())

                if OLDCOORDS == CURRENTCOORDS then
                    TriggerServerEvent('brutal_racing:server:DropFromPartyAfk', Details.Party)

                    RemoveBlips()
                    RemoveRacersBlips()

                    SendNUIMessage({action = "StopTimer"})
                    FinishRace = true
                    DeleteCheckpoint(CheckPoint)
                    CheckPoint = nil
                    TriggerEvent('brutal_vehicleshop:client:utils:DeleteVehicle', MyVehicle)
                    DeleteVehicle(MyVehicle)
                    TeleportFunction(Config.Races[Details.Party].StartPlace.x, Config.Races[Details.Party].StartPlace.y, Config.Races[Details.Party].StartPlace.z)
                    SendNotify(16)
                end
                OLDCOORDS = CURRENTCOORDS
            end
        end)
    end

    Citizen.CreateThread(function()
        while FinishRace == false do
            sleep = 300
            local coords = GetEntityCoords(PlayerPedId())
            local c_coords = Config.Races[Details.Party].CheckPoints[Details.CheckPoint]
            local next_c_coords = Config.Races[Details.Party].CheckPoints[Details.CheckPoint+1]
            local distance = #(coords - vector3(c_coords.x, c_coords.y, c_coords.z))
            local CPM = Config.Races[Details.Party].CheckPointsMarkers

            if CheckPoint == nil and Config.Races[Details.Party].CheckPoints[Details.CheckPoint] ~= nil then
                if Config.Races[Details.Party].CheckPoints[Details.CheckPoint].type:upper() == 'CHECK' then
                    CheckPoint = CreateCheckpoint(CPM.CheckPoints.sprite, c_coords.x, c_coords.y, c_coords.z+CPM.CheckPoints.height, next_c_coords.x, next_c_coords.y, next_c_coords.z, CPM.CheckPoints.size, CPM.CheckPoints.r, CPM.CheckPoints.g, CPM.CheckPoints.b, 220, 0)
                    SetCheckpointRgba2(CheckPoint, CPM.CheckPoints.r2, CPM.CheckPoints.g2, CPM.CheckPoints.b2, 220)
                elseif Config.Races[Details.Party].CheckPoints[Details.CheckPoint].type:upper() == 'FINISH' then
                    if Details.Rounds > 1 then
                        CheckPoint = CreateCheckpoint(CPM.NewLap.sprite, c_coords.x, c_coords.y, c_coords.z+CPM.NewLap.height, 0, 0, 0, CPM.NewLap.size, CPM.NewLap.r, CPM.NewLap.g, CPM.NewLap.b, 220, 0)
                        SetCheckpointRgba2(CheckPoint, CPM.NewLap.r2, CPM.NewLap.g2, CPM.NewLap.b2, 220)
                    elseif Details.Rounds == 1 then
                        CheckPoint = CreateCheckpoint(CPM.Finish.sprite, c_coords.x, c_coords.y, c_coords.z+CPM.Finish.height, 0, 0, 0, CPM.Finish.size, CPM.Finish.r, CPM.Finish.g, CPM.Finish.a, 220, 0)
                        SetCheckpointRgba2(CheckPoint, CPM.Finish.r2, CPM.Finish.g2, CPM.Finish.b2, 220)
                    end
                end
            end

            if distance < 20 then
                sleep = 1
                if distance < CPM.AcceptDistance then
                    DeleteCheckpoint(CheckPoint)
                    CheckPoint = nil

                    if Config.Races[Details.Party].CheckPoints[Details.CheckPoint].type:upper() == 'CHECK' then
                        Details.CheckPoint += 1
                        SetBlips()
                    elseif Config.Races[Details.Party].CheckPoints[Details.CheckPoint].type:upper() == 'FINISH' then
                        if Details.Rounds > 1 then
                            Citizen.CreateThread(function()
                                NewLapNotify(Details.StartRounds-Details.Rounds+1, Details.StartRounds)
                            end)
                            Details.Rounds -= 1
                            Details.CheckPoint = 1
                            SetBlips()

                            table.insert(Details.Times, Details.Time)
                            SendNUIMessage({action = "Rounds", Rounds = Details.Rounds, BestTime = min(Details.Times, function(a,b) return a > b end), LapTime = Details.Time})
                            TriggerServerEvent('brutal_racing:server:MyTime', Details.Party, Details.Time)
                            Details.Time = 0
                        else
                            FinishRaceFunction()
                        end
                    end
                end
            end

            Citizen.Wait(sleep)
        end
    end)
end)

function SetBlips()
    RemoveBlips()
    for k,v in pairs(Config.Races[Details.Party].CheckPoints) do
        if k >= Details.CheckPoint then
            local Blip = AddBlipForCoord(v.x, v.y, v.z)

            if Details.Rounds == 1 and v.type:upper() == 'FINISH' then
                SetBlipSprite(Blip, Config.Races[Details.Party].Blips.Finish.sprite)
                SetBlipScale(Blip, Config.Races[Details.Party].Blips.Finish.size)
                SetBlipColour(Blip, Config.Races[Details.Party].Blips.Finish.color)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.Races[Details.Party].Blips.Finish.label)
                EndTextCommandSetBlipName(Blip)
            elseif Details.Rounds > 1 and v.type:upper() == 'FINISH' then
                SetBlipSprite(Blip, Config.Races[Details.Party].Blips.NewLap.sprite)
                SetBlipScale(Blip, Config.Races[Details.Party].Blips.NewLap.size)
                SetBlipColour(Blip, Config.Races[Details.Party].Blips.NewLap.color)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.Races[Details.Party].Blips.NewLap.label)
                EndTextCommandSetBlipName(Blip)
            else
                SetBlipSprite(Blip, Config.Races[Details.Party].Blips.Checkpoint.sprite)
                SetBlipScale(Blip, Config.Races[Details.Party].Blips.Checkpoint.size)
                SetBlipColour(Blip, Config.Races[Details.Party].Blips.Checkpoint.color)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.Races[Details.Party].Blips.Checkpoint.label)
                EndTextCommandSetBlipName(Blip)
            end

            if k == Details.CheckPoint and Config.Races[Details.Party].UseBlipRoute then
                SetBlipRoute(Blip,  true)
            end

            SetBlipAsShortRange(Blip, true)
            table.insert(Details.Blips, Blip)
        end
    end
end

function RemoveBlips()
    for k, v in pairs(Details.Blips) do
        RemoveBlip(v)
    end
end

function RemoveRacersBlips()
    for k, v in pairs(Details.PlayerBlips) do
        RemoveBlip(v)
    end
end

function SetRacersBlips()
    RemoveRacersBlips()
    if Config.Races[Details.Party].Blips.Racer.Use then
        for i = 1,#PartyLists[Details.Party].members do
            if GetPlayerServerId(PlayerId()) ~= PartyLists[Details.Party].members[i].ID then
                local player = GetPlayerPed(GetPlayerFromServerId(PartyLists[Details.Party].members[i].ID))

                local Blip = AddBlipForEntity(player)
                SetBlipSprite(Blip, Config.Races[Details.Party].Blips.Racer.sprite)
                SetBlipScale(Blip, Config.Races[Details.Party].Blips.Racer.size)
                SetBlipColour(Blip, Config.Races[Details.Party].Blips.Racer.color)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(Config.Races[Details.Party].Blips.Racer.label)
                EndTextCommandSetBlipName(Blip)
                SetBlipAsShortRange(Blip, true)

                table.insert(Details.PlayerBlips, Blip)
            end
        end
    end
end

RegisterNetEvent('brutal_racing:client:RefreshRecordsTables')
AddEventHandler('brutal_racing:client:RefreshRecordsTables', function(T1, T2)
    TodayRecords = T1
    Top25Records = T2
end)

RegisterNetEvent('brutal_racing:client:RefreshPartyLists')
AddEventHandler('brutal_racing:client:RefreshPartyLists', function(PL)
    PartyLists = PL

    if MenuOpen then
        SendNUIMessage({action = "RefreshPartyLists", PartyLists = PartyLists, MyServerID = GetPlayerServerId(PlayerId())})
    end
end)

-----------------------| RACE END FUNCTIONS |-----------------------

RegisterNetEvent('brutal_racing:client:SendRank')
AddEventHandler('brutal_racing:client:SendRank', function(RankTable, Party, NewPartyLists)
    PartyLists = NewPartyLists

    if RankTable.ID == GetPlayerServerId(PlayerId()) then
        FinishNotify(RankTable.Rank, SecondsToClock(sum(Details.Times)))
        if Config.Spectate then
            StartPlayerSpectate(Party)
        else
            TeleportFunction(Config.Races[Party].StartPlace.x, Config.Races[Party].StartPlace.y, Config.Races[Party].StartPlace.z)
        end
    else
        RankNotify(RankTable.NAME, RankTable.Rank)
        if FinishRace == false then SetRacersBlips() end

        if TargetSpectate == RankTable.ID then
            SpecID = 1
            StartPlayerSpectate(Party)
        elseif FinishRace then
            SendNUIMessage({action = "OpenSpec", name = PartyLists[Party].members[SpecID].NAME, ranks = PartyLists[Party].ranks, PartyLists = PartyLists})
        end
    end
end)

RegisterNetEvent('brutal_racing:client:ReopenOpenSpec')
AddEventHandler('brutal_racing:client:ReopenOpenSpec', function(Type, Party, PlayerName, PlayerID)
    LeftGameNotify(PlayerName)

    if Type == 'members' then
        SetRacersBlips()
    else
        if TargetSpectate == PlayerID then 
            SpecID = 1
            StartPlayerSpectate(Party)
        end
    end
end)

function FinishRaceFunction()
    table.insert(Details.Times, Details.Time)
    RemoveBlips()

    for k, v in pairs(Details.PlayerBlips) do
        RemoveBlip(v)
    end

    SendNUIMessage({action = "StopTimer"})

    TriggerServerEvent('brutal_racing:server:FinishRace', Details.Party, sum(Details.Times))
    TriggerServerEvent('brutal_racing:server:MyTime', Details.Party, Details.Time)
    FinishRace = true

    Citizen.Wait(50)
    TriggerEvent('brutal_vehicleshop:client:utils:DeleteVehicle', MyVehicle)
    DeleteVehicle(MyVehicle)
end

function CreatedParty(Party)
    Citizen.Wait(3000)
    Citizen.CreateThread(function()
        while PartyLists[Party].leader ~= 0 and PartyLists[Party].started == false do
            local coords = GetEntityCoords(PlayerPedId())
            local distance = #(coords - vector3(Config.Races[Party].StartPlace.x, Config.Races[Party].StartPlace.y, Config.Races[Party].StartPlace.z))
            if distance > 15 then
                SendNotify(17)
                TriggerServerEvent('brutal_racing:server:CancelParty', Party)
                break
            end
            Citizen.Wait(10000)
        end
    end)
end

RegisterNetEvent('brutal_racing:client:AdminKickedMe')
AddEventHandler('brutal_racing:client:AdminKickedMe', function()
    RemoveBlips()
    RemoveRacersBlips()

    SendNUIMessage({action = "StopTimer"})
    FinishRace = true
    DeleteCheckpoint(CheckPoint)
    CheckPoint = nil
    TriggerEvent('brutal_vehicleshop:client:utils:DeleteVehicle', MyVehicle)
    DeleteVehicle(MyVehicle)
    TeleportFunction(Config.Races[Details.Party].StartPlace.x, Config.Races[Details.Party].StartPlace.y, Config.Races[Details.Party].StartPlace.z)
    SendNotify(25)
end)