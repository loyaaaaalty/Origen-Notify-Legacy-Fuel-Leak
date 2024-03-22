QBCore = exports['qb-core']:GetCoreObject()


local isNearPump = false
local isFueling = false
local currentFuel = 0.0
local currentCash = 1000
local currentV
local fuelSynced = false
local lastFinalCost = 0
local lastAmount = 0

local NUI = false
RegisterNUICallback("close", function()
	NUI = false
	SetNuiFocus(false, false)
end)

RegisterNUICallback("getPrice", function(data, cb)
	local fuelToAdd = 2
	if not data.amount or data.amount == "" then
		lastAmount = 0
		lastFinalCost = 0
		cb(0)
		return
	end
	local cost = fuelToAdd / 1.5 * Config.CostMultiplier
	local finalCost = data.amount * cost
	lastFinalCost = math.floor(finalCost) + 1
	lastAmount = tonumber(data.amount)
	cb(math.floor(finalCost) + 1)
end)

RegisterNUICallback("acceptBuy", function(data, cb)
	NUI = false

	-- SendNUIMessage({
	-- 	action = NUI and 'onPanel' or 'offPanel'
	-- })
	SetNuiFocus(NUI, NUI)
	if lastFinalCost > 0 and lastAmount > 0 then


		QBCore.Functions.TriggerCallback('origen_fuel:server:hasMoney', function(result)

			if result == true then
				cb('ok')
				isFueling = true
				local ped = PlayerPedId()
				TaskTurnPedToFaceEntity(ped, currentV, 1000)
				Citizen.Wait(1000)
				grabNozzleFromPump()
				LoadAnimDict("timetable@gardener@filling_can")
				TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
				QBCore.Functions.Progressbar("fueling_vehicle", "Repostando Gasolina", 8000, false, true, {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				}, {}, {}, {}, function() -- Done
					currentFuel = GetVehicleFuelLevel(currentV)
					if (currentFuel + lastAmount) > 100 then
						SetFuel(currentV, 100.0)
					else
						SetFuel(currentV, currentFuel + lastAmount)
					end
					TriggerServerEvent('origen_garages:server:UpdateMods', json.encode(QBCore.Functions.GetVehicleProperties(currentV)), GetVehicleNumberPlateText(currentV))
					dropNozzle()
					ClearPedTasks(ped)
					RemoveAnimDict("timetable@gardener@filling_can")
					SendNUIMessage({action = 'fuelCompleted'})
					isFueling = false
				end, function() -- Cancel
					QBCore.Functions.Notify("Cancelado", "error")
					ClearAllPedProps(ped)
					ClearPedTasks(ped)
					SendNUIMessage({action = 'fuelCompleted'})
					isFueling = false
				end)
			else
				QBCore.Functions.Notify("No tienes suficiente dinero", "error")
				isFueling = false
				SendNUIMessage({action = 'offPanel'})
			end
		end, lastFinalCost)
	end
end)

function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Wait(1)
		end
	end
end

local nozzle
local rope

function grabNozzleFromPump()
	local ped = PlayerPedId()
	local pumpObject, pumpDistance = FindNearestFuelPump()
	local pump = GetEntityCoords(pumpObject)
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(ped, "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    Wait(300)
    nozzle = CreateObject(`prop_cs_fuel_nozle`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(nozzle, ped, GetPedBoneIndex(ped, 0x49D9), 0.11, 0.02, 0.02, -80.0, -90.0, 15.0, true, true, false, true, 1, true)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(0)
    end
    RopeLoadTextures()
    while not pump do
        Wait(0)
    end
    rope = AddRope(pump.x, pump.y, pump.z, 0.0, 0.0, 0.0, 3.0, 1, 1000.0, 0.0, 1.0, false, false, false, 1.0, true)
    while not rope do
        Wait(0)
    end
    ActivatePhysics(rope)
    Wait(50)
    local nozzlePos = GetEntityCoords(nozzle)
    nozzlePos = GetOffsetFromEntityInWorldCoords(nozzle, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(rope, pumpObject, nozzle, pump.x, pump.y, pump.z + 1.45, nozzlePos.x, nozzlePos.y, nozzlePos.z, 5.0, false, false, nil, nil)
end

function dropNozzle()
    DetachEntity(nozzle, true, true)
	DeleteRope(rope)
	DeleteEntity(nozzle)
end

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(200, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
	end
end

Citizen.CreateThread(function()
	DecorRegister(Config.FuelDecor, 1)
	while true do
		Citizen.Wait(2000)

		local ped = PlayerPedId()

		if IsPedInAnyVehicle(ped) and GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) ~= -1963629913 then
			local vehicle = GetVehiclePedIsIn(ped)

			if GetPedInVehicleSeat(vehicle, -1) == ped then
				ManageFuelUsage(vehicle)
			end
		else
			if fuelSynced then
				fuelSynced = false
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 750

		local pumpObject, pumpDistance = FindNearestFuelPump()

		if pumpDistance < 10 then
			sleep = 250
		end

		if pumpDistance < 2.5 then
			isNearPump = pumpObject

			currentCash = 0

            local player_inventory = QBCore.Functions.GetPlayerData().items

            for _, item in pairs(player_inventory) do
                if item.type == "item" and item.name == "cash" then
                    currentCash = item.amount
                end
            end
		else
			isNearPump = false

			Citizen.Wait(math.ceil(pumpDistance * 20))
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	local notify
	while true do
		local ped = PlayerPedId()
		
		if not isFueling and ((isNearPump and GetEntityHealth(isNearPump) > 0) or (GetSelectedPedWeapon(ped) == 883325847 and not isNearPump)) then
			if IsPedInAnyVehicle(ped) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped and GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) ~= -1963629913 then
			
			else
				local vehicle = GetPlayersLastVehicle()
				local vehicleCoords = GetEntityCoords(vehicle)

				if DoesEntityExist(vehicle) and #(GetEntityCoords(ped) - vehicleCoords) < 2.5 and GetEntityModel(vehicle) ~= -1963629913 then
					if not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) then
						local stringCoords = GetEntityCoords(isNearPump)
						local canFuel = true

						if GetSelectedPedWeapon(ped) == 883325847 then
							stringCoords = vehicleCoords

							if GetAmmoInPedWeapon(ped, 883325847) < 100 then
								canFuel = false
							end
						end

						if GetVehicleFuelLevel(vehicle) < 95 and canFuel then
							if currentCash > 0 then
								if not notify then
									notify = exports["origen_notify"]:CreateHelp("E", Config.Strings.EToRefuel)
								else
									exports["origen_notify"]:UpdateHelp(notify, "E", Config.Strings.EToRefuel)
								end

								if IsControlJustReleased(0, 38) then
									currentV = vehicle
									ClearPedTasks(PlayerPedId())
									NUI = true

									SendNUIMessage({
										action = NUI and 'onPanel' or 'offPanel',
										fuel = GetFuel(vehicle)
									})
									SetNuiFocus(NUI, NUI)
								end
							else
								if not notify then
									notify = exports["origen_notify"]:CreateHelp("", Config.Strings.NotEnoughCash)
								else
									exports["origen_notify"]:UpdateHelp(notify, "", Config.Strings.NotEnoughCash)
								end
							end
						elseif not canFuel then
							if not notify then
								notify = exports["origen_notify"]:CreateHelp("", Config.Strings.JerryCanEmpty)
							else
								exports["origen_notify"]:UpdateHelp(notify, "", Config.Strings.JerryCanEmpty)
							end
						else
							if not notify then
								notify = exports["origen_notify"]:CreateHelp("", Config.Strings.FullTank)
							else
								exports["origen_notify"]:UpdateHelp(notify, "", Config.Strings.FullTank)
							end
						end
					elseif notify then
						exports["origen_notify"]:RemoveHelp(notify)
						notify = nil
					end
				else
					if notify then
						exports["origen_notify"]:RemoveHelp(notify)
						notify = nil
					end
					Citizen.Wait(250)
				end
			end

		else
			if notify then
				exports["origen_notify"]:RemoveHelp(notify)
				notify = nil
			end
			Citizen.Wait(250)
		end

		Citizen.Wait(0)
	end
end)

if Config.ShowNearestGasStationOnly then
	Citizen.CreateThread(function()
		local currentGasBlip = 0

		while true do
			local coords = GetEntityCoords(PlayerPedId())
			local closest = 1000
			local closestCoords

			for _, gasStationCoords in pairs(Config.GasStations) do
				local dstcheck = #(coords - gasStationCoords)

				if dstcheck < closest then
					closest = dstcheck
					closestCoords = gasStationCoords
				end
			end

			if DoesBlipExist(currentGasBlip) then
				RemoveBlip(currentGasBlip)
			end

			currentGasBlip = CreateBlip(closestCoords)

			Citizen.Wait(10000)
		end
	end)
elseif Config.ShowAllGasStations then
	Citizen.CreateThread(function()
		for _, gasStationCoords in pairs(Config.GasStations) do
			CreateBlip(gasStationCoords)
		end
	end)
end

-- LoyaltyDevelopment.es