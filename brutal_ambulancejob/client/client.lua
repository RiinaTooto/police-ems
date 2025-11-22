-----------------------------------------------------------
--------------------| Get Player Data |--------------------
-----------------------------------------------------------

PlayerData = {}
PlayerData.job = {name = '', label = ''}
PlayerData.medicer = false
PlayerData.deathStatus = false
PlayerData.callSent = false
PlayerData.reviveRequest = false
PlayerData.reviveRequestTime = 0
PlayerData.deathTime = 0
PlayerData.hospitalRevive = true
InDuty = false
InAnimation = false
InCarry = false
InTreatment = false
StretcherData = {pushing = false, puton = nil}
nearMarker = false
nearMarker2 = true
ShowText = false
ShowText2 = false
RevivedByMedicer = false
SpawnCoords = nil
SpamDuty = false
InPutSpam = false
InDoorNear = false
CallBlips = {}
MedicerBlips = {}
AvailableMedicers = 0
InvoicesTargetID = nil
MedicerMenuTargetID = nil
wheelchair = nil
InHealing = false

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
		GetPlayerData()
    end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        local ped = GetPlayerPed(-1)
        if InCarry or IsEntityAttachedToAnyPed(ped) or IsEntityAttachedToAnyVehicle(ped) or IsEntityAttachedToAnyObject(ped) then
            DetachEntity(ped, true, false)
            ClearPedTasks(ped)
        end

        if DoesEntityExist(tab) then
            DeleteEntity(tab)
        end

        if DoesEntityExist(dutyprop) then
            DeleteEntity(dutyprop)
            DeleteEntity(dutyprop2)
        end

        if InjuredWalk then
            ResetPedMovementClipset(ped)
            ResetPedWeaponMovementClipset(ped)
            ResetPedStrafeClipset(ped)
        end

        if DoesEntityExist(MedicerBag) then
            DeleteEntity(MedicerBag)
        end

        if DoesEntityExist(MedicerEcg) then
            DeleteEntity(MedicerEcg)
        end

        if DoesEntityExist(str) then
            DeleteEntity(str)
        end

        if DoesEntityExist(wheelchair) then
            DeleteEntity(wheelchair)
        end

        TextUIFunction('hide')
	end
end)

if Config['Core']:upper() == 'QBCORE' then
    AddEventHandler('gameEventTriggered', function(event, data)
        if event == "CEventNetworkEntityDamage" then
            local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
            if not IsEntityAPed(victim) then return end
            if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
                if not PlayerData.deathStatus then
                    TriggerServerEvent('onPlayerDeath')
                end
            end
        end
    end)
end

RegisterNetEvent(LoadedEvent)
AddEventHandler(LoadedEvent, function(playerData)
    Citizen.Wait(5000)
    GetPlayerData()
end)

function GetPlayerData()
    exports.spawnmanager:setAutoSpawn(false)

    TSCB('brutal_ambulancejob:server:getDeathStatus', function(data)
        PlayerData.name = data.name
        if data.death then
            TriggerEvent('brutal_ambulancejob:client:onPlayerDeath')
        end
    end)

    if Config.AmbulanceJob.Blip.use then
        local blip = AddBlipForCoord(Config.AmbulanceJob.Blip.coords)
        SetBlipSprite(blip, Config.AmbulanceJob.Blip.sprite)
        SetBlipColour(blip,Config.AmbulanceJob.Blip.color)
        SetBlipScale(blip, Config.AmbulanceJob.Blip.size)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Config.AmbulanceJob.Label)
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, true)
    end

    local jobdata = GetPlayerJobDatas()

    while jobdata == nil do
        Citizen.Wait(1)
    end

    PlayerData.job = {}
    PlayerData.job.name = jobdata.name
    PlayerData.job.label = jobdata.label

    if Config['Core']:upper() == 'ESX' then
        PlayerData.job.grade = jobdata.grade
        PlayerData.job.grade_label = jobdata.grade_label
        PlayerData.job.salary = jobdata.grade_salary
    elseif Config['Core']:upper() == 'QBCORE' then
        PlayerData.job.grade = jobdata.grade.level
        PlayerData.job.grade_label = jobdata.grade.name
        PlayerData.job.salary = jobdata.payment
    end

    if isPlayerMedicer() then
        if Config['Core']:upper() == 'QBCORE' then
            TriggerServerEvent('brutal_ambulancejob:server:SyncDutyStatus', InDuty)
        end

        inAmbulanceJob()
    end
end

RegisterNetEvent(JobUpdateEvent, function(NewJob)
    local medicbefore = false
    if isPlayerMedicer() then
        medicbefore = true
    end

    PlayerData.job.name = NewJob.name
    PlayerData.job.label = NewJob.label

    if Config['Core']:upper() == 'ESX' then
        PlayerData.job.grade = NewJob.grade
        PlayerData.job.grade_label = NewJob.grade_label
        PlayerData.job.salary = NewJob.grade_salary
    elseif Config['Core']:upper() == 'QBCORE' then
        PlayerData.job.grade = NewJob.grade.level
        PlayerData.job.grade_label = NewJob.grade.name
        PlayerData.job.salary = NewJob.payment
    end

    if isPlayerMedicer() and not medicbefore then
        inAmbulanceJob()
    elseif not isPlayerMedicer() then
        PlayerData.medicer = false
        InDuty = false
    end
end)

function isPlayerMedicer()
    PlayerData.medicer = false
    if Config.AmbulanceJob.Job == PlayerData.job.name then
        PlayerData.medicer = true
    end

    return PlayerData.medicer
end

-----------------------------------------------------------
----------------------| While loops |----------------------
-----------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        sleep = 1500
        local nearMarker2 = false
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for k,v in pairs(Config.Elevators) do
            if #(playerCoords - vector3(v.firstCoords[1], v.firstCoords[2], v.firstCoords[3])) < 10.0 then
                sleep = 1
                if Config.AmbulanceJob.Marker.use then DrawMarker(Config.AmbulanceJob.Marker.marker, vector3(v.firstCoords[1], v.firstCoords[2], v.firstCoords[3]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, Config.AmbulanceJob.Marker.rgb[1], Config.AmbulanceJob.Marker.rgb[2], Config.AmbulanceJob.Marker.rgb[3], 255, Config.AmbulanceJob.Marker.bobUpAndDown, true, 2, Config.AmbulanceJob.Marker.rotate, nil, false) end
                if #(playerCoords - vector3(v.firstCoords[1], v.firstCoords[2], v.firstCoords[3])) < 1.5 then
                    sleep = 5

                    nearMarker2 = true
                    if not ShowText2 then
                        TextUIFunction('open', Config.Texts[6][1])
                        ShowText2 = true
                    end
                    
                    if IsControlJustReleased(0, Config.Texts[6][2]) then
                        DoScreenFadeOut(400)
                        Citizen.Wait(400)
                        SetEntityCoordsNoOffset(playerPed, v.secondCoords, false, false, false)
                        SetEntityHeading(playerPed, v.secondCoords.w)

                        -- Camera Rotation Fix
                        SetGameplayCamRelativeHeading(GetEntityHeading(playerPed)-v.secondCoords.w)
                        SetGameplayCamRelativePitch(90, 1.0)

                        DoScreenFadeIn(600)
                    end
                end
            end
        end

        for k,v in pairs(Config.NPCMedicers) do
            if #(playerCoords - v.coords) < 10.0 then
                sleep = 1

                if Config.AmbulanceJob.Marker.use then DrawMarker(Config.AmbulanceJob.Marker.marker, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, Config.AmbulanceJob.Marker.rgb[1], Config.AmbulanceJob.Marker.rgb[2], Config.AmbulanceJob.Marker.rgb[3], 255, Config.AmbulanceJob.Marker.bobUpAndDown, true, 2, Config.AmbulanceJob.Marker.rotate, nil, false) end
                if #(playerCoords - v.coords) < 1.5 then
                    sleep = 5

                    nearMarker2 = true
                    if not ShowText2 then
                        TextUIFunction('open', Config.Texts[10][1]..' '..v.price..''..Config.MoneyForm)
                        ShowText2 = true
                    end
                    
                    if IsControlJustReleased(0, Config.Texts[10][2]) then
                        if Config.NPCMedicersOnlyAllowHelpWhenThereIsNoMedicsAvailable and AvailableMedicers == 0 then
                            if not InTreatment then
                                if GetEntityHealth(playerPed) < GetEntityMaxHealth(playerPed) or PlayerData.deathStatus then
                                    TSCB('brutal_ambulancejob:server:GetPlayerMoney', function(wallet)
                                        if wallet.money >= v.price then
                                            InTreatment = true
                                            if PlayerData.deathStatus then
                                                ReviveEvent()
                                            end

                                            Citizen.Wait(1000)
                                            
                                            TriggerServerEvent('brutal_ambulancejob:server:RemoveMoney', 'money', v.price)
                                            SetEntityCoords(playerPed, v.bedcoords)

                                            bedObject = GetClosestObjectOfType(playerCoords, 3.0, v.prop, false, false, false)
                                            FreezeEntityPosition(bedObject, true)
                    
                                            loadAnimDict("anim@gangops@morgue@table@")
                                            TaskPlayAnim(playerPed, "anim@gangops@morgue@table@" , "body_search", 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
                                            SetEntityHeading(playerPed, v.bedheading)
                    
                                            cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
                                            SetCamActive(cam, true)
                                            RenderScriptCams(true, false, 1, true, true)
                                            AttachCamToPedBone(cam, playerPed, 31085, 0, 1.0, 1.0 , true)
                                            SetCamFov(cam, 90.0)
                                            local heading = GetEntityHeading(playerPed)
                                            heading = (heading > 180) and heading - 180 or heading + 180
                                            SetCamRot(cam, -45.0, 0.0, heading, 2)
                    
                                            Citizen.Wait(1500)
                                            DoScreenFadeIn(1000)
                    
                                            Citizen.Wait(1000*v.time)
                                            SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
                    
                                            FreezeEntityPosition(playerPed, false)
                                            SetEntityInvincible(playerPed, false)
                                            SetEntityHeading(playerPed, v.bedheading + 90)
                    
                                            loadAnimDict("switch@franklin@bed")
                                            TaskPlayAnim(playerPed, 'switch@franklin@bed' , 'sleep_getup_rubeyes', 100.0, 1.0, -1, 8, -1, 0, 0, 0)
                                            Wait(4000)
                                            ClearPedTasks(playerPed)
                                            RenderScriptCams(0, true, 200, true, true)
                                            DestroyCam(cam, false)

                                            InTreatment = false
                                        else
                                            SendNotify(12)
                                        end
                                    end)
                                else
                                    SendNotify(17)
                                end
                            end
                        else
                            SendNotify(23)
                        end
                    end
                end
            end
        end

        if (ShowText2 and not nearMarker2) or (InMenu and ShowText2) then
            ShowText2 = false
            TextUIFunction('hide')
        end
        
        Citizen.Wait(sleep)
    end
end)

function inAmbulanceJob()
    Citizen.CreateThread(function()
        while PlayerData.medicer do
            sleep = 750
            local v = Config.AmbulanceJob
            local nearMarker = false
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if not IsPedInAnyVehicle(playerPed, false) then

                -- Duty --
                if #(playerCoords - v.Duty) < 10.0 then
                    sleep = 1
                    if Config.AmbulanceJob.Marker.use then DrawMarker(v.Marker.marker, v.Duty, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, v.Marker.rgb[1], v.Marker.rgb[2], v.Marker.rgb[3], 255, v.Marker.bobUpAndDown, true, 2, v.Marker.rotate, nil, false) end
                    if #(playerCoords - v.Duty) < 1.5 then

                        nearMarker = true

                        if not ShowText and not InMenu then
                            if not InDuty then
                                TextUIFunction('open', Config.Texts[7][1])
                                ShowText = true
                            else
                                TextUIFunction('open', Config.Texts[7][2])
                                ShowText = true
                            end
                        end
                        
                        if IsControlJustReleased(0, Config.Texts[7][3]) and not InMenu and not DoesEntityExist(dutyprop) then
                            if not SpamDuty then
                                SpamDuty = true

                                ShowText = false

                                local ped = GetPlayerPed(-1)
                                local ad = "missheistdockssetup1clipboard@base"
                                local prop_name = 'prop_notepad_01'
                                local secondaryprop_name = 'prop_pencil_01'
                                loadAnimDict(ad)

                                if not InDuty then
                                    ProgressBarFunction(2500, Config.Progressbar.DutyON)
                                else
                                    ProgressBarFunction(2500, Config.Progressbar.DutyOFF)
                                end
                                
                                local x,y,z = table.unpack(playerCoords)
                                RequestSpawnObject(prop_name)
                                RequestSpawnObject(secondaryprop_name)
                                dutyprop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
                                dutyprop2 = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
                                AttachEntityToEntity(dutyprop, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
                                AttachEntityToEntity(dutyprop2, ped, GetPedBoneIndex(ped, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true)
                                TaskPlayAnim(ped, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                                FreezeEntityPosition(ped, true)

                                Citizen.Wait(2500)
                                FreezeEntityPosition(ped, false)
                                ClearPedTasks(ped)
                                DeleteEntity(dutyprop)
                                DeleteEntity(dutyprop2)

                                if not InDuty then
                                    InDuty = true
                                    SendNotify(5)
                                else
                                    InDuty = false
                                    SendNotify(6)
                                end

                                for k,v in pairs(MedicerBlips) do
                                    RemoveBlip(v)
                                end
                                for k,v in pairs(CallBlips) do
                                    RemoveBlip(v)
                                end

                                TriggerServerEvent('brutal_ambulancejob:server:SetDutyStatus', InDuty, Config.AmbulanceJob.DutyBlips)
                                if Config['Core']:upper() == 'QBCORE' then
                                    TriggerServerEvent("QBCore:ToggleDuty", InDuty)
                                    TriggerServerEvent('brutal_ambulancejob:server:SyncDutyStatus', InDuty)
                                end

                                Citizen.CreateThread(function()
                                    Citizen.Wait(1000*10)
                                    SpamDuty = false
                                    SpamNotify = false
                                end)
                            else
                                if not SpamNotify then
                                    SendNotify(9)
                                    SpamNotify = true
                                end
                            end
                        end
                    end
                end

                if not InMenu and InDuty then

                    -- Cloakrooms --
                    for key,coords in pairs(v.Cloakrooms) do
                        if #(playerCoords - coords) < 10.0 then
                            sleep = 1
                            if Config.AmbulanceJob.Marker.use then DrawMarker(v.Marker.marker, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, v.Marker.rgb[1], v.Marker.rgb[2], v.Marker.rgb[3], 255, v.Marker.bobUpAndDown, true, 2, v.Marker.rotate, nil, false) end
                            if #(playerCoords - coords) < 1.5 then
                                nearMarker = true
                                if not ShowText then
                                    TextUIFunction('open', Config.Texts[1][1])
                                    ShowText = true
                                end
                                
                                if IsControlJustReleased(0, Config.Texts[1][2]) then
                                    if Config['Core']:upper() == 'ESX' and not Config.CustomOutfitMenu then
                                        OpenCloakroomMenu(k)
                                    elseif Config['Core']:upper() == 'QBCORE' and not Config.CustomOutfitMenu then
                                        OpenCloakroomMenu(k)
                                    else
                                        OpenCloakroomMenuEvent(k)
                                    end
                                end
                            end
                        end
                    end

                    -- Armorys --
                    for key,coords in pairs(v.Armorys) do
                        if #(playerCoords - coords) < 10.0 then
                            sleep = 1
                            if Config.AmbulanceJob.Marker.use then DrawMarker(v.Marker.marker, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, v.Marker.rgb[1], v.Marker.rgb[2], v.Marker.rgb[3], 255, v.Marker.bobUpAndDown, true, 2, v.Marker.rotate, nil, false) end
                            if #(playerCoords - coords) < 1.5 then
                                sleep = 1
                            
                                nearMarker = true
                                if not ShowText then
                                    TextUIFunction('open', Config.Texts[2][1])
                                    ShowText = true
                                end
                                
                                if IsControlJustReleased(0, Config.Texts[2][2]) then
                                    OpenMenuUtil()
                                    SendNUIMessage({action = "OpenArmory"})
                                end
                            end
                        end
                    end

                    -- Boss Menus --
                    for key,coords in pairs(v.BossMenu.coords) do
                        if #(playerCoords - coords) < 10.0 then
                            sleep = 1
                            if Config.AmbulanceJob.Marker.use then DrawMarker(v.Marker.marker, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, v.Marker.rgb[1], v.Marker.rgb[2], v.Marker.rgb[3], 255, v.Marker.bobUpAndDown, true, 2, v.Marker.rotate, nil, false) end
                            if #(playerCoords - coords) < 1.5 then
                                sleep = 1
                            
                                nearMarker = true
                                if not ShowText then
                                    TextUIFunction('open', Config.Texts[5][1])
                                    ShowText = true
                                end
                                
                                if IsControlJustReleased(0, Config.Texts[5][2]) then
                                    local permission = false
                                    for k,v in pairs(v.BossMenu.grades) do
                                        if PlayerData.job.grade == v then
                                            permission = true
                                            break
                                        end
                                    end

                                    if permission then
                                        if Config['Core']:upper() == 'ESX' then
                                            TriggerEvent('esx_society:openBossMenu', PlayerData.job.name, function(data) end, { wash = false })
                                        elseif Config['Core']:upper() == 'QBCORE' then
                                            TriggerEvent('qb-bossmenu:client:OpenMenu')
                                        end
                                    else
                                        SendNotify(1)
                                    end
                                end
                            end
                        end
                    end

                    -- Garages --
                    for key,table in pairs(v.Garages) do
                        local coords = table.menu
                        if #(playerCoords - coords) < 15.0 then
                            sleep = 1
                            if Config.AmbulanceJob.Marker.use then DrawMarker(v.Marker.marker, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, v.Marker.rgb[1], v.Marker.rgb[2], v.Marker.rgb[3], 255, v.Marker.bobUpAndDown, true, 2, v.Marker.rotate, nil, false) end

                            if #(playerCoords - coords) < 2.0 then
                                nearMarker = true
                                if not ShowText then
                                    TextUIFunction('open', Config.Texts[3][1])
                                    ShowText = true
                                end
                                
                                if IsControlJustReleased(0, Config.Texts[3][2]) then
                                    OpenGarageMenu(table)
                                end
                            end
                        end
                    end
                end
            else

                -- Garage Deposit --
                for key,table in pairs(v.Garages) do
                    local coords = table.deposit
                    if Vdist(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) < 3.5 and not InMenu and InDuty then
                        sleep = 1
                        
                        nearMarker = true
                        if not ShowText then
                            TextUIFunction('open', Config.Texts[4][1])
                            ShowText = true
                        end
                        
                        if IsControlJustReleased(0, Config.Texts[4][2]) then
                            DoScreenFadeOut(400)
                            Citizen.Wait(400)

                            local ambulanceVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                            DeleteEntity(ambulanceVehicle)
                            Citizen.Wait(300)
                            DoScreenFadeIn(600)
                        end
                    end
                end
            end

            if (ShowText and not nearMarker) or (InMenu and ShowText) then
                ShowText = false
                TextUIFunction('hide')
            end

            Citizen.Wait(sleep)
        end
    end)
end

-----------------------------------------------------------
--------------------| duty |--------------------
-----------------------------------------------------------

if Config.Commands.Duty.Use then
    TriggerEvent('chat:addSuggestion', '/'.. Config.Commands.Duty.Command ..'', Config.Commands.Duty.Suggestion)

    RegisterCommand(Config.Commands.Duty.Command, function()
        TriggerEvent('brutal_ambulancejob:client:ToggleDuty')
    end)

    RegisterNetEvent('brutal_ambulancejob:client:ToggleDuty')
    AddEventHandler('brutal_ambulancejob:client:ToggleDuty', function(animation)
        if isPlayerMedicer() then
            if not SpamDuty then
                SpamDuty = true
            
                if animation ~= nil and animation then
                    local ped = GetPlayerPed(-1)
                    local ad = "missheistdockssetup1clipboard@base"
                    local prop_name = 'prop_notepad_01'
                    local secondaryprop_name = 'prop_pencil_01'
                    loadAnimDict(ad)

                    if not InDuty then
                        ProgressBarFunction(2500, Config.Progressbar.DutyON)
                    else
                        ProgressBarFunction(2500, Config.Progressbar.DutyOFF)
                    end
                    
                    local x,y,z = table.unpack(playerCoords)
                    RequestSpawnObject(prop_name)
                    RequestSpawnObject(secondaryprop_name)
                    dutyprop = CreateObject(GetHashKey(prop_name), x, y, z+0.2,  true,  true, true)
                    dutyprop2 = CreateObject(GetHashKey(secondaryprop_name), x, y, z+0.2,  true,  true, true)
                    AttachEntityToEntity(dutyprop, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
                    AttachEntityToEntity(dutyprop2, ped, GetPedBoneIndex(ped, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true)
                    TaskPlayAnim(ped, ad, "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                    FreezeEntityPosition(ped, true)
                
                    Citizen.Wait(2500)
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    DeleteEntity(dutyprop)
                    DeleteEntity(dutyprop2)
                end
            
                if not InDuty then
                    InDuty = true
                    SendNotify(5)
                else
                    InDuty = false
                    SendNotify(6)
                end
            
                for k,v in pairs(MedicerBlips) do
                    RemoveBlip(v)
                end
                for k,v in pairs(CallBlips) do
                    RemoveBlip(v)
                end
            
                TriggerServerEvent('brutal_ambulancejob:server:SetDutyStatus', InDuty, Config.AmbulanceJob.DutyBlips)
                if Config['Core']:upper() == 'QBCORE' then
                    TriggerServerEvent("QBCore:ToggleDuty", InDuty)
                    TriggerServerEvent('brutal_ambulancejob:server:SyncDutyStatus', InDuty)
                end
            
                Citizen.CreateThread(function()
                    Citizen.Wait(1000*10)
                    SpamDuty = false
                    SpamNotify = false
                end)
            else
                if not SpamNotify then
                    SendNotify(9)
                    SpamNotify = true
                end
            end
        end
    end)
end

-----------------------------------------------------------
--------------------| ambulance menus |--------------------
-----------------------------------------------------------

function OpenCloakroomMenu(AmbulanceDepartment)
    local outfits = {}

    table.insert(outfits, {id = 'citizen_wear', label = Config.CitizenWear.label})

    for k,v in pairs(Config.Uniforms) do
        for i = 1, #v.jobs do
            if PlayerData.job.name == Config.Uniforms[k].jobs[i].job then
                for _k,_v in pairs(Config.Uniforms[k].jobs[i].grades) do
                    if PlayerData.job.grade == _v then
                        table.insert(outfits, {id = k, label = v.label})
                    end
                end
            end
        end
    end

    OpenMenuUtil()
    SendNUIMessage({ 
        action = "OpenInteractionMenu",
        table = outfits,
        type = 'cloakroom',
        label = Config.Locales.CloakRoom
    })
end

function OpenGarageMenu(data)
    SpawnCoords = data.spawn

    local VehicleTable = {}
    for k,v in pairs(data.vehicles) do
        if PlayerData.job.grade >= v.minRank then
            table.insert(VehicleTable, {id = k, label = v.Label})
        end
    end

    if #VehicleTable > 0 then
        OpenMenuUtil()
        SendNUIMessage({ 
            action = "OpenInteractionMenu",
            table = VehicleTable,
            type = 'garage',
            label = Config.Locales.GarageMenu
        })
    else
        SendNotify(2)
    end
end

function DeleteVehicleFunction(data)
    DoScreenFadeOut(400)
    Citizen.Wait(400)

    local ambulanceVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    TriggerEvent('brutal_ambulancejob:client:utils:DeleteVehicle', ambulanceVehicle)
    DeleteEntity(ambulanceVehicle)
    Citizen.Wait(300)
    DoScreenFadeIn(600)
end

-----------------------------------------------------------
-----------------------| functions |-----------------------
-----------------------------------------------------------

RegisterNetEvent('brutal_ambulancejob:client:onPlayerDeath')
AddEventHandler('brutal_ambulancejob:client:onPlayerDeath', function()
    if PlayerData.deathStatus == false then
        OLDMyDamages = MyDamages
        PlayerData.deathStatus = true
        TriggerServerEvent('brutal_ambulancejob:server:setDeathStatus', PlayerData.deathStatus)
        if Config['Core']:upper() == 'QBCORE' and GetResourceState('brutal_policejob') == "started" then
            TriggerEvent('brutal_policejob:client:PlayerDied')
        end
        
        local player = PlayerPedId()

        while GetEntitySpeed(player) > 0.5 or IsPedRagdoll(player) do
            Wait(10)
        end

        local pos = GetEntityCoords(player)
        local heading = GetEntityHeading(player)

        if Config.DeathAnimation.use then
            if IsPedInAnyVehicle(player) then
                local veh = GetVehiclePedIsIn(player)
                local vehseats = GetVehicleModelNumberOfSeats(GetHashKey(GetEntityModel(veh)))
                for i = -1, vehseats do
                    local occupant = GetPedInVehicleSeat(veh, i)
                    if occupant == player then
                        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
                        SetPedIntoVehicle(player, veh, i)
                    end
                end
            else
                NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
            end
        end

        SetEntityInvincible(player, true)
        if Config.DeathAnimation.use then
            if IsPedInAnyVehicle(player, false) then
                loadAnimDict("veh@low@front_ps@idle_duck")
                TaskPlayAnim(player, "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
            else
                loadAnimDict(Config.DeathAnimation.animDictionary)
                TaskPlayAnim(player, Config.DeathAnimation.animDictionary, Config.DeathAnimation.animName, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
            end
        end

        PlayerData.deathTime = Config.DeathTime
        PlayerData.callSent = false
        PlayerData.reviveRequest = false
        PlayerData.reviveRequestTime = 0
        SendNUIMessage({action = "DeathScreen", time = PlayerData.deathTime, call = PlayerData.callSent, request = PlayerData.reviveRequest, waittime = Config.WaitTime})

        Citizen.CreateThread(function()
            while PlayerData.deathStatus do
                for k,v in pairs(Config.DisableControls) do
                    DisableControlAction(0,v,true)
                    DisableControlAction(1,v,true)
                    DisableControlAction(2,v,true)
                end

                if IsControlJustPressed(0, Config.ReviveKey) then
					if PlayerData.deathTime > 0 and PlayerData.callSent == false and not RevivedByMedicer then
                        PlayerData.callSent = true
                        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
                        streetLabel = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
                        TriggerServerEvent('brutal_ambulancejob:server:citizencall', 'create', PlayerData.name, {x,y,z}, streetLabel)
                        SendNUIMessage({action = "DeathScreen", time = PlayerData.deathTime, call = PlayerData.callSent, request = PlayerData.reviveRequest, waittime = Config.WaitTime})
                    elseif PlayerData.deathTime == 0 and PlayerData.reviveRequest == false then
                        PlayerData.reviveRequest = true
                        SendNUIMessage({action = "DeathScreen", time = PlayerData.deathTime, call = true, request = PlayerData.reviveRequest, waittime = Config.WaitTime})
                    end
				end

                Citizen.Wait(1)
            end
        end)

        while PlayerData.deathStatus and not PlayerData.reviveRequest and (PlayerData.reviveRequestTime < Config.WaitTime or (Config.WaitTime <= 0 and PlayerData.deathTime > 0)) do
            if PlayerData.deathTime > 0 then
            PlayerData.deathTime = PlayerData.deathTime - 1
            else
                PlayerData.reviveRequestTime += 1
            end

            if Config.DeathAnimation.use then
                if not RevivedByMedicer and PlayerData.deathStatus and not IsEntityPlayingAnim(player, "amb@world_human_bum_slumped@male@laying_on_right_side@base", "base", 9) and not IsEntityPlayingAnim(player, Config.DeathAnimation.animDictionary, Config.DeathAnimation.animName, 3) and not IsEntityPlayingAnim(player, "veh@low@front_ps@idle_duck", "sit", 9) then
                    loadAnimDict(Config.DeathAnimation.animDictionary)
                    TaskPlayAnim(player, Config.DeathAnimation.animDictionary, Config.DeathAnimation.animName, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                end
            end
            Citizen.Wait(1000)
        end

        PlayerData.reviveRequest = true

        if not RevivedByMedicer then
            if PlayerData.deathStatus then
                PlayerData.hospitalRevive = true
            else
                PlayerData.hospitalRevive = false
            end
            RevivePlayer()
        end
    end
end)

function RevivePlayer()
    if PlayerData.hospitalRevive then
        while PlayerData.reviveRequest == false and PlayerData.deathStatus do
            Citizen.Wait(1)
        end
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local coords
    if PlayerData.hospitalRevive then
        TriggerServerEvent('brutal_ambulancejob:server:clearinventory')
        coords = Config.ReviveCoords[1]
        for k,v in pairs(Config.ReviveCoords) do
            if #(playerCoords - vector3(v[1], v[2], v[3])) < #(playerCoords - vector3(coords[1], coords[2], coords[3])) then
                coords = v
            end
        end
    else
        coords = {playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(playerped)}
    end

    PlayerData.hospitalRevive = true

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
        Wait(50)
    end

    RespawnPed(playerPed, coords)
    PlayerData.deathStatus = false
    MyDamages = OLDMyDamages
    TriggerServerEvent('brutal_ambulancejob:server:setDeathStatus', PlayerData.deathStatus)
    SendNUIMessage({action = "DeathScreenHide"})
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    DoScreenFadeIn(800)
end

function RespawnPed(ped, coords)
    if coords ~= nil then
        SetEntityCoordsNoOffset(ped, coords[1], coords[2], coords[3], false, false, false)
        NetworkResurrectLocalPlayer(coords[1], coords[2], coords[3], coords[4], true, false)
        SetPlayerInvincible(ped, false)
        ClearPedBloodDamage(ped)

        -- Camera Rotation Fix
        SetGameplayCamRelativeHeading(GetEntityHeading(ped)-coords[4])
        SetGameplayCamRelativePitch(90, 1.0)
    end

    SetEntityInvincible(ped, false)

    TriggerEvent('brutal_ambulancejob:revive')
    if Config['Core']:upper() == 'ESX' then
        TriggerServerEvent('esx:onPlayerSpawn')
        TriggerEvent('esx:onPlayerSpawn')
        TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
    end
end

RegisterNetEvent(ReviveEvent)
AddEventHandler(ReviveEvent, function()
    ReviveEvent()
end)

RegisterNetEvent('brutal_ambulancejob:revive')
AddEventHandler('brutal_ambulancejob:revive', function()
    ReviveEvent()
end)

function ReviveEvent()
    PlayerData.hospitalRevive = false

    if PlayerData.deathStatus then
        PlayerData.deathStatus = false
    end
end

-----------------------------------------------------------
--------------------------| MDT |--------------------------
-----------------------------------------------------------

if Config.Commands.MDT.Use then
    RegisterCommand(Config.Commands.MDT.Command, function()
        TriggerEvent('brutal_ambulancejob:client:MDTCommand')
    end)

    if Config.Commands.MDT.Control ~= nil then
        RegisterKeyMapping(Config.Commands.MDT.Command, Config.Commands.MDT.Suggestion, "keyboard", Config.Commands.MDT.Control)
    end
    
    TriggerEvent('chat:addSuggestion', '/'.. Config.Commands.MDT.Command ..'', Config.Commands.MDT.Suggestion)
end

RegisterNetEvent('brutal_ambulancejob:client:MDTCommand')
AddEventHandler('brutal_ambulancejob:client:MDTCommand', function()
    if InDuty then
        if not InMenu then
            if Config.Commands.MDT.Use then
                OpenMenuUtil()

                local ped = GetPlayerPed(-1)
                        
                RequestSpawnObject("prop_cs_tablet")
                tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
                AttachEntityToEntity(tab, ped, GetPedBoneIndex(ped, 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)

                loadAnimDict("amb@world_human_seat_wall_tablet@female@base")
                TaskPlayAnim(ped, "amb@world_human_seat_wall_tablet@female@base", "base" ,8.0, -8.0, -1, 50, 0, false, false, false)
                
                local x,y,z = table.unpack(GetEntityCoords(ped))

                SendNUIMessage({
                    action = "OpenMDTMenu",
                    job = {job = PlayerData.job.name, name = PlayerData.job.label, label = PlayerData.job.grade_label, salary = PlayerData.job.salary},
                    street = {GetLabelText(GetNameOfZone(x,y,z)), GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))},
                    name = PlayerData.name,
                    medicers = AvailableMedicers,
                    moneyform = Config.MoneyForm,
                })
            else
                CustomMDT()
            end
        end
    elseif Config.AmbulanceJob.Job == PlayerData.job.name then
        SendNotify(10)
    end
end)

-----------------------------------------------------------
---------------------| citizen call |----------------------
-----------------------------------------------------------

RegisterNetEvent('brutal_ambulancejob:client:CitizenCallRefreshTable')
AddEventHandler('brutal_ambulancejob:client:CitizenCallRefreshTable', function(Calls)
    SendNUIMessage({action = "MDTGetCalls", table = Calls, myid = GetPlayerServerId(PlayerId())})
end)

RegisterNetEvent('brutal_ambulancejob:client:RemoveCitizenCallBlip')
AddEventHandler('brutal_ambulancejob:client:RemoveCitizenCallBlip', function(id)
    if InDuty then
        RemoveBlip(CallBlips[id])
        CallBlips[id] = nil
    end
end)

RegisterNetEvent('brutal_ambulancejob:client:CitizenCallArived')
AddEventHandler('brutal_ambulancejob:client:CitizenCallArived', function(id, street)
    if InDuty then
        notification(Config.Notify[7][1], '#'..id..' '..Config.Notify[7][2]..' '..street, Config.Notify[7][3], Config.Notify[7][4])
    end
end)

TriggerEvent('chat:addSuggestion', '/'.. Config.Commands.MedicCall.Command ..'', Config.Commands.MedicCall.Suggestion)

RegisterCommand(Config.Commands.MedicCall.Command, function()
    OpenMenuUtil()
    SendNUIMessage({action = "CitizenCallMenu"})
end)

-----------------------------------------------------------
------------------| main ambulance menu |------------------
-----------------------------------------------------------

RegisterKeyMapping(Config.Commands.JobMenu.Command, Config.Commands.JobMenu.Suggestion, "keyboard", Config.Commands.JobMenu.Control)
TriggerEvent('chat:addSuggestion', '/'.. Config.Commands.JobMenu.Command ..'', Config.Commands.JobMenu.Suggestion)

RegisterCommand(Config.Commands.JobMenu.Command, function()
    if InDuty then
        if not InMenu and not IsPedInAnyVehicle(PlayerPedId(), false) then
            InMenu = true
            SendNUIMessage({
                action = "OpenJobMenu",
                interactionstable = {
                    {
                        label = Config.Locales.Animations,
                        icon = '<i class="fa-solid fa-user"></i>',
                        table = {
                            {label = Config.Locales.Carry, icon = '<i class="fa-solid fa-people-carry-box fa-flip-horizontal"></i>', id = 'carry'},
                            {label = Config.Locales.Ecg, icon = '<i class="fa-solid fa-stethoscope"></i>', id = 'ecg'},
                            {label = Config.Locales.Bag, icon = '<i class="fa-solid fa-briefcase"></i>', id = 'bag'},
                            {label = Config.Locales.Wheelchair, icon = '<i class="fa-solid fa-wheelchair"></i>', id = 'wheelchair'},
                        }
                    },
                    {
                        label = Config.Locales.Stretcher,
                        icon = '<i class="fa-solid fa-truck-medical"></i>',
                        table = {
                            {label = Config.Locales.Spawn, icon = '<i class="fa-solid fa-plus"></i>', id = 'spawn'},
                            {label = Config.Locales.PutOn, icon = '<i class="fa-solid fa-person"></i>', id = 'puton'},
                            {label = Config.Locales.Bed, icon = '<i class="fa-solid fa-bed-pulse"></i>', id = 'bed'},
                            {label = Config.Locales.Push, icon = '<i class="fa-solid fa-hand"></i>', id = 'push'},
                            {label = Config.Locales.PutIn, icon = '<i class="fa-solid fa-truck-medical"></i>', id = 'putin'},
                        }
                    },
                    {label = Config.Locales.MedicerMenu, icon = '<i class="fa-solid fa-hand-holding-medical"></i>', id = 'medicer_menu'},
                    {label = Config.Locales.MDT, icon = '<i class="fa-solid fa-tablet-screen-button"></i>', id = 'mdt'},
                }
            })

            Citizen.CreateThread(function()
                while InMenu do
                    if IsControlJustReleased(0, 188) then
                        SendNUIMessage({
                            action = "ControlReleased",
                            control = 'down'
                        })
                    elseif IsControlJustReleased(0, 187) then
                        SendNUIMessage({
                            action = "ControlReleased",
                            control = 'up'
                        })
                    elseif IsControlJustReleased(0, 191) then
                        SendNUIMessage({
                            action = "ControlReleased",
                            control = 'enter'
                        })
                    elseif IsControlJustReleased(0, 194) then
                        SendNUIMessage({
                            action = "ControlReleased",
                            control = 'backspace'
                        })
                    end
                    Citizen.Wait(1)
                end
            end)
        end
    elseif Config.AmbulanceJob.Job == PlayerData.job.name then
        SendNotify(10)
    end
end)

RegisterNetEvent('brutal_ambulancejob:client:carry')
AddEventHandler('brutal_ambulancejob:client:carry', function(Target)
    local ped = GetPlayerPed(-1)
    
    if not InCarry then
        InCarry = true
        local targetPed = GetPlayerPed(GetPlayerFromServerId(Target))
        local distance = #(GetEntityCoords(ped) - GetEntityCoords(targetPed))

        if IsPedInAnyVehicle(ped) then
            SetEntityCoords(ped, GetEntityCoords(targetPed))
            Citizen.Wait(300)
        end

        if distance <= 5.0 then
            AttachEntityToEntity(ped, targetPed, GetPedBoneIndex(targetPed, 57005), -0.32, -0.6, -0.35, 240.0, 35.0, 149.0, true, true, false, true, 1, true)

            loadAnimDict('amb@world_human_bum_slumped@male@laying_on_right_side@base')
            TaskPlayAnim(ped, 'amb@world_human_bum_slumped@male@laying_on_right_side@base',  'base', 8.0, 8.0, -1, 9, 0, false, false, false)
        end
    else
        InCarry = false
        DetachEntity(ped, true, false)
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('brutal_ambulancejob:client:puton')
AddEventHandler('brutal_ambulancejob:client:puton', function(Target)
    local ped = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestObject = GetClosestObjectOfType(playerCoords, 3.0, GetHashKey("prop_ld_binbag_01"), false)
    
    if not IsEntityAttachedToEntity(ped, closestObject) then
        AttachEntityToEntity(ped, closestObject, 0.0, 0.0, 0.15, 1.1, 0.0, 0.0, 180.0, false, false, false, false, 2, true)
        loadAnimDict("anim@gangops@morgue@table@")
        TaskPlayAnim(ped, "anim@gangops@morgue@table@", "body_search", 1.0, 1.0, -1, 1, 0, 0, 0, 0)

        while IsEntityAttachedToEntity(ped, closestObject) do
            Citizen.Wait(1)

            if not IsEntityPlayingAnim(ped, "anim@gangops@morgue@table@", "body_search", 3) then
                TaskPlayAnim(ped, "anim@gangops@morgue@table@", "body_search", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
            end
        end
    else
        DetachEntity(ped, true, true)
        local coords = GetOffsetFromEntityInWorldCoords(closestObject, 1.0, 0.0, 0.0)
        SetEntityCoords(ped, coords.x,coords.y,coords.z)
        Citizen.Wait(10)
        ClearPedTasks(ped)
    end
end)

AddEventHandler('gameEventTriggered', function (name, args)
    if name == 'CEventNetworkPlayerEnteredVehicle' then
        CloseMenuUtil()
        SendNUIMessage({action = "close"})
    end
end)

-----------------------------------------------------------
---------------------| medicer menu |----------------------
-----------------------------------------------------------

Bones = {
    [31085] = 'HEAD',
    [31086] = 'HEAD',
    [39317] = 'HEAD',
    [57597] = 'BODY',
    [23553] = 'BODY',
    [24816] = 'BODY',
    [24817] = 'BODY',
    [24818] = 'BODY',
    [10706] = 'BODY',
    [64729] = 'BODY',
    [11816] = 'BODY',
    [45509] = 'LARM',
    [61163] = 'LARM',
    [18905] = 'LARM',
    [4089] = 'LARM',
    [4090] = 'LARM',
    [4137] = 'LARM',
    [4138] = 'LARM',
    [4153] = 'LARM',
    [4154] = 'LARM',
    [4169] = 'LARM',
    [4170] = 'LARM',
    [4185] = 'LARM',
    [4186] = 'LARM',
    [26610] = 'LARM',
    [26611] = 'LARM',
    [26612] = 'LARM',
    [26613] = 'LARM',
    [26614] = 'LARM',
    [58271] = 'LLEG',
    [63931] = 'LLEG',
    [2108] = 'LLEG',
    [14201] = 'LLEG',
    [40269] = 'RARM',
    [28252] = 'RARM',
    [57005] = 'RARM',
    [58866] = 'RARM',
    [58867] = 'RARM',
    [58868] = 'RARM',
    [58869] = 'RARM',
    [58870] = 'RARM',
    [64016] = 'RARM',
    [64017] = 'RARM',
    [64064] = 'RARM',
    [64065] = 'RARM',
    [64080] = 'RARM',
    [64081] = 'RARM',
    [64096] = 'RARM',
    [64097] = 'RARM',
    [64112] = 'RARM',
    [64113] = 'RARM',
    [36864] = 'RLEG',
    [51826] = 'RLEG',
    [20781] = 'RLEG',
    [52301] = 'RLEG',
}

BleedingCooldown = false
InjuredWalk = false
MyDamages = {
    bleeding = false,

    head = false,
    body = false,
    larm = false,
    rarm = false,
    lleg = false,
    rleg = false
}

Citizen.CreateThread(function()
    while true do
        local sleep = 3000
        local ped = GetPlayerPed(-1)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)

        if IsEntityDead(ped) then
            Citizen.Wait(5000)
            if IsEntityDead(ped) and not PlayerData.deathStatus then
                TriggerEvent('brutal_ambulancejob:client:onPlayerDeath')
            end
        end

        if GetEntityHealth(ped) >= GetEntityMaxHealth(ped) and not PlayerData.deathStatus then
            MyDamages = {
                bleeding = false,
            
                head = false,
                body = false,
                larm = false,
                rarm = false,
                lleg = false,
                rleg = false
            }
        elseif GetEntityHealth(ped) <= 150 and not BleedingCooldown and Config.Bleeding then
            MyDamages.bleeding = true
        elseif GetEntityHealth(ped) > 150 then
            MyDamages.bleeding = false
        end

        if MyDamages.bleeding then
            sleep = 10000
            SetEntityHealth(ped, GetEntityHealth(ped)-1)
        end

        if Config.InjuredWalk then
            if (MyDamages.lleg or MyDamages.rleg) and not InjuredWalk then
                InjuredWalk = true
                RequestAnimSet("move_m@injured")
                SetPedMovementClipset(ped, "move_m@injured", true)
            elseif InjuredWalk and not (MyDamages.lleg or MyDamages.rleg) then
                InjuredWalk = false
                ResetPedMovementClipset(ped)
                ResetPedWeaponMovementClipset(ped)
                ResetPedStrafeClipset(ped)
            end
        end

        Citizen.Wait(sleep)
    end
end)

AddEventHandler('gameEventTriggered', function (event, data)
    if event == 'CEventNetworkEntityDamage' then
        local ped = GetPlayerPed(-1)
        local success,bone = GetPedLastDamageBone(ped)
        if success then
            BleedingCooldown = false

            if Bones[bone] == 'HEAD' then
                MyDamages.head = true
            elseif Bones[bone] == 'BODY' then
                MyDamages.body= true
            elseif Bones[bone] == 'LARM' then
                MyDamages.larm = true
            elseif Bones[bone] == 'RARM' then
                MyDamages.rarm = true
            elseif Bones[bone] == 'LLEG' then
                MyDamages.lleg= true
            elseif Bones[bone] == 'RLEG' then
                MyDamages.rleg = true
            end
        end
    end
end)
  
TriggerEvent('chat:addSuggestion', '/'.. Config.Commands.MedicerMenu.Command ..'', Config.Commands.MedicerMenu.Suggestion)

RegisterCommand(Config.Commands.MedicerMenu.Command, function()
    TriggerEvent('brutal_ambulancejob:client:MedicerMenuCommand')
end)

RegisterNetEvent('brutal_ambulancejob:client:MedicerMenuCommand')
AddEventHandler('brutal_ambulancejob:client:MedicerMenuCommand', function()
    if not InMenu then
        if InAnimation == false then
            local closestPlayer, closestDistance = GetClosestPlayerFunction()

            if (closestPlayer == -1 or closestDistance >= 2.0) or InDuty == false then
                OpenMenuUtil()

                local DamagesTable = MyDamages
                local bpm = GetEntityHealth(GetPlayerPed(-1))-100
                if PlayerData.deathStatus then
                    bpm = 0
                elseif bpm > 80 then 
                    bpm = 80 
                elseif bpm < 0 then
                    bpm = 0
                end

                TSCB('brutal_ambulancejob:server:getMedicerItems', function(items)
                    SendNUIMessage({
                        action = "OpenMedicerMenu",
                        damagestable = DamagesTable,
                        bpm = bpm,
                        gender = IsPedMale(GetPlayerPed(-1)),
                        deathstatus = PlayerData.deathStatus,
                        items = items,
                        you = true
                    })
                end)
            elseif (closestPlayer ~= -1 and closestDistance < 2.0) and InDuty then
                TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuGetDamageData', GetPlayerServerId(closestPlayer))
            end
        end
    end
end)

RegisterNetEvent('brutal_ambulancejob:client:MedicerMenuGetDamageData')
AddEventHandler('brutal_ambulancejob:client:MedicerMenuGetDamageData', function(Target, Source)
    TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuSendDamageData', Target, Source, MyDamages, PlayerData.deathStatus)
end)

RegisterNetEvent('brutal_ambulancejob:client:MedicerMenuSendDamageData')
AddEventHandler('brutal_ambulancejob:client:MedicerMenuSendDamageData', function(Target, DamagesTable, DeathStatus)
    MedicerMenuTargetID = Target
    OpenMenuUtil()

    local targetPed = GetPlayerPed(GetPlayerFromServerId(Target))
    local bpm = GetEntityHealth(targetPed)-100
    if DeathStatus then
        bpm = 0
    elseif bpm > 80 then 
        bpm = 80 
    elseif bpm < 0 then
        bpm = 0
    end

    TSCB('brutal_ambulancejob:server:getMedicerItems', function(items)
        SendNUIMessage({
            action = "OpenMedicerMenu",
            damagestable = DamagesTable,
            bpm = bpm,
            gender = IsPedMale(targetPed),
            deathstatus = DeathStatus,
            items = items,
            you = false
        })
    end)
end)

RegisterNetEvent('brutal_ambulancejob:client:MedicerMenuUseItem')
AddEventHandler('brutal_ambulancejob:client:MedicerMenuUseItem', function(item, part)
    local ped = GetPlayerPed(-1)
    local closestPlayer, closestDistance = GetClosestPlayerFunction()

    if closestPlayer ~= -1 and closestDistance < 3.0 then
        if item == "head_heal" then
            MyDamages.head = false
            TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), item)
        elseif item == "body_heal" then
            MyDamages.body = false
            TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), item)
        elseif item == "arm_heal" then
            if part == 'right' then
                MyDamages.rarm = false
                TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), 'rarm')
            elseif part == 'left' then
                MyDamages.larm = false
                TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), 'larm')
            end
        elseif item == "leg_heal" then
            if part == 'right' then
                MyDamages.rleg = false
                TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), 'rleg')
            elseif part == 'left' then
                MyDamages.lleg = false
                TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), 'lleg')
            end
        elseif item == "blood" then
            TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), "body_heal")
            Citizen.CreateThread(function()
                MyDamages.bleeding = false
                BleedingCooldown = true
                Citizen.Wait(1000*60*3)
                BleedingCooldown = false
            end)
        elseif item == "revive" then
            RevivedByMedicer = true
            PlayerData.hospitalRevive = false
            SendNUIMessage({action = "DeathScreenHide"})
            TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuAnims', GetPlayerServerId(closestPlayer), item)

            local targetPed = GetPlayerPed(GetPlayerFromServerId(GetPlayerServerId(closestPlayer)))
            playerheading = GetEntityHeading(targetPed)
			playerlocation = GetEntityForwardVector(targetPed)
			playercoords = GetEntityCoords(targetPed)
            local x, y, z = table.unpack(playercoords + playerlocation * 1.0)
            SetEntityCoords(ped, x, y, z-0.50)
	        SetEntityHeading(ped, playerheading - 270.0) 

            loadAnimDict('mini@cpr@char_b@cpr_str')
            loadAnimDict('mini@cpr@char_b@cpr_def')

   			TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_def',  'cpr_intro', 8.0, 8.0, -1, 0, 0, false, false, false)
   			Citizen.Wait(15800 - 900)
		    for i=1, 15, 1 do
		        Citizen.Wait(900)
		        TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_str', 'cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)
		    end	
    		TaskPlayAnim(ped, 'mini@cpr@char_b@cpr_str', 'cpr_success', 8.0, 8.0, 27590, 0, 0, false, false, false)	
    		Citizen.Wait(27590)

            local x,y,z = table.unpack(GetEntityCoords(ped))
            RespawnPed(ped, {x,y,z,GetEntityHeading(ped)})
            PlayerData.deathStatus = false
            TriggerServerEvent('brutal_ambulancejob:server:setDeathStatus', PlayerData.deathStatus)
            if not MyDamages.head and not MyDamages.body and not MyDamages.rarm and not MyDamages.larm and not MyDamages.rleg and not MyDamages.lleg then
                SetEntityHealth(ped, GetEntityHealth(ped))
            else
                SetEntityHealth(ped, 155)
            end

            Citizen.CreateThread(function()
                Citizen.Wait(5000)
                RevivedByMedicer = false
            end)
        end

        if item == "head_heal" or item == "body_heal" or item == "arm_heal" or  item == "leg_heal" or item == "blood" then
            if PlayerData.deathStatus == false then
                loadAnimDict("dead")
                TaskPlayAnim(ped, "dead", "dead_a", 1.0, 1.0, 7000, 1, 0, 0, 0, 0)
                Citizen.Wait(8000)

                if item ~= "blood" then
                    local z = 1
                    if MyDamages.head then z+= 1 end
                    if MyDamages.body then z+= 1 end
                    if MyDamages.rarm then z+= 1 end
                    if MyDamages.larm then z+= 1 end 
                    if MyDamages.rleg then z+= 1 end
                    if MyDamages.lleg then z+= 1 end

                    local max_health = GetEntityMaxHealth(ped)
                    local plus = math.floor((max_health-GetEntityHealth(ped))/z)
                    if GetEntityHealth(ped)+plus < max_health then
                        SetEntityHealth(ped, GetEntityHealth(ped)+plus)
                    else
                        SetEntityHealth(ped, max_health)
                    end

                    if not MyDamages.head and not MyDamages.body and not MyDamages.rarm and not MyDamages.larm and not MyDamages.rleg and not MyDamages.lleg then
                        SetEntityHealth(ped, max_health)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('brutal_ambulancejob:client:MedicerMenuAnims')
AddEventHandler('brutal_ambulancejob:client:MedicerMenuAnims', function(Target, AnimType)
    local ped = GetPlayerPed(-1)
    InAnimation = true

    if AnimType == "lleg" then
        loadAnimDict("anim@heists@narcotics@funding@gang_idle")
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(Target)), 11816, -0.06, 1.36, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20, false)
        TaskPlayAnim(ped, "anim@heists@narcotics@funding@gang_idle", "gang_chatting_idle01", 8.0, -8.0, 7000, 0, 0, false, false, false)
        Citizen.Wait(7000)
        DetachEntity(ped, true, false)
    elseif AnimType == "rleg" then
        loadAnimDict("anim@heists@narcotics@funding@gang_idle")
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(Target)), 11816, 0.32, 1.36, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20, false)
        TaskPlayAnim(ped, "anim@heists@narcotics@funding@gang_idle", "gang_chatting_idle01", 8.0, -8.0, 7000, 0, 0, false, false, false)
        Citizen.Wait(7000)
        DetachEntity(ped, true, false)
    elseif AnimType == "rarm" then
        loadAnimDict("anim@heists@narcotics@funding@gang_idle")
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(Target)), 11816, 0.40, 0.52, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20, false)
        TaskPlayAnim(ped, "anim@heists@narcotics@funding@gang_idle", "gang_chatting_idle01", 8.0, -8.0, 7000, 0, 0, false, false, false)
        Citizen.Wait(7000)
        DetachEntity(ped, true, false)
    elseif AnimType == "larm" then
        loadAnimDict("anim@heists@narcotics@funding@gang_idle")
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(Target)), 11816, -0.40, 0.32, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20, false)
        TaskPlayAnim(ped, "anim@heists@narcotics@funding@gang_idle", "gang_chatting_idle01", 8.0, -8.0, 7000, 0, 0, false, false, false)
        Citizen.Wait(7000)
        DetachEntity(ped, true, false)
    elseif AnimType == "body_heal" then
        loadAnimDict("anim@heists@narcotics@funding@gang_idle")
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(Target)), 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 20, false)
        TaskPlayAnim(ped, "anim@heists@narcotics@funding@gang_idle", "gang_chatting_idle01", 8.0, -8.0, 7000, 0, 0, false, false, false)
        Citizen.Wait(7000)
        DetachEntity(ped, true, false)
    elseif AnimType == "head_heal" then
        loadAnimDict("anim@heists@narcotics@funding@gang_idle")
        AttachEntityToEntity(ped, GetPlayerPed(GetPlayerFromServerId(Target)), 11816, -0.10, -1.35, 0.0, 0.0, 180.0, 180.0, false, false, false, false, 20, false)
        TaskPlayAnim(ped, "anim@heists@narcotics@funding@gang_idle", "gang_chatting_idle01", 8.0, -8.0, 7000, 0, 0, false, false, false)
        Citizen.Wait(7000)
        DetachEntity(ped, true, false)
    elseif AnimType == "revive" then

        loadAnimDict('mini@cpr@char_a@cpr_def')
        loadAnimDict('mini@cpr@char_a@cpr_str')
        TaskPlayAnim(ped, 'mini@cpr@char_a@cpr_def', 'cpr_intro', 8.0, 8.0, -1, 0, 0, false, false, false)                      	
        Citizen.Wait(14900)
        for i=1, 15, 1 do
            Citizen.Wait(900)
            TaskPlayAnim(ped, 'mini@cpr@char_a@cpr_str','cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)
        end
        TaskPlayAnim(ped,'mini@cpr@char_a@cpr_str', 'cpr_success', 8.0, 8.0, 27590, 0, 0, false, false, false)
        Citizen.Wait(27590)
    end

    Citizen.Wait(1000)
    InAnimation = false
    TriggerEvent('brutal_ambulancejob:client:MedicerMenuCommand')
end)

-----------------------------------------------------------
--------------------| other functions |--------------------
-----------------------------------------------------------

RegisterNetEvent('brutal_ambulancejob:client:updateAvailabemedicers')
AddEventHandler('brutal_ambulancejob:client:updateAvailabemedicers', function(count)
    AvailableMedicers = count
end)

RegisterNetEvent('brutal_ambulancejob:client:updateBlip')
AddEventHandler('brutal_ambulancejob:client:updateBlip', function(OneSync, InDutyList)

    for k, v in pairs(MedicerBlips) do
        RemoveBlip(v)
    end

    for k,v in pairs(InDutyList) do
        if OneSync == 'infinite' then
            blip = AddBlipForCoord(v.location.x, v.location.y, v.location.z)
            SetBlipSprite(blip, 1)
            ShowHeadingIndicatorOnBlip(blip, true)
            SetBlipRotation(blip, math.ceil(v.location.h))
            SetBlipScale(blip, 1.0)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(v.label)
            EndTextCommandSetBlipName(blip)

            table.insert(MedicerBlips, blip)
        else
            if v == true then
                local id = GetPlayerFromServerId(k)
                if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() and GetPlayerServerId(PlayerId()) ~= id then
                    local ped = GetPlayerPed(id)
                    local blip = GetBlipFromEntity(ped)

                    if not DoesBlipExist(blip) then
                        blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
                        SetBlipNameToPlayerName(blip, id)
                        SetBlipScale(blip, 0.85)
                        SetBlipAsShortRange(blip, true)
                        SetBlipShowCone(blip, true)

                        table.insert(MedicerBlips, blip)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('brutal_ambulancejob:client:usedHealItem')
AddEventHandler('brutal_ambulancejob:client:usedHealItem', function(value, anim)
    if not InHealing then
        InHealing = true
        local ped = GetPlayerPed(-1)
        if anim then
            loadAnimDict('anim@heists@narcotics@funding@gang_idle')
            TaskPlayAnim(ped, 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 8.0, 8.0, 6000, 0, 0, false, false, false)  
        end
    
        local entityHealth = GetEntityHealth(ped)
        local entityMaxHealth = GetEntityMaxHealth(ped)
        if entityHealth + value < entityMaxHealth then
            SetEntityHealth(ped, entityHealth + value)
        else
            SetEntityHealth(ped, entityMaxHealth)
        end
    
        SendNotify(16)

        Citizen.Wait(5000)
        InHealing = false
    else 
        SendNotify(30)
    end
end)

RegisterCommand('closedoors', function()
    local closestVeh, closestVehicleDistance = GetClosestVehicleFunction()
    SetVehicleDoorShut(closestVeh, 2, false) 
	Citizen.Wait(500)
	SetVehicleDoorShut(closestVeh, 3, false)
end)

-----------------------------------------------------------
----------------------| usable beds |----------------------
-----------------------------------------------------------

if Config.Commands.Bed.Use then
    ClosestBed = nil

    TriggerEvent('chat:addSuggestion', '/'.. Config.Commands.Bed.Command ..'', Config.Commands.Bed.Suggestion)

    RegisterCommand(Config.Commands.Bed.Command, function()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if not IsEntityPlayingAnim(playerPed, 'missfbi1', 'cpr_pumpchest_idle', 3) then
            for k,v in pairs(Config.Commands.Bed.Objects) do
                local hash = v
                if type(hash) ~= 'number' then hash = GetHashKey(hash) end
                ClosestBed = GetClosestObjectOfType(playerCoords, 2.5, hash, false, false)

                if ClosestBed ~= 0 then
                    local BedCoords, BedHeading = GetEntityCoords(ClosestBed), GetEntityHeading(ClosestBed)

                    local closestPlayer, closestDistance = GetClosestPlayerFunction({BedCoords.x, BedCoords.y, BedCoords.z})
                    if (closestPlayer == -1 or GetDistanceBetweenCoords(GetEntityCoords(ClosestBed), GetEntityCoords(GetPlayerPed(closestPlayer)), true) > 1.5) then
                    
                        SetEntityCoords(playerPed, BedCoords)
                        SetEntityHeading(playerPed, (BedHeading+180))

                        loadAnimDict('missfbi1')
                        TaskPlayAnim(playerPed, 'missfbi1', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
                    else
                        SendNotify(27)
                        break
                    end
                end
            end

            Citizen.Wait(500)

            if ClosestBed == 0 and not IsEntityPlayingAnim(playerPed, 'missfbi1', 'cpr_pumpchest_idle', 3) then
                SendNotify(15)
                ClosestBed = nil
            end
        else
            ClearPedTasks(playerPed)
            ClosestBed = nil
        end
    end)
end

RegisterNetEvent('brutal_ambulancejob:client:putonBED')
AddEventHandler('brutal_ambulancejob:client:putonBED', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    DetachEntity(playerPed, true, true)
    Citizen.Wait(100)
    ClearPedTasks(playerPed)

    for k,v in pairs(Config.Commands.Bed.Objects) do
        local hash = v
        if type(hash) ~= 'number' then hash = GetHashKey(hash) end
        ClosestBed = GetClosestObjectOfType(playerCoords, 2.5, hash, false, false)

        if ClosestBed ~= 0 then
            local BedCoords, BedHeading = GetEntityCoords(ClosestBed), GetEntityHeading(ClosestBed)

            local closestPlayer, closestDistance = GetClosestPlayerFunction({BedCoords.x, BedCoords.y, BedCoords.z})
            if (closestPlayer == -1 or GetDistanceBetweenCoords(GetEntityCoords(ClosestBed), GetEntityCoords(GetPlayerPed(closestPlayer)), true) > 1.5) then

                SetEntityCoords(playerPed, BedCoords)
                SetEntityHeading(playerPed, (BedHeading+180))

                loadAnimDict('missfbi1')
                TaskPlayAnim(playerPed, 'missfbi1', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
            else
                SendNotify(27)
                break
            end
        end
    end
end)

-----------------------------------------------------------
------------------------| exports |------------------------
-----------------------------------------------------------

function getAvailableDoctorsCount()
    return AvailableMedicers
end

function IsDead()
    return PlayerData.deathStatus
end

-----------------------------------------------------------
--------------------| basic functions |--------------------
-----------------------------------------------------------

RegisterNetEvent('brutal_ambulancejob:client:SendNotify')
AddEventHandler('brutal_ambulancejob:client:SendNotify', function(title, text, time, type)
	notification(title, text, time, type)
end)

function SendNotify(Number)
    notification(Config.Notify[Number][1], Config.Notify[Number][2], Config.Notify[Number][3], Config.Notify[Number][4])
end

function CreateVehicleFunction(model, coords)
    local ped = GetPlayerPed(-1)
    local closestVeh = GetClosestVehicleFunction(vector3(coords[1], coords[2], coords[3]))

    if closestVeh == -1 or #(GetEntityCoords(closestVeh) - vector3(coords[1], coords[2], coords[3])) >= 5.0 then
        DoScreenFadeOut(400)
        Citizen.Wait(400)

        while not HasModelLoaded(GetHashKey(model)) do
            RequestModel(GetHashKey(model))
            Citizen.Wait(0)
        end
        AmbulanceVehicle = CreateVehicle(GetHashKey(model), coords, true, false)
        local id = NetworkGetNetworkIdFromEntity(AmbulanceVehicle)
        SetNetworkIdCanMigrate(id, true)
        SetEntityAsMissionEntity(AmbulanceVehicle, true, true)
        SetVehicleHasBeenOwnedByPlayer(AmbulanceVehicle, true)
        SetVehicleNeedsToBeHotwired(AmbulanceVehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(AmbulanceVehicle, 'OFF')
        SetVehicleNumberPlateText(AmbulanceVehicle, GenerateAmbulancePlace())
        SetVehicleDirtLevel(AmbulanceVehicle, 0)
        SetPedIntoVehicle(ped, AmbulanceVehicle, -1)
        SetVehicleLivery(AmbulanceVehicle, 0)

        Citizen.Wait(300)
        DoScreenFadeIn(600)

        -- Camera Rotation Fix
        SetGameplayCamRelativeHeading(GetEntityHeading(ped)-coords[4])
        SetGameplayCamRelativePitch(90, 1.0)

        TriggerEvent('brutal_ambulancejob:client:utils:CreateVehicle', AmbulanceVehicle)

        Citizen.Wait(800)

        Citizen.CreateThread(function()
            liveryCount = GetVehicleLiveryCount(AmbulanceVehicle)
            liveryCurrent = 0

            SendNUIMessage({action = "LiveryMenu", livery = liveryCurrent})

            while true do
                local playerPed = PlayerPedId()

                if GetEntitySpeed(playerPed) > 0.5 then
                    SendNUIMessage({action = "HideLiveryMenu"})
                    break
                end

                if IsControlJustPressed(0, 174) then
                    if liveryCurrent-1 >= 0 then
                        liveryCurrent -= 1
                    else
                        liveryCurrent = liveryCount
                    end
                    SetVehicleLivery(AmbulanceVehicle, liveryCurrent)
                    SendNUIMessage({action = "LiveryMenu", livery = liveryCurrent})
                end

                if IsControlJustPressed(0, 175) then
                    if liveryCurrent+1 <= liveryCount then
                        liveryCurrent += 1
                    else
                        liveryCurrent = 0
                    end
                    SetVehicleLivery(AmbulanceVehicle, liveryCurrent)
                    SendNUIMessage({action = "LiveryMenu", livery = liveryCurrent})
                end

                Citizen.Wait(1)
            end
        end)
    else
        SendNotify(3)
    end
    
    return Vehicle
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do        
        Citizen.Wait(1)
    end
end

function RequestSpawnObject(object)
    local hash = GetHashKey(object)
    RequestModel(hash)
    while not HasModelLoaded(hash) do 
        Wait(1)
    end
end

-----------------------------------------------------------
-----------------| NOT RENAME THE SCRIPT |-----------------
-----------------------------------------------------------

Citizen.CreateThread(function()
    Citizen.Wait(1000*30)
	if GetCurrentResourceName() ~= 'brutal_ambulancejob' then
		while true do
			Citizen.Wait(1)
			print("Please don't rename the script! Please rename it back to 'brutal_ambulancejob'")
		end
	end
end)