RegisterNetEvent('brutal_atm_robbery:client:ServerNotify')
AddEventHandler('brutal_atm_robbery:client:ServerNotify', function(data, data2, data3)
  notification(data, data2, data3)
end)

RegisterNetEvent("brutal_atm_robbery:client:UseItem")
AddEventHandler("brutal_atm_robbery:client:UseItem", function()
    local playerPed = PlayerPedId()
    if NearATM() then
        TSCB('brutal_atm_robbery:server:GetCops', function(Enough)
            if Enough then
                TriggerServerEvent('brutal_atm_robbery:server:RemoveItem', Config['Item'])
                TriggerServerEvent('brutal_atm_robbery:server:SendToDiscord')
                TriggerServerEvent('brutal_atm_robbery:server:Timer')
                StartDrilling()
            end
        end)
    end
end)

function NearATM() 
    atms = Config['Models']
    i, imax = 1, #Config['Models'] + 1

    while i < imax do
        Citizen.Wait(1)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        AtmHash = atms[i]

        AtmProp = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.5, GetHashKey(AtmHash), false, true ,true)

        if AtmProp > 0 then
            return true
        end
        i = i+1
    end
end


------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------[ DRILLING ANIMATION ]---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

function StartDrilling()
    local ped = PlayerPedId()
    local player = GetPlayerPed(-1)
    local animDict = "anim@heists@fleeca_bank@drilling"
    local animLib = "drill_straight_idle"

    FreezeEntityPosition(player, true)
    AtmHeading = GetEntityHeading(AtmProp)
    AtmCoords = GetEntityCoords(AtmProp)
    SetEntityHeading(PlayerPedId(), AtmHeading)
    loadAnimDict(animDict)
    TaskPlayAnim(player, animDict , animLib ,8.0, -8.0, -1, 1, 0, false, false, false )
    AttachEntityToEntity(player, AtmProp, 0, 0.1, -0.700, 1.046, 0.0, 0.0, 0.0, true, true, true, true, 1, true)
    PoliceAlert(AtmProp)

    local drillProp = GetHashKey('hei_prop_heist_drill')
    local boneIndex = GetPedBoneIndex(player, 28422)

    RequestModel(drillProp)
    while not HasModelLoaded(drillProp) do
        Citizen.Wait(100)
    end

    attachedDrill = CreateObject(drillProp, 1.0, 1.0, 1.0, 1, 1, 0)
    AttachEntityToEntity(attachedDrill, player, boneIndex, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
                            
    SetEntityAsMissionEntity(attachedDrill, true, true)

    RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
    RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
    RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
    drillSound = GetSoundId()
    Citizen.Wait(100)
    PlaySoundFromEntity(drillSound, "Drill", attachedDrill, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
    Citizen.Wait(100)	

    ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.0)

    local particleDictionary = "scr_fbi5a"
	local particleName = "scr_bio_cutter_flame"

	RequestNamedPtfxAsset(particleDictionary)
	while not HasNamedPtfxAssetLoaded(particleDictionary) do
		Citizen.Wait(0)
	end

	SetPtfxAssetNextCall(particleDictionary)
	effect = StartParticleFxLoopedOnEntity(particleName, attachedDrill, -0.01, -0.65, 0.00, -0, -0, 20, 2.0, 0, 0, 0)
	Citizen.Wait(100)
    
    Drilling.Start(function(status)
            if status then
            StopParticleFxLooped(effect, 0)
            ClearPedTasksImmediately(player)
            StopSound(drillSound)
            ReleaseSoundId(drillSound)
            DeleteObject(attachedDrill)
            DeleteEntity(attachedDrill)
            StopGameplayCamShaking(true)
            ClearPedTasksImmediately(PlayerPedId())
            FreezeEntityPosition(player, false)
            DetachEntity(player)
            Citizen.Wait(1000)
            GrabCashAnim()
        else
            StopParticleFxLooped(effect, 0)
            ClearPedTasksImmediately(player)
            StopSound(drillSound)
            ReleaseSoundId(drillSound)
            DeleteObject(attachedDrill)
            DeleteEntity(attachedDrill)
            StopGameplayCamShaking(true)
            ClearPedTasksImmediately(PlayerPedId())
            FreezeEntityPosition(player, false)
            DetachEntity(player)
            Citizen.Wait(1000)
            notification(Config['Notification'][1][1], Config['Notification'][1][2], Config['Notification'][1][3], Config['Notification'][1][4])
        end
    end)
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do        
        Citizen.Wait(1)
    end
end

function GrabCashAnim()
	local player = GetPlayerPed(-1)
    local ped = PlayerPedId()
	local animDict = "anim@heists@ornate_bank@grab_cash"
	local animName = "grab"

    loadAnimDict(animDict)
	local targetPosition, targetRotation = (GetOffsetFromEntityInWorldCoords(AtmProp, 0, 0, 0)), GetEntityRotation(AtmProp)
    local animPos = GetAnimInitialOffsetPosition(animDict, animName, targetPosition, targetRotation, 0, 2)

    local netScene = NetworkCreateSynchronisedScene(targetPosition.x, targetPosition.y, targetPosition.z+0.5, targetRotation.x+180, targetRotation.y-180, targetRotation.z+2.91, 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, netScene, animDict, animName, 1.5, -4.0, 1, 16, 1148846080, 0)

    SetPedComponentVariation(PlayerPedId(), 5, 0, 0, 0)

    bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), targetPosition, 1, 1, 0)
	NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, "bag_grab", 4.0, -8.0, 1)

    NetworkStartSynchronisedScene(netScene)

    Citizen.Wait(GetAnimDuration(animDict, animName) * 150)

	NetworkStopSynchronisedScene(netScene)
    DeleteObject(bag)
    SetPedComponentVariation(PlayerPedId(), 5, 45, 0, 0)

    TriggerServerEvent('brutal_atm_robbery:server:AddPlayerMoney', math.random(Config['Reward']['Min'], Config['Reward']['Max']))
end

------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------[ POLICE ALERT ]--------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

function PoliceAlert(Atm)
    local coords = GetEntityCoords(Atm)
    TriggerServerEvent('brutal_atm_robbery:server:PoliceAlert', coords)  
end

------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------[ SCRIPT RESTART ]-------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then 
        DetachEntity(GetPlayerPed(-1))
        ClearPedTasksImmediately(GetPlayerPed(-1))
            StopSound(drillSound)
            ReleaseSoundId(drillSound)
            DeleteObject(attachedDrill)
            DeleteEntity(attachedDrill)
            FreezeEntityPosition(player, false)
            StopGameplayCamShaking(true)
            ClearPedTasksImmediately(PlayerPedId())
            DeleteObject(bag)
    end
end)