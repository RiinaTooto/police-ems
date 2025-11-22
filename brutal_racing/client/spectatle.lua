function StartPlayerSpectate(Party)
	if Config.Spectate then
		if #PartyLists[Party].members > 0 then 
			SendNUIMessage({action = "OpenSpec", name = PartyLists[Party].members[SpecID].NAME, ranks = PartyLists[Party].ranks, PartyLists = PartyLists})
			spectate(PartyLists[Party].members[SpecID].ID)
		else
			Citizen.CreateThread(function()
				while true do
					Wait(1)

					if IsControlPressed(0, 202) or MenuOpen then
						SendNUIMessage({action = "CloseSpec"})
    					SendNotify(15)
						break
					end
				end
			end)
			SendNUIMessage({action = "OpenSpec", name = 'nil', ranks = PartyLists[Party].ranks, PartyLists = PartyLists})
			resetNormalCamera(Party)
		end
	end
end

SpecID = 1
InSpectatorMode = false
TargetSpectate = nil
local cam
local polarAngleDeg = 0
local azimuthAngleDeg = 90
local radius = -6.0
local PlayerDate = {}

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z - radius * math.cos(azimuthAngleRad)
	}

	return pos
end

function spectate(target)
	InSpectatorMode = false
	Citizen.Wait(2)

	local playerPed = PlayerPedId()

	SetEntityCollision(playerPed, false, false)
	SetEntityVisible(playerPed, false)

	Citizen.CreateThread(function()
		if not DoesCamExist(cam) then
			cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
		end

		SetCamActive(cam, true)
		RenderScriptCams(true, false, 0, true, true)

		InSpectatorMode = true
		TargetSpectate  = target
	end)

	SpectateThread()
end

function resetNormalCamera(Party)
	InSpectatorMode = false
	TargetSpectate  = nil
	Citizen.Wait(1)
	local playerPed = PlayerPedId()

	SetCamActive(cam, false)
	RenderScriptCams(false, false, 0, true, true)

	SetEntityCollision(playerPed, true, true)
	SetEntityVisible(playerPed, true)
	TeleportFunction(Config.Races[Party].StartPlace.x, Config.Races[Party].StartPlace.y, Config.Races[Party].StartPlace.z)
end

function SpectateThread()
	Citizen.CreateThread(function()
		while InSpectatorMode do
			Wait(0)
			local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
			local playerPed	  = PlayerPedId()
			local targetPed	  = GetPlayerPed(targetPlayerId)
			local coords	 = GetEntityCoords(targetPed)

			for i=0, 32, 1 do
				if i ~= PlayerId() then
					local otherPlayerPed = GetPlayerPed(i)
					SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
				end
			end

			if IsControlPressed(2, 241) then
				radius = radius + 2.0
			end

			if IsControlPressed(2, 242) then
				if radius - 2.0 > -40 then
					radius = radius - 2.0
				end
			end

			if radius > -1 then
				radius = -1
			end

			local xMagnitude = GetDisabledControlNormal(0, 1)
			local yMagnitude = GetDisabledControlNormal(0, 2)

			polarAngleDeg = polarAngleDeg + xMagnitude * 10

			if polarAngleDeg >= 360 then
				polarAngleDeg = 0
			end

			azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10

			if azimuthAngleDeg >= 360 then
				azimuthAngleDeg = 0
			end

			local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

			SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
			PointCamAtEntity(cam,  targetPed)
			SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 10)

			for k,v in pairs(Config.SpecDisableControls) do
				DisableControlAction(0,v,true)
			end

			if Details.Party ~= nil then
				if PartyLists[Details.Party].started then
					if IsControlJustReleased(0, 174) then
						if SpecID > 1 then
							SpecID -= 1
						elseif SpecID == 1 then
							SpecID = #PartyLists[Details.Party].members
						end
						StartPlayerSpectate(Details.Party)
					end

					if IsControlJustReleased(0, 175) then
						if SpecID < #PartyLists[Details.Party].members then
							SpecID += 1
						elseif SpecID == #PartyLists[Details.Party].members then
							SpecID = 1
						end
						StartPlayerSpectate(Details.Party)
					end
				else
					resetNormalCamera(Details.Party)
				end
			end
		end
	end)
end