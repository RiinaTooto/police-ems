function SendNotify(Number)
    notification(Config.Notify[Number][1], Config.Notify[Number][2], Config.Notify[Number][3], Config.Notify[Number][4])
end

function CreateVeh(model, coords)
    while not HasModelLoaded(GetHashKey(model)) do
		RequestModel(GetHashKey(model))
		Citizen.Wait(0)
	end
    local Vehicle = CreateVehicle(GetHashKey(model), coords.x, coords.y, coords.z, coords.heading, true, false)
    local id = NetworkGetNetworkIdFromEntity(Vehicle)
    SetNetworkIdCanMigrate(id, true)
    SetEntityAsMissionEntity(Vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(Vehicle, true)
    SetVehicleNeedsToBeHotwired(Vehicle, false)
    SetModelAsNoLongerNeeded(model)
    SetVehRadioStation(Vehicle, 'OFF')
    SetVehicleNumberPlateText(Vehicle, string.sub(Config.PlateText, 1, 5)..' '..Details.MemberID)
    SetVehicleDirtLevel(Vehicle, 0)
    FreezeEntityPosition(Vehicle, true)
    SetPedIntoVehicle(GetPlayerPed(-1), Vehicle, -1)
    TriggerEvent('brutal_vehicleshop:client:utils:CreateVehicle', Vehicle)
    
    if Config.StartAnimation then
        local isMovingCamera = true

        CreateThread(function()
            while isMovingCamera do
                Wait(0)
                DisableControlAction(0,1,true)
                DisableControlAction(0,2,true)
            end
        end)

        local forwardVector, rightVector, upVector, position = GetEntityMatrix(Vehicle)
        local forwardCoords, rightCoords, upCoords = forwardVector*5, rightVector*3, upVector*2
        local cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (GetEntityCoords(Vehicle)+forwardCoords+rightCoords+upCoords).xyz, (GetEntityRotation(Vehicle)+vector3(-20,0,-210)).xyz, GetGameplayCamFov() * 1.0)
        SetCamAffectsAiming(cam1, false)
        local forwardCoords, rightCoords, upCoords = forwardVector*3, rightVector*-1.5, upVector*0.5
        local cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (GetEntityCoords(Vehicle)+forwardCoords+rightCoords+upCoords).xyz, (GetEntityRotation(Vehicle)+vector3(-20,0,-150)).xyz, GetGameplayCamFov() * 1.0)
        SetCamAffectsAiming(cam2, false)
        local forwardCoords, rightCoords, upCoords = forwardVector*0, rightVector*-2, upVector*0
        local cam3 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", (GetEntityCoords(Vehicle)+forwardCoords+rightCoords+upCoords).xyz, (GetEntityRotation(Vehicle)+vector3(0,0,-100)).xyz, GetGameplayCamFov() * 1.0)
        SetCamAffectsAiming(cam3, false)
        SetCamActiveWithInterp(cam2, cam1, math.floor(3700))
        RenderScriptCams(true, false, 0, true, false)
        Wait(math.floor(3700))
        SetCamActive(cam3, true)
        RenderScriptCams(true, false, 0, true, false)
        SetGameplayCamRelativeRotation(GetEntityRotation(Vehicle).xyz)
        SetGameplayCamRelativePitch(-10.0, 1.0)
        RenderScriptCams(false, true, math.floor(5000), false, false)
        Wait(math.floor(5000))
        isMovingCamera = false
    end

    -- Camera Rotation Fix
    SetGameplayCamRelativeHeading(GetEntityHeading(GetPlayerPed(-1))-coords.heading)
    SetGameplayCamRelativePitch(90, 1.0)

    return Vehicle
end

function TeleportFunction(x,y,z)
	if PlayerDied() == false then
		SetEntityCoords(PlayerPedId(), x,y,z)
	end
end

function Countdown(_r, _g, _b, _waitTime, _playSound)
    local showCD = true
    local time = _waitTime
    local scale = 0
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
    scale = showCountdown(time, _r, _g, _b)
    Citizen.CreateThread(function()
        while showCD do
            Citizen.Wait(1000)
            if time > 1 then
                time = time - 1
                scale = showCountdown(time, _r, _g, _b)
            elseif time == 1 then
                time = time - 1
                scale = showCountdown("GO", _r, _g, _b)
            else
                showCD = false
            end
        end
    end)
    Citizen.CreateThread(function()
        while showCD do
            Citizen.Wait(1)
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
        end
    end)
end

function showCountdown(_number, _r, _g, _b)
    local scaleform = RequestScaleform('COUNTDOWN')

    CallFunction(scaleform, false, "SET_MESSAGE", _number, _r, _g, _b, true)
    CallFunction(scaleform, false, "FADE_MP", _number, _r, _g, _b)

    return scaleform
end

function MidsizeBanner(_title, subtitle, _bannerColor, _waitTime, _playSound)
    local showMidBanner = true
    local scale = 0
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
    scale = showMidsizeBanner(_title, subtitle, _bannerColor)
    Citizen.CreateThread(function()
        Citizen.Wait((_waitTime * 1000) - 1000)
        CallFunction(scale, false, "SHARD_ANIM_OUT", 2, 0.3, true)
        Citizen.Wait(1000)
        showMidBanner = false
    end)
    Citizen.CreateThread(function()
        while showMidBanner do
            Citizen.Wait(1)
            DrawScaleformMovieFullscreen(scale, 255, 255, 255, 255)
        end
    end)
end

function showMidsizeBanner(_title, _subtitle, _bannerColor)
    local scaleform = RequestScaleform('MIDSIZED_MESSAGE')

    CallFunction(scaleform, false, "SHOW_COND_SHARD_MESSAGE", _title, _subtitle, _bannerColor, true)

    return scaleform
end

function RankShow(_role, _nameString, _x, _y, _waitTime, _playSound)
    showCreditsBanner = true
    if _playSound ~= nil and _playSound == true then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    end
    showCredits(_role, _nameString, _x, _y)
    Citizen.CreateThread(function()
        Citizen.Wait(tonumber(_waitTime) * 1000)
        showCreditsBanner = false
    end)
end

function showCredits(_role, _name, _x, _y)
    Citizen.CreateThread(function()
        function drawCredits(role, name)
            local scaleform = RequestScaleformMovie("OPENING_CREDITS")
            while not HasScaleformMovieLoaded(scaleform) do
                Citizen.Wait(0)
            end

            CallFunction(scaleform, false, "TEST_CREDIT_BLOCK", role, name, 'left', 0.0, 50.0, 1, 5, 10, 10)
            return scaleform
        end
        local scale = drawCredits(_role, _name)
        while showCreditsBanner do
            Citizen.Wait(1)
            DrawScaleformMovie(scale, _x, _y, 0.71, 0.68, 255, 255, 255, 255)
        end
    end)
end

function RequestScaleform(scaleform)
    local scaleform_handle = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform_handle) do
        Citizen.Wait(0)
    end
    return scaleform_handle
end

function CallFunction(scaleform, returndata, the_function, ...)
    BeginScaleformMovieMethod(scaleform, the_function)
    local args = {...}

    if args ~= nil then
        for i = 1,#args do
            local arg_type = type(args[i])

            if arg_type == "boolean" then
                ScaleformMovieMethodAddParamBool(args[i])
            elseif arg_type == "number" then
                if not string.find(args[i], '%.') then
                    ScaleformMovieMethodAddParamInt(args[i])
                else
                    ScaleformMovieMethodAddParamFloat(args[i])
                end
            elseif arg_type == "string" then
                ScaleformMovieMethodAddParamTextureNameString(args[i])
            end
        end

        if not returndata then
            EndScaleformMovieMethod()
        else
            return EndScaleformMovieMethodReturnValue()
        end
    end
end

function showScaleform(title, desc, sec)
	function Initialize(scaleform)
		local scaleform = RequestScaleformMovie(scaleform)

		while not HasScaleformMovieLoaded(scaleform) do
			Citizen.Wait(0)
		end
		PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		PushScaleformMovieFunctionParameterString(title)
		PushScaleformMovieFunctionParameterString(desc)
		PopScaleformMovieFunctionVoid()
		return scaleform
	end
	scaleform = Initialize("mp_big_message_freemode")
	while sec > 0 do
		sec = sec - 0.02
		Citizen.Wait(0)
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
	end
	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function DisableControls()
    Citizen.CreateThread(function()
        while FinishRace == false do 
            Citizen.Wait(0)
            if IsInVehicle() then
                for k,v in pairs(Config.DisableControls) do
                    DisableControlAction(0,v,true)
                    DisableControlAction(2,v,true)
                end
            else
                Citizen.Wait(1000)
            end
        end
    end)
end

function IsInVehicle()
    local ply = GetPlayerPed(-1)
    if IsPedSittingInAnyVehicle(ply) then
      return true
    else
      return false
    end
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
  
    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end

function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end

    return sum
end

function min(t, fn)
    if #t == 0 then return nil, nil end
    local value = t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            value = t[i]
        end
    end
    return value
end