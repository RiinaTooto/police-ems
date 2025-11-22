PartyLists = {}
BlackList = {}

Citizen.CreateThread(function()
    for k,v in pairs(Config.Races) do
        PartyLists[k] = {
            created = false,
            PartyImg = v.Image,
            MenuColor = v.MenuColor,
            createdata = {},
            started = false,
            leader = 0,
            waitlist = {},
            members = {},
            ranks = {}
        }
    end
end)

function ClearParty(Party)
    PartyLists[Party] = {
        created = false,
        PartyImg = Config.Races[Party].Image,
        MenuColor = Config.Races[Party].MenuColor,
        createdata = {},
        started = false,
        leader = 0,
        waitlist = {},
        members = {},
        ranks = {}
    }
    TriggerClientEvent('brutal_racing:client:ReopenPanel', -1, Party, PartyLists)
end

function SendNotify(Number, source)
    if source ~= nil and source ~= 0 then
        notification(source, Config.Notify[Number][1], Config.Notify[Number][2], Config.Notify[Number][3], Config.Notify[Number][4])
    end
end

function RefreshPartyLists(NUM)
    TriggerClientEvent('brutal_racing:client:RefreshPartyLists', -1, PartyLists)
end

function RemoveMoney(source, amount)
    if amount > 0 and Config.Core:upper() ~= 'STANDALONE' then
        return RemoveMoneyFunction(source, amount)
    else
        return true
    end
end

function AddMoney(source, amount)
    if amount > 0 and Config.Core:upper() ~= 'STANDALONE' then
        AddMoneyFunction(source, amount)
    end
end

-----------------------| CREATE PARTY |-----------------------

RegisterNetEvent('brutal_racing:server:CreateParty')
AddEventHandler('brutal_racing:server:CreateParty', function(Party, MaxPlayers, MinPlayers, MaxLaps, Accessibility, MoneyAmount, AccValue, Model)
    if PartyLists[Party] ~= nil then
        if PartyLists[Party].created == false then
            if RemoveMoney(source, MoneyAmount) then
                PartyLists[Party].created = true
                PartyLists[Party].createdata = {MaxPlayers = MaxPlayers, MinPlayers = MinPlayers, MaxLaps = MaxLaps, Accessibility = Accessibility, AccessibilityTEXT = AccValue, MoneyAmount = MoneyAmount, Model = Model}
                PartyLists[Party].leader = source
                table.insert(PartyLists[Party].members, {ID = source, NAME = GetPlayerNameFunction(source)})
                SendNotify(7, source)
                TriggerClientEvent('brutal_racing:client:CreatedPartyMenuReopen', -1, Party, PartyLists)
            else
                SendNotify(6, source)
            end
        else
            TriggerClientEvent('brutal_racing:client:ClosePanel', source)
            SendNotify(5, source)
        end
    end
end)

-----------------------| JOIN PARTY |-----------------------

RegisterNetEvent('brutal_racing:server:JoinParty')
AddEventHandler('brutal_racing:server:JoinParty', function(Party)
    if PartyLists[Party] ~= nil and PartyLists[Party].created then
        if PartyLists[Party].started == false then
            if #PartyLists[Party].members < PartyLists[Party].createdata.MaxPlayers then
                inMemberList = false
                inWaitList = false
                for k,v in pairs(PartyLists[Party].members) do
                    if v.ID == source then
                        inMemberList = true
                    end
                end

                for k,v in pairs(PartyLists[Party].waitlist) do
                    if v.ID == source then
                        inWaitList = true
                    end
                end

                if inMemberList == false then
                    if inWaitList == false then
                        if PartyLists[Party].createdata.Accessibility == 'open' then
                            if RemoveMoney(source, PartyLists[Party].createdata.MoneyAmount) then
                                table.insert(PartyLists[Party].members, {ID = source, NAME = GetPlayerNameFunction(source)})
                                SendNotify(7, source)
                                RefreshPartyLists(3)
                            else
                                SendNotify(6, source)
                            end
                        else
                            table.insert(PartyLists[Party].waitlist, {ID = source, NAME = GetPlayerNameFunction(source)})
                            SendNotify(8, source)
                            RefreshPartyLists(4)
                        end
                    else
                        SendNotify(12, source)
                    end
                else
                    SendNotify(3, source)
                end
            else
                SendNotify(2, source)
            end
        else
            SendNotify(1, source)
        end
    end
end)

-----------------------| ACCEPT JOIN |-----------------------

RegisterNetEvent('brutal_racing:server:AcceptJoin')
AddEventHandler('brutal_racing:server:AcceptJoin', function(Party, PlayerID)
    if #PartyLists[Party].members < PartyLists[Party].createdata.MaxPlayers then
        if RemoveMoney(PlayerID, PartyLists[Party].createdata.MoneyAmount) then
            table.insert(PartyLists[Party].members, {ID = PlayerID, NAME = GetPlayerNameFunction(PlayerID)})
            SendNotify(9, PlayerID)

            for k,v in pairs(PartyLists) do
                for _k,_v in pairs(PartyLists[k].waitlist) do
                    if _v.ID == PlayerID then
                    table.remove(PartyLists[k].waitlist, _k)
                    end
                end
            end

            RefreshPartyLists(5)
        else
            SendNotify(6, PlayerID)
        end
    else
        SendNotify(2, source)
    end
end)

-----------------------| KICK PLAYER |-----------------------

RegisterNetEvent('brutal_racing:server:KickPlayer')
AddEventHandler('brutal_racing:server:KickPlayer', function(Party, PlayerID)
    for k,v in pairs(PartyLists[Party].waitlist) do
        if v.ID == PlayerID then
            table.remove(PartyLists[Party].waitlist, k)
            SendNotify(10, PlayerID)
        end
    end

    for k,v in pairs(PartyLists[Party].members) do
        if v.ID == PlayerID then
            table.remove(PartyLists[Party].members, k)
            SendNotify(11, PlayerID)

            if PartyLists[Party].created and PartyLists[Party].started == false then
                AddMoney(PlayerID, PartyLists[Party].createdata.MoneyAmount)
            end
        end
    end

    RefreshPartyLists(6)
end)

-----------------------| START PARTY |-----------------------

RegisterNetEvent('brutal_racing:server:StartParty')
AddEventHandler('brutal_racing:server:StartParty', function(Party)
    if PartyLists[Party] ~= nil then
        if PartyLists[Party].started == false then
            if PartyLists[Party].createdata.MinPlayers ~= nil then
                if #PartyLists[Party].members >= PartyLists[Party].createdata.MinPlayers then
                    PartyLists[Party].started = true
                    for i = 1,#PartyLists[Party].members do
                        TriggerClientEvent('brutal_racing:client:JoinParty', PartyLists[Party].members[i].ID, Party, i, PartyLists[Party].createdata.MaxLaps)
                    end
                    RefreshPartyLists(7)
                else
                    SendNotify(4, source)
                end
            end
        else
            SendNotify(1, source)
        end
    end
end)

function FinishParty(Party)
    if #PartyLists[Party].members < 1 and PartyLists[Party].started then
        PartyLists[Party].started = false
        Citizen.Wait(500)
        ClearParty(Party)
    end
end

-----------------------| FINISH PARTY |-----------------------

RegisterNetEvent('brutal_racing:server:FinishRace')
AddEventHandler('brutal_racing:server:FinishRace', function(Party, TotalTime)
    local MyRank = #PartyLists[Party].ranks+1
    table.insert(PartyLists[Party].ranks, {Rank = MyRank, TotalTime = TotalTime, ID = source, NAME = GetPlayerNameFunction(source)})
    PrizeAmount = PartyLists[Party].createdata.MoneyAmount*#PartyLists[Party].members
    if MyRank == 1 and PrizeAmount > 0 then 
        AddMoney(source, PrizeAmount)
        notification(source, Config.Notify[23][1], ' '.. Config.Notify[23][2] ..''..PrizeAmount..' '.. Config.MoneyForm ..'', Config.Notify[23][3], Config.Notify[23][4])
    end

    DropMeFromAllParty(source)
        for i = 1,#PartyLists[Party].members do 
            TriggerClientEvent('brutal_racing:client:SendRank', PartyLists[Party].members[i].ID, PartyLists[Party].ranks[MyRank], Party, PartyLists) 
        end
        for i = 1,#PartyLists[Party].ranks do 
            TriggerClientEvent('brutal_racing:client:SendRank', PartyLists[Party].ranks[i].ID, PartyLists[Party].ranks[MyRank], Party, PartyLists) 
        end
    FinishParty(Party)
end)

--------------------| CANCEL PARTY |--------------------

RegisterNetEvent('brutal_racing:server:CancelParty')
AddEventHandler('brutal_racing:server:CancelParty', function(Party)
    if PartyLists[Party].started == false then
        for i = 1,#PartyLists[Party].members do
            AddMoney(PartyLists[Party].members[i].ID, PartyLists[Party].createdata.MoneyAmount)
            TriggerClientEvent('brutal_racing:client:ReopenPanel', PartyLists[Party].members[i].ID, Party, PartyLists)
        end
        ClearParty(Party)
    end
end)

--------------------| DROP EVENT |--------------------

function DropMeFromAllParty(source)
    for k,v in pairs(PartyLists) do
        for _k,_v in pairs(PartyLists[k].members) do
            if _v.ID == source then
            table.remove(PartyLists[k].members, _k)
            end
		end
	end
    RefreshPartyLists(9)
end

AddEventHandler('playerDropped', function()
    local InParty = nil
    for k,v in pairs(PartyLists) do
        for _k,_v in pairs(PartyLists[k].members) do
            if _v.ID == source then
                InParty = k
            end
		end
	end
    
    if InParty ~= nil and PartyLists[InParty].started == false then
        ClearParty(InParty)
    end
    
	DropMeFromAllParty(source)
end)

--------------------| DROP EVENT |--------------------

RegisterNetEvent('brutal_racing:server:LeaveParty')
AddEventHandler('brutal_racing:server:LeaveParty', function(Party)
    if PartyLists[Party].started == false and PartyLists[Party].createdata.MoneyAmount ~= nil then
        AddMoney(source, PartyLists[Party].createdata.MoneyAmount)
        DropMeFromAllParty(source)
    else
        SendNotify(14, source)
    end
end)

RegisterNetEvent('brutal_racing:server:DropFromPartyAfk')
AddEventHandler('brutal_racing:server:DropFromPartyAfk', function(Party)
    DropMeFromAllParty(source)
    for i = 1,#PartyLists[Party].members do
        TriggerClientEvent('brutal_racing:client:ReopenOpenSpec', PartyLists[Party].members[i].ID, 'members', Party, GetPlayerNameFunction(source), source)
    end
    for i = 1,#PartyLists[Party].ranks do
        TriggerClientEvent('brutal_racing:client:ReopenOpenSpec', PartyLists[Party].ranks[i].ID, 'ranks', Party, GetPlayerNameFunction(source), source)
    end
    FinishParty(Party)
end)

-----------------------| RECORDS |-----------------------
TodayRecords = {}
Top25Records = json.decode(LoadResourceFile(GetCurrentResourceName(), "server/top25.json"))

RegisterNetEvent('brutal_racing:server:ServerJoinGetData')
AddEventHandler('brutal_racing:server:ServerJoinGetData', function(Party)
    TriggerClientEvent('brutal_racing:client:ServerJoinGetData', source, TodayRecords, Top25Records, PartyLists, Party)
end)

RegisterNetEvent('brutal_racing:server:MyTime')
AddEventHandler('brutal_racing:server:MyTime', function(Party, Time)
    Time += math.random(000001, 499999)/1000000
    MyName = GetPlayerNameFunction(source)
    HaveTodayRecord = false
    HaveTop25Record = false
    ---- | TODAY | ----

    for k,v in pairs(TodayRecords) do
        if v.name == MyName and v.party == Party then
            HaveTodayRecord = true
            if Time < v.time then
                v.time = Time
            end
        end 
    end

    if HaveTodayRecord == false then 
        table.insert(TodayRecords, {time = Time, name = MyName, party = Party}) 
    end

   ---- | TOP 25 | ----

    for k,v in pairs(Top25Records) do
        if v.name == MyName and v.party == Party then
            HaveTop25Record = true
        end 
    end
    
    if HaveTop25Record ~= true then
        Top25RecordsCount = 0

        for i = 1,#Top25Records do
            if Top25Records[i].party == Party then
                Top25RecordsCount += 1
            end
        end

        if Top25RecordsCount < 25 then
            table.insert(Top25Records, {time = Time, party = Party, name = MyName, date = os.date('%d/%m/%Y')})
            SaveResourceFile(GetCurrentResourceName(), "server/top25.json", json.encode(Top25Records), -1)
        else
            for k,v in pairs(Top25Records) do
                if Less == nil then
                    Less = v.time 
                end
        
                if v.time < Less then
                    Less = v.time
                end 
            end

            for k,v in pairs(Top25Records) do
                if v.party == Party then
                    if v.name == MyName then
                        if v.time == Less then
                            if Time < v.time then
                                v.time = Time
                                v.name = MyName
                                v.party = Party
                                v.date = os.date('%d/%m/%Y')
                                SaveResourceFile(GetCurrentResourceName(), "server/top25.json", json.encode(Top25Records), -1)
                            end
                        end 
                    end
                end
            end
        end
    else
        for k,v in pairs(Top25Records) do
            if v.party == Party then
                if v.name == MyName then
                    if Time < v.time then
                        v.time = Time
                        v.name = MyName
                        v.party = Party
                        v.date = os.date('%d/%m/%Y')
                        SaveResourceFile(GetCurrentResourceName(), "server/top25.json", json.encode(Top25Records), -1)
                    end
                end
            end 
        end
    end

    TriggerClientEvent('brutal_racing:client:RefreshRecordsTables', -1, TodayRecords, Top25Records)
end)

-----------------------------------------------------------
---------------------| ADMIN COMMANDS |--------------------
-----------------------------------------------------------

RegisterCommand(Config.AdminCommands.ShowRaces.Command, function(source, args, rawCommand)
    if Config.AdminCommands.ShowRaces.Use then
        local Text = ''
        for k,v in pairs(Config.Races) do
            if Text == '' then
                Text = k
            else
                Text = Text..', '..k
            end
        end
        if source == 0 then
            print(Config.Notify[18][2]..' '..Text)
        else
            if StaffCheck(source) then
                notification(source, Config.Notify[18][1], Config.Notify[18][2]..' '..Text, Config.Notify[18][3], Config.Notify[18][4])
            else
                SendNotify(19, source)
            end
        end
    end
end, false)

RegisterCommand(Config.AdminCommands.CloseParty.Command, function(source, args, rawCommand)
    if Config.AdminCommands.CloseParty.Use then
        local Party = string.sub(rawCommand, #Config.AdminCommands.CloseParty.Command+2)

        if source == 0 then
            if Config.Races[Party] ~= nil then 
                TriggerEvent('brutal_racing:server:CancelParty', Party)
            end
        else
            if StaffCheck(source) then
                if Config.Races[Party] ~= nil then 
                    TriggerEvent('brutal_racing:server:CancelParty', Party)
                    SendNotify(22, source)
                else
                    SendNotify(21, source)
                end
            else
                SendNotify(19, source)
            end
        end
    end
end, false)

RegisterCommand(Config.AdminCommands.KickPlayer.Command, function(source, args, rawCommand)
    if Config.AdminCommands.KickPlayer.Use then
        local PlayerID = tonumber(string.sub(rawCommand, #Config.AdminCommands.KickPlayer.Command+2))

        if source == 0 then
            PlayerAdminKick(PlayerID, source)
        else
            if StaffCheck(source) then
                PlayerAdminKick(PlayerID, source)
            else
                SendNotify(19, source)
            end
        end
    end
end, false)

function PlayerAdminKick(PlayerID, AdminID)
    if GetPlayerPing(PlayerID) ~= 0 then
        PartyValue = nil
        for k,v in pairs(PartyLists) do
            for _k,_v in pairs(PartyLists[k].members) do
                if _v.ID == PlayerID then
                    PartyValue = k
                end
            end
        end

        if PartyValue ~= nil then
            DropMeFromAllParty(PlayerID)
            TriggerClientEvent('brutal_racing:client:AdminKickedMe', PlayerID)
            for i = 1,#PartyLists[PartyValue].members do
                TriggerClientEvent('brutal_racing:client:ReopenOpenSpec', PartyLists[PartyValue].members[i].ID, 'members',PartyValue, GetPlayerNameFunction(PlayerID), PlayerID)
            end
            for i = 1,#PartyLists[PartyValue].ranks do
                TriggerClientEvent('brutal_racing:client:ReopenOpenSpec', PartyLists[PartyValue].ranks[i].ID, 'ranks', PartyValue, GetPlayerNameFunction(PlayerID), PlayerID)
            end
            FinishParty(PartyValue)
            SendNotify(26, AdminID)
        else
            SendNotify(24, AdminID)
        end
    else
        SendNotify(20, AdminID)
    end
end