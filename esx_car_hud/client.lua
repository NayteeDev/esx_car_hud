	local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

-- CONFIG

local vSyncPogoda = true 		-- ustaw na true jeśli korzystasz z vSync i wykonałeś/aś instrukcje w ReadMe.txt;

-- ZMIENNE

local prox = 10.0
local isTalking = false
local ZablokujPozycje = false
local wszedlDoGry = false
local DuzaMapaPojazd = false
local pokazalHud = false
local przesunalHud = false
local oczekiwanie = 500

-- START

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(500)
		if not wszedlDoGry then
			NetworkSetVoiceActive(false)
			NetworkSetTalkerProximity(1.0)
			wszedlDoGry = true
		end
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	NetworkSetTalkerProximity(1.0)
end)

-- HUD

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(oczekiwanie)
		local playerPed = GetPlayerPed(-1)
		if IsPedInAnyVehicle(playerPed, true) then
			oczekiwanie = 150
			local playerVeh = GetVehiclePedIsIn(playerPed, false)
			if DuzaMapaPojazd == false then
				if pokazalHud == false then
					pokazalHud = true
					SendNUIMessage({action = "toggleCar", show = true})
				end
				SendNUIMessage({action = "przesunHud", show = true})
			else
				SendNUIMessage({action = "przesunHudMapa", show = true})		
			end
			fuel = math.floor(GetVehicleFuelLevel(playerVeh)+0.0)		
			SendNUIMessage({action = "updateGas", key = "gas", value = fuel})
			PrzelaczRadar(true)
			if not DuzaMapaPojazd then
				SetRadarBigmapEnabled(false, false)
			end
			lokalizacja = false
		else
			oczekiwanie = 500
			if pokazalHud == true then
				pokazalHud = false
				SendNUIMessage({action = "toggleCar", show = false})
			end
			if not ZablokujPozycje then
				if przesunalHud == false then
					przesunalHud = true
					SendNUIMessage({action = "przesunHud", show = true})
				end
			end
			PrzelaczRadar(false)
			if IsControlPressed(1, 243) then
				PrzelaczRadar(true)
				SetRadarBigmapEnabled(true, false)
				SendNUIMessage({action = "toggleAllHud", show = true})
				SendNUIMessage({action = "przesunHudMapa", show = true})
				lokalizacja = true
			else
				SendNUIMessage({action = "toggleAllHud", show = false})
				if not ZablokujPozycje then
					SendNUIMessage({action = "przesunHudMapa", show = false})
				end
				lokalizacja = false
				if not DuzaMapaPojazd then
					SetRadarBigmapEnabled(false, false)
				end
			end
		end
	end
end)

function PrzelaczRadar(on)
	if on and not ZablokujPozycje then
		if przesunalHud == false then
			przesunalHud = true
			SendNUIMessage({action = "przesunHud", show = true})
		end
		DisplayRadar(true)
	elseif not ZablokujPozycje then
		if przesunalHud == true then
			przesunalHud = false
			SendNUIMessage({action = "przesunHud", show = false})
		end
		DisplayRadar(false)
	end
end

-- VOICE CHAT

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, 166) then
			local vprox
			if prox <= 2.5 then
				prox = 10.0
				vprox = "normal"
			elseif prox == 10.0 then
				prox = 26.0
				vprox = "shout"
			elseif prox >= 26.0 then
				prox = 2.5
				vprox = "whisper"
			end
			NetworkClearVoiceChannel()
			NetworkSetTalkerProximity(prox)
			SendNUIMessage({action = "setProximity", value = vprox})
		end
		if IsControlPressed(1, 166) then
			local posPlayer = GetEntityCoords(GetPlayerPed(-1))
			DrawMarker(1, posPlayer.x, posPlayer.y, posPlayer.z - 1, 0, 0, 0, 0, 0, 0, prox * 2, prox * 2, 0.8001, 0, 75, 255, 165, 0,0, 0,0)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50)
			if isTalking == false then
				if NetworkIsPlayerTalking(PlayerId()) then
					isTalking = true
					SendNUIMessage({action = "setTalking", value = true})
				end
			else
				if NetworkIsPlayerTalking(PlayerId()) == false then
					isTalking = false
					SendNUIMessage({action = "setTalking", value = false})
				end
			end
	end
end)

-- VEHICLE HUD

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local playerPed = PlayerPedId()
		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if GetIsVehicleEngineRunning(vehicle) == false then
				SendNUIMessage({action = "engineSwitch", status = false})
			else
				SendNUIMessage({action = "engineSwitch", status = true})
			end
			if (lockStatus == 0 or lockStatus == 1) then
				SendNUIMessage({action = "lockSwitch", status = true})
			elseif lockstatus ~= 0 and lockstatus ~= 1 then
				SendNUIMessage({action = "lockSwitch", status = false})
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlPressed(1, 243) then
			SendNUIMessage({action = "toggleCar", show = false})
			if not ZablokujPozycje then
				SendNUIMessage({action = "przesunHudMapa", show = true})
			end
			DuzaMapaPojazd = true
			SetRadarBigmapEnabled(true, false)
		elseif IsControlJustReleased(1, 243) and DuzaMapaPojazd == true then
			DuzaMapaPojazd = false
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				SendNUIMessage({action = "toggleCar", show = true})
				SendNUIMessage({action = "przesunHud", show = true})
			end
			SetRadarBigmapEnabled(false, false)
		end
	end
end)

-- PANEL DOLNY

local zones = { ['AIRP'] = "Airport LS", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "Klub Golfowy", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port LS", ['ZQ_UAR'] = "Davis Quartz" }
local directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N', }
local tekstLokalizacji = ''
local tekstDzien = ''
local pogodaHash = ''

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		local Ped = GetPlayerPed(-1)
		if(IsPedInAnyVehicle(Ped, false)) then
			local PedCar = GetVehiclePedIsIn(Ped, false)
			carSpeed = math.ceil(GetEntitySpeed(PedCar) * 1.23)
			SendNUIMessage({
				showhud = true,
				speed = carSpeed
			})
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local pos = GetEntityCoords(GetPlayerPed(-1))
		local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
		local current_zone = zones[GetNameOfZone(pos.x, pos.y, pos.z)]

		for k,v in pairs(directions)do
			direction = GetEntityHeading(GetPlayerPed(-1))
			if(math.abs(direction - k) < 22.5)then
				direction = v
				break;
			end
		end

		if(GetStreetNameFromHashKey(var1) and GetNameOfZone(pos.x, pos.y, pos.z)) then
			if(zones[GetNameOfZone(pos.x, pos.y, pos.z)] and tostring(GetStreetNameFromHashKey(var1))) then
				tekstLokalizacji = direction..' | '..tostring(GetStreetNameFromHashKey(var1))
				SendNUIMessage({
					showLokalizacja = true,
					lokalizacja = tekstLokalizacji
				})
			end
		end

	end
end)

RegisterNetEvent('welldone_carhud:UstawPogode')
AddEventHandler('welldone_carhud:UstawPogode', function(pogoda)
    pogodaHash = pogoda
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1500)

		local dzienInt = GetClockDayOfWeek()
		local dzien = ''
		if dzienInt == 0 then
			dzien = 'Sunday'
		elseif dzienInt == 1 then
			dzien = 'Monday'
		elseif dzienInt == 2 then
			dzien = 'Tuesday'
		elseif dzienInt == 3 then
			dzien = 'Wednesday'
		elseif dzienInt == 4 then
			dzien = 'Thursday'
		elseif dzienInt == 5 then
			dzien = 'Friday'
		elseif dzienInt == 6 then
			dzien = 'Saturday'
		end

		local godzinaInt = GetClockHours()
		local godzina = ''
		if string.len(tostring(godzinaInt)) == 1 then
			godzina = '0'..godzinaInt
		else
			godzina = godzinaInt
		end

		local minutaInt = GetClockMinutes()
		local minuta = ''
		if string.len(tostring(minutaInt)) == 1 then
			minuta = '0'..minutaInt
		else
			minuta = minutaInt
		end

		local pogoda = ''

		if vSyncPogoda == true then
			if pogodaHash == 'EXTRASUNNY' then
				pogoda = 'Sunny'
			elseif pogodaHash == 'CLEAR' then
				pogoda = 'Clear'
			elseif pogodaHash == 'NEUTRAL' then
				pogoda = 'Neutral'
			elseif pogodaHash == 'SMOG' then
				pogoda = 'Smog'
			elseif pogodaHash == 'FOGGY' then
				pogoda = 'Fog'
			elseif pogodaHash == 'OVERCAST' then
				pogoda = 'Overcast'
			elseif pogodaHash == 'CLOUDS' then
				pogoda = 'Clouds'
			elseif pogodaHash == 'CLEARING' then
				pogoda = 'Clearing'
			elseif pogodaHash == 'RAIN' then
				pogoda = 'Rain'
			elseif pogodaHash == 'THUNDER' then
				pogoda = 'Thunder'
			elseif pogodaHash == 'BLIZZARD' then
				pogoda = 'Blizzard'
			elseif pogodaHash == 'SNOWLIGHT' then
				pogoda = 'Winter'
			elseif pogodaHash == 'XMAS' then
				pogoda = 'Christmas'
			elseif pogodaHash == 'HALLOWEEN' then
				pogoda = 'Halloween'
			end

			tekstDzien = godzina..':'..minuta..' | '..dzien..' | '..pogoda
		else
			tekstDzien = godzina..':'..minuta..' | '..dzien
		end

		SendNUIMessage({
			showDni = true,
			dni = tekstDzien
		})
	end
end)