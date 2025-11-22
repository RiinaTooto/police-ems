RegisterNUICallback("UseButton", function(data)
	if data.action == 'close' then
		CloseMenuUtil()
		InvoicesTargetID = nil
		MedicerMenuTargetID = nil
		
		if DoesEntityExist(tab) then
			DeleteEntity(tab)
			ClearPedTasks(GetPlayerPed(-1))
		end
	elseif data.action == 'interactionmenu' then
		if data.table.Type == 'cloakroom' then
			if data.id == 'citizen_wear' then
				CitizenWear()
			else
				setUniform(Config.Uniforms[tonumber(data.id)])
			end
		elseif data.table.Type == 'garage' then
			CreateVehicleFunction(data.id, SpawnCoords)
		end
	elseif data.action == 'armory' then
		CloseMenuUtil()
		InventoryOpenFunction('society', PlayerData.job.name)
	elseif data.action == 'armory-shop' then
		local Table = {}
		if Config.AmbulanceJob.Job == PlayerData.job.name then
			for k,v in pairs(Config.AmbulanceJob.Shop) do
				if PlayerData.job.grade >= v.minGrade then
					table.insert(Table, v)
				end
			end
			OpenMenuUtil()
			SendNUIMessage({action = "OpenShopMenu", items = Table, moneyform = Config.MoneyForm, card = true})
		end
	elseif data.action == 'BuyInShop' then
		local BuyItems = data.BuyItems
        local BuyItemsTable = {}
        local TotalMoney = 0
        for i = 1, #BuyItems do
           TotalMoney = TotalMoney + BuyItems[i][2]*BuyItems[i][3]
            table.insert(BuyItemsTable, {item = BuyItems[i][1], label = BuyItems[i][4], amount = BuyItems[i][2], price = BuyItems[i][3]})
        end

        TSCB('brutal_ambulancejob:server:GetPlayerMoney', function(wallet)
			local PlayerMoney = 0
			if data.paytype == 'money' then
				PlayerMoney = wallet.money
			else
				PlayerMoney = wallet.bank
			end

            if PlayerMoney >= TotalMoney and #BuyItemsTable ~= 0 then
                TriggerServerEvent('brutal_ambulancejob:server:AddItem', BuyItemsTable, data.paytype)
            else
                SendNotify(12)
            end
        end)
		elseif data.action == 'MDTCitizenCall' then
		if data.type == 'getcalls' then
			TSCB('brutal_ambulancejob:server:GetCalls', function(Calls)
				SendNUIMessage({action = "MDTGetCalls", table = Calls, myid = GetPlayerServerId(PlayerId())})
			end)
		elseif data.type == 'accept' then
			TriggerServerEvent('brutal_ambulancejob:server:citizencall', data.type, data.tableid)
		elseif data.type == 'blip' then
			if CallBlips[data.tableid] == nil then
				local CallBlip = AddBlipForCoord(data.coords[1], data.coords[2], data.coords[3])
				SetBlipSprite(CallBlip, 66)
				SetBlipColour(CallBlip, 1)
				SetBlipScale(CallBlip, 1.0)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName('Call #'..data.tableid)
				EndTextCommandSetBlipName(CallBlip)
				SetBlipAsShortRange(CallBlip, true)
				
				SetNewWaypoint(data.coords[1], data.coords[2])
				

				CallBlips[data.tableid] = CallBlip
			end
		elseif data.type == 'close' then
			TriggerServerEvent('brutal_ambulancejob:server:citizencall', data.type, data.tableid, data.text)
		elseif data.type == 'create' then
			local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
            streetLabel = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
			TriggerServerEvent('brutal_ambulancejob:server:citizencall', 'create', data.text, {x,y,z}, streetLabel)
		end
	elseif data.action == 'MDTInvoices' then
		if data.type == 'get' then
			local closestPlayer, closestDistance = GetClosestPlayerFunction()
			InvoicesTargetID = nil

            if closestPlayer ~= -1 and closestDistance < 3.0 then
				InvoicesTargetID = GetPlayerServerId(closestPlayer)
			end

			TSCB('brutal_ambulancejob:server:GetInvoiceTypes', function(DataTable)
				SendNUIMessage({action = "MDTGetInvoiceTypes", table = DataTable.invoices, targetname = DataTable.targetname})
			end, InvoicesTargetID)
		elseif data.type == 'create' then
			TriggerServerEvent('brutal_ambulancejob:server:CreateNewInvoiceType', data.label, data.amount)
		elseif data.type == 'delete' then
			TriggerServerEvent('brutal_ambulancejob:server:RemoveInvoiceType', tonumber(data.number))
		elseif data.type == 'give' then
			TriggerServerEvent('brutal_ambulancejob:server:GiveInvoice', InvoicesTargetID, data.label, data.amount)
		end
	elseif data.action == 'MedicerMenu' then
		if data.type == 'useitem' then
			TSCB('brutal_ambulancejob:server:removeMedicerItems', function(success)
				if success then
					if data.you then
						local ped = GetPlayerPed(-1)
						loadAnimDict('anim@heists@narcotics@funding@gang_idle')
        				TaskPlayAnim(ped, 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 8.0, 8.0, 6000, 0, 0, false, false, false)  
						Citizen.CreateThread(function()
							MyDamages.bleeding = false
							BleedingCooldown = true
							Citizen.Wait(1000*60*5)
							BleedingCooldown = false
						end)
					else
						TriggerServerEvent('brutal_ambulancejob:server:MedicerMenuUseItem', MedicerMenuTargetID, data.item, data.part)
					end
					Citizen.Wait(2001)
					if InMenu then
						TriggerEvent('brutal_ambulancejob:client:MedicerMenuCommand')
					end
				else
					SendNotify(13)
				end
			end, data.item)
		end
	elseif data.action == 'JobMenu' then
		if data.id == 'carry' then
			local ped = GetPlayerPed(-1)
			local closestPlayer, closestDistance = GetClosestPlayerFunction()

    		if closestPlayer ~= -1 and closestDistance < 3.0 then
				if not InCarry then
					InCarry = true
					TriggerServerEvent('brutal_ambulancejob:server:carry', GetPlayerServerId(closestPlayer))
					loadAnimDict('anim@heists@box_carry@')
					TaskPlayAnim(ped, 'anim@heists@box_carry@',  'idle', 8.0, 8.0, -1, 49, 0, false, false, false)

					while InCarry do
						Citizen.Wait(500)
			
						if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@',  'idle', 3) then
							TaskPlayAnim(ped, 'anim@heists@box_carry@',  'idle', 8.0, 8.0, -1, 49, 0, false, false, false)
						end
					end
				else
					InCarry = false
					TriggerServerEvent('brutal_ambulancejob:server:carry', GetPlayerServerId(closestPlayer))
					Citizen.Wait(500)
					ClearPedTasks(ped)
				end
			else
				SendNotify(14)
			end
		elseif data.id == 'ecg' then
			if not DoesEntityExist(MedicerEcg) then
				local ped = GetPlayerPed(-1)
				loadAnimDict("missheistdocksprep1hold_cellphone")
				TaskPlayAnim(ped, "missheistdocksprep1hold_cellphone", "static", 2.0, 2.0, -1, 1, 0, false, false, false)
		
				off1, off2, off3, rot1, rot2, rot3 = table.unpack(Config.MedicItems['ecg'].pos)
				local x,y,z = table.unpack(GetEntityCoords(ped))
				RequestSpawnObject(Config.MedicItems['ecg'].prop)
				MedicerEcg = CreateObject(GetHashKey(Config.MedicItems['ecg'].prop), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(MedicerEcg, ped, GetPedBoneIndex(ped, 57005), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
				SetModelAsNoLongerNeeded(Config.MedicItems['ecg'].prop)
			else
				DeleteEntity(MedicerEcg)
			end
		elseif data.id == 'bag' then
			if not DoesEntityExist(MedicerBag) then
				local ped = GetPlayerPed(-1)
				loadAnimDict("missheistdocksprep1hold_cellphone")
				TaskPlayAnim(ped, "missheistdocksprep1hold_cellphone", "static", 2.0, 2.0, -1, 1, 0, false, false, false)
		
				off1, off2, off3, rot1, rot2, rot3 = table.unpack(Config.MedicItems['bag'].pos)
				local x,y,z = table.unpack(GetEntityCoords(ped))
				RequestSpawnObject(Config.MedicItems['bag'].prop)
				MedicerBag = CreateObject(GetHashKey(Config.MedicItems['bag'].prop), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(MedicerBag, ped, GetPedBoneIndex(ped, 57005), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
				SetModelAsNoLongerNeeded(Config.MedicItems['bag'].prop)
			else
				DeleteEntity(MedicerBag)
			end
		elseif data.id == 'wheelchair' then
			local playerPed = PlayerPedId()
			local closestVeh, closestVehicleDistance = GetClosestVehicleFunction()
			
			if closestVeh ~= -1 and closestVehicleDistance < 10.0 and GetEntityModel(closestVeh) == GetHashKey(Config.WheelchairVehicle) then
				NetworkRegisterEntityAsNetworked(closestVeh)
				NetworkRequestControlOfEntity(closestVeh)
				SetEntityAsMissionEntity(closestVeh)

				DeleteEntity(closestVeh)

				Citizen.Wait(100)
				ClearPedTasks(playerPed)
			else

				RequestSpawnObject(Config.WheelchairVehicle)
				local wheelchair = CreateVehicle(GetHashKey(Config.WheelchairVehicle), GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.5, -0.98), true, true)
				SetEntityAsMissionEntity(wheelchair, true, true)
				SetVehicleHasBeenOwnedByPlayer(wheelchair, true)
				SetVehicleNeedsToBeHotwired(wheelchair, false)
				SetModelAsNoLongerNeeded(Config.WheelchairVehicle)
				SetVehRadioStation(wheelchair, 'OFF')
				SetVehicleDirtLevel(wheelchair, 0)
				SetEntityHeading(wheelchair, GetEntityHeading(playerPed))
			end
		elseif data.id == 'spawn' then
			local ped = GetPlayerPed(-1)
			local closestObject = GetClosestObjectOfType(GetEntityCoords(ped), 3.0, GetHashKey("prop_ld_binbag_01"), false)
			NetworkRegisterEntityAsNetworked(closestObject)
			NetworkRequestControlOfEntity(closestObject)
			SetEntityAsMissionEntity(closestObject)

			if not IsEntityAttachedToAnyVehicle(closestObject) and not IsEntityAttachedToAnyObject(closestObject) then
				if not DoesEntityExist(closestObject) then
					StretcherData = {pushing = false, puton = nil}

					RequestSpawnObject('prop_ld_binbag_01')
					str = CreateObject(GetHashKey('prop_ld_binbag_01'), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.5, -0.98), true)
					SetEntityHeading(str, GetEntityHeading(PlayerPedId()))
					FreezeEntityPosition(str, true)
				else
					DeleteEntity(closestObject)
					Citizen.Wait(100)
					ClearPedTasks(ped)
				end
			else
				SendNotify(22)
			end
		elseif data.id == 'push' then
			local pedCoords = GetEntityCoords(GetPlayerPed(-1))
			local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("prop_ld_binbag_01"), false)

			NetworkRegisterEntityAsNetworked(closestObject)
			NetworkRequestControlOfEntity(closestObject)
			SetEntityAsMissionEntity(closestObject)

			if StretcherData.pushing == false then
				if not IsEntityAttachedToAnyPed(closestObject) and not IsEntityAttachedToAnyVehicle(closestObject) and not IsEntityAttachedToAnyObject(closestObject) then
					if DoesEntityExist(closestObject) then
						local strCoords = GetEntityCoords(closestObject)
						local strVecForward = GetEntityForwardVector(closestObject)
						local sitCoords = (strCoords + strVecForward * - 0.5)
						local pickupCoords = (strCoords + strVecForward * 0.3)
						if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 2.0 then

							local closestPlayer, closestPlayerDist = GetClosestPlayerFunction()
							if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
								if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'anim@heists@box_carry@', 'idle', 3) then
									SendNotify(18)
									return
								end
							end

							StretcherData.pushing = true

							NetworkRequestControlOfEntity(closestObject)
							loadAnimDict("anim@heists@box_carry@")
							local playerPed = PlayerPedId()
							Citizen.Wait(500)
							TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
							AttachEntityToEntity(closestObject, GetPlayerPed(-1), GetPlayerPed(-1), -0.05, 1.3, -0.345 , 180.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
							while IsEntityAttachedToEntity(closestObject, playerPed) do
								Citizen.Wait(1)
								
								SetEntityVisible(GetPlayerPed(closestPlayer), true, 0)

								if not IsEntityPlayingAnim(playerPed, 'anim@heists@box_carry@', 'idle', 3) then
									ClearPedTasks(playerPed)
									TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
								end

								if IsPedDeadOrDying(playerPed) or IsControlJustPressed(0, 73) then
									DetachEntity(closestObject, true, true)
									FreezeEntityPosition(closestObject, true)
									ClearPedTasks(playerPed)
									StretcherData.pushing = false
								end

							end
						end
					end
				else
					SendNotify(22)
				end
			else
				local playerPed = PlayerPedId()
				DetachEntity(closestObject, true, true)
				StretcherData.pushing = false
				Citizen.Wait(100)
				ClearPedTasks(playerPed)
			end
		elseif data.id == 'bed' then
			local ped = GetPlayerPed(-1)
			local closestPlayer, closestDistance = GetClosestPlayerFunction()
			local closestObject = GetClosestObjectOfType(GetEntityCoords(ped), 3.0, GetHashKey("prop_ld_binbag_01"), false)

    		if closestPlayer ~= -1 and closestDistance < 3.0 then
				if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), "anim@gangops@morgue@table@", "body_search", 3) then
					TriggerServerEvent('brutal_ambulancejob:server:putonBED', GetPlayerServerId(closestPlayer))
					StretcherData.puton = nil
					DetachEntity(closestObject, true, true)
					FreezeEntityPosition(closestObject, true)
					StretcherData.pushing = false
					Citizen.Wait(100)
					ClearPedTasks(ped)
				end
			else
				SendNotify(14)
			end
		elseif data.id == 'puton' then
			local closestPlayer, closestDistance = GetClosestPlayerFunction()
			local playerCoords = GetEntityCoords(PlayerPedId())
			local closestObject = GetClosestObjectOfType(playerCoords, 3.0, GetHashKey("prop_ld_binbag_01"), false)

			if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(closestPlayer)), GetEntityCoords(closestObject), true) <= 2.5 then
				NetworkRegisterEntityAsNetworked(closestObject)
				NetworkRequestControlOfEntity(closestObject)
				SetEntityAsMissionEntity(closestObject)

				if DoesEntityExist(closestObject) then
					if not IsEntityAttachedToAnyVehicle(closestObject) then
						if StretcherData.puton == nil then
							StretcherData.puton = GetPlayerServerId(closestPlayer)
							TriggerServerEvent('brutal_ambulancejob:server:puton', GetPlayerServerId(closestPlayer))
						elseif GetPlayerServerId(closestPlayer) == StretcherData.puton then
							StretcherData.puton = nil
							TriggerServerEvent('brutal_ambulancejob:server:puton', GetPlayerServerId(closestPlayer))
						else
							SendNotify(26)
						end
					else
						SendNotify(22)
					end
				else
					SendNotify(20)
				end
			else
				SendNotify(14)
			end
		elseif data.id == 'putin' and not InPutSpam then
			InPutSpam = true
			SetTimeout(5000, function()
				InPutSpam = false
			end)

			local playerCoords = GetEntityCoords(PlayerPedId())
			local closestVeh, closestVehicleDistance = GetClosestVehicleFunction()

			NetworkRegisterEntityAsNetworked(closestVeh)
			NetworkRequestControlOfEntity(closestVeh)
			SetEntityAsMissionEntity(closestVeh)

			local blacklisted = true
			local currentCfg
			for k,v in pairs(Config.Stretcher.Vehicles) do
				if GetHashKey(v.model:lower()) == GetEntityModel(closestVeh) then
					blacklisted = false
					currentCfg = v
				end
			end

			if not blacklisted then
				local closestObject = GetClosestObjectOfType(GetOffsetFromEntityInWorldCoords(closestVeh, currentCfg.xPos, currentCfg.yPos, currentCfg.zPos), 3.0, GetHashKey("prop_ld_binbag_01"), false)

				NetworkRegisterEntityAsNetworked(closestObject)
				NetworkRequestControlOfEntity(closestObject)
				SetEntityAsMissionEntity(closestObject)

				if DoesEntityExist(closestObject) then
					if not IsEntityAttachedToAnyVehicle(closestObject) and not IsEntityAttachedToAnyObject(closestObject) then
						if closestVehicleDistance < 10 then
							if IsEntityAttachedToAnyPed(closestObject) then
								DetachEntity(closestObject, false, false)
								SetEntityCollision(closestObject, false)
								StretcherData.pushing = false
							end

							SetVehicleDoorOpen(closestVeh, 2, false, false)
							SetVehicleDoorOpen(closestVeh, 3, false, false)

							Citizen.Wait(500)

							AttachEntityToEntity(closestObject, closestVeh, 0.0, currentCfg.xPos, currentCfg.yPos, currentCfg.zPos, currentCfg.xRot, currentCfg.yRot, currentCfg.zRot, false, false, false, false, 2, true)

							Citizen.Wait(25)
							ClearPedTasks(PlayerPedId())
						else
							SendNotify(21)
						end
					else
						SetVehicleDoorOpen(closestVeh, 2, false, false)
						SetVehicleDoorOpen(closestVeh, 3, false, false)

						Citizen.Wait(500)

						DetachEntity(closestObject, true, true)
						FreezeEntityPosition(closestObject, false)
						local coords = GetOffsetFromEntityInWorldCoords(closestVeh, 0.0, currentCfg.offsetY, 0.0)
						SetEntityCoords(closestObject, coords.x,coords.y,coords.z)
						PlaceObjectOnGroundProperly(closestObject)
						FreezeEntityPosition(closestObject, true)

						Citizen.Wait(2000)
						SetVehicleDoorShut(closestVeh, 2, false) 
						SetVehicleDoorShut(closestVeh, 3, false)
					end
				else
					SendNotify(20)
				end
			else
				SendNotify(25)
			end
		elseif data.id == 'medicer_menu' then
			InMenu = false
			TriggerEvent('brutal_ambulancejob:client:MedicerMenuCommand')
		elseif data.id == 'mdt' then
			InMenu = false
			TriggerEvent('brutal_ambulancejob:client:MDTCommand')
		end
	end
end)

AddEventHandler('CEventOpenDoor', function(entities, eventEntity, args)
    if StretcherData.pushing and not InDoorNear then
		InDoorNear = true
		local playerPed = PlayerPedId()
		local closestObject = GetClosestObjectOfType(GetEntityCoords(playerPed), 3.0, GetHashKey("prop_ld_binbag_01"), false)
		AttachEntityToEntity(closestObject, GetPlayerPed(-1), GetPlayerPed(-1), -0.05, 1.3, -0.345 , 180.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)
		Citizen.Wait(5000)
		InDoorNear = false
		if StretcherData.pushing then
			AttachEntityToEntity(closestObject, playerPed, GetPedBoneIndex(playerPed,  28422), 0.0, -0.8, -0.80, -15.0, 0.0, 180.0, 0.0, false, false, true, false, 2, true)
		end
	end
end)