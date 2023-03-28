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
  
  local PlayerData = {}
  local HasAlreadyEnteredMarker = false
  local LastStation, LastPart, LastPartNum, LastEntity
  local CurrentAction = nil
  local CurrentActionMsg  = ''
  local CurrentActionData = {}
  local IsHandcuffed = false
  local HandcuffTimer = {}
  local DragStatus = {}
  DragStatus.IsDragged = false
  local hasAlreadyJoined = false
  local blipsCops = {}
  local isDead = false
  local CurrentTask = {}
  local playerInService = false
  local spawnedVehicles, isInShopMenu = {}, false
  local Drag = false
  local animation = false
  ESX                           = nil
  
  Citizen.CreateThread(function()
	  while ESX == nil do
		  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		  Citizen.Wait(0)
	  end
  
	  while ESX.GetPlayerData().job == nil do
		  Citizen.Wait(10)
	  end
  
	  PlayerData = ESX.GetPlayerData()
  end)
  
  function cleanPlayer(playerPed)
	  SetPedArmour(playerPed, 0)
	  ClearPedBloodDamage(playerPed)
	  ResetPedVisibleDamage(playerPed)
	  ClearPedLastWeaponDamage(playerPed)
	  ResetPedMovementClipset(playerPed, 0)
  end
  
  function setUniform(job, playerPed)
	  TriggerEvent('skinchanger:getSkin', function(skin)
		  if skin.sex == 0 then
			  if Config.Uniforms[job].male ~= nil then
				  TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			  else 
				exports.nc_notify:PushNotification({
					title = ' ไม่มีชุด ',
					description = message,
					color = '#94dcfc',
					icon = 'message',
					direction = 'right',
					duration = 3000
				})
			  end
  
			  if job == 'bullet_wear' then
				  SetPedArmour(playerPed, 100)
			  end
		  else
			  if Config.Uniforms[job].female ~= nil then
				  TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			  else
				exports.nc_notify:PushNotification({
					title = ' ไม่มีชุด ',
					description = message,
					color = '#94dcfc',
					icon = 'message',
					direction = 'right',
					duration = 3000
				})
			  end
  
			  if job == 'bullet_wear' then
				  SetPedArmour(playerPed, 100)
			  end
		  end
	  end)
  end
  
  function OpenCloakroomMenu()
  
	  local playerPed = PlayerPedId()
	  local grade = PlayerData.job.grade_name
  
	  local elements = {}
  
	  table.insert(elements, {label = '<strong class="blue-text">อุปกรณ์เสริม</strong>', value = 'more'})
	  table.insert(elements, {label = '<strong class="blue-text">ชุดธรรมดา</strong>', value = 'more1'})
  
	  for k,v in pairs(Config.UniformsList) do
		  table.insert(elements, {label = v.title, value = k})
	  end
  
	  ESX.UI.Menu.CloseAll()
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom',
	  {
		  title    = _U('cloakroom'),
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  cleanPlayer(playerPed)
  
		  if data.current.value ~= nil then
  
			  if data.current.value == 'more' then
				  OpenLockerClothMore()
			  else
				  TriggerEvent('skinchanger:getSkin', function(skin)
					  if skin.sex == 0 then
						  -- TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList[data.current.value].male)
						  TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList[data.current.value].male)
					  else
						  TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsList[data.current.value].female)
					  end
				  end)
			  end
			  
			  if data.current.value == 'more1' then
				  menu.close()
				  ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					  TriggerEvent('skinchanger:loadSkin', skin)
				  end)	
			  end
  
		  end
  
	  end, function(data, menu)
		  menu.close()
  
		  CurrentAction     = 'menu_cloakroom'
		  CurrentActionMsg  = _U('open_cloackroom')
		  CurrentActionData = {}
	  end)
  end
  
  function OpenLockerClothMore()
	  local playerPed = PlayerPedId()
  
	  local elements = {}
	  for k,v in pairs(Config.UniformsListMore) do
		  table.insert(elements, {label = v.title, value = k})
	  end
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom_more',
	  {
		  title    = "อุปกรณ์เสริม",
		  align    = 'top-left',
		  elements = elements
	  }, function(data2, menu2)
		  
		  cleanPlayer(playerPed)
  
		  if data2.current.value ~= nil then
  
			  TriggerEvent('skinchanger:getSkin', function(skin)
				  if skin.sex == 0 then
					  TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsListMore[data2.current.value].male)
				  else
					  TriggerEvent('skinchanger:loadClothes', skin, Config.UniformsListMore[data2.current.value].female)
				  end
			  end)
		  
		  end
  
	  end, function(data2, menu2)
		  menu2.close()
	  end)
  
  end
  
  function OpenArmoryMenu(station)
	  local elements = {
		  {label = _U('buy_weapons'), value = 'buy_weapons'}
	  }
  
	  if Config.EnableArmoryManagement then
		  table.insert(elements, {label = _U('get_weapon'),     value = 'get_weapon'})
		  table.insert(elements, {label = _U('put_weapon'),     value = 'put_weapon'})
		  
		  
		  table.insert(elements, {label = _U('deposit_object'), value = 'put_stock'})
		  if ESX.GetPlayerData().job.grade_name == 'boss' then
			  table.insert(elements, {label = _U('remove_object'),  value = 'get_stock'})
		  elseif ESX.GetPlayerData().job.grade_name == 'lieutenant' then
			  table.insert(elements, {label = _U('remove_object'),  value = 'get_stock'})
		  end
	  end
  
	  ESX.UI.Menu.CloseAll()
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory',
	  {
		  title    = _U('armory'),
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  if data.current.value == 'get_weapon' then
			  OpenGetWeaponMenu()
		  elseif data.current.value == 'put_weapon' then
			  OpenPutWeaponMenu()
		  elseif data.current.value == 'buy_weapons' then
			  OpenBuyWeaponsMenu()
		  elseif data.current.value == 'put_stock' then
			  OpenPutStocksMenu()
		  elseif data.current.value == 'get_stock' then
			  OpenGetStocksMenu()
		  end
  
	  end, function(data, menu)
		  menu.close()
  
		  CurrentAction     = 'menu_armory'
		  CurrentActionMsg  = _U('open_armory')
		  CurrentActionData = {station = station}
	  end)
  end
  
  function OpenVehicleSpawnerMenu(type, station, part, partNum)
	  local playerCoords = GetEntityCoords(PlayerPedId())
	  PlayerData = ESX.GetPlayerData()
	  local elements = {
		  {label = "โรงรถ", action = 'garage'},
		  {label = "เก็บรถ", action = 'store_garage'},
		  {label = "ซื้อรถ", action = 'buy_vehicle'},
		  --{label = "รถที่โดนยึดโดยตำรวจ", action = 'police_vehicle'}
	  }
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		  title    = _U('garage_title'),
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  if data.current.action == 'buy_vehicle' then
			  local shopElements, shopCoords = {}
  
			  if type == 'car' then
				  shopCoords = Config.spdStations[station].Vehicles[partNum].InsideShop
				  local authorizedVehicles = Config.AuthorizedVehicles[PlayerData.job.grade_name]
  
				  if #Config.AuthorizedVehicles['Shared'] > 0 then
					  for k,vehicle in ipairs(Config.AuthorizedVehicles['Shared']) do
						  table.insert(shopElements, {
							  label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							  name  = vehicle.label,
							  model = vehicle.model,
							  price = vehicle.price,
							  type  = 'car'
						  })
					  end
				  end
  
				  if #authorizedVehicles > 0 then
					  for k,vehicle in ipairs(authorizedVehicles) do
						  table.insert(shopElements, {
							  label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							  name  = vehicle.label,
							  model = vehicle.model,
							  price = vehicle.price,
							  type  = 'car'
						  })
					  end
				  else
					  if #Config.AuthorizedVehicles['Shared'] == 0 then
						  return
					  end
				  end
			  elseif type == 'helicopter' then
				  shopCoords = Config.spdStations[station].Helicopters[partNum].InsideShop
				  local authorizedHelicopters = Config.AuthorizedHelicopters[PlayerData.job.grade_name]
  
				  if #authorizedHelicopters > 0 then
					  for k,vehicle in ipairs(authorizedHelicopters) do
						  table.insert(shopElements, {
							  label = ('%s - <span class="green-text">%s</span>'):format(vehicle.label, _U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
							  name  = vehicle.label,
							  model = vehicle.model,
							  price = vehicle.price,
							  livery = vehicle.livery or nil,
							  type  = 'helicopter'
						  })
					  end
				  else 
					exports.nc_notify:PushNotification({
						title = ' คุณไม่ได้รับอนุญาตให้ซื้อเฮลิคอปเตอร์ ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
					  return
				  end
			  end
  
			  OpenShopMenu(shopElements, playerCoords, shopCoords)
		  elseif data.current.action == 'garage' then
			  local garage = {}
  
			  ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				  if #jobVehicles > 0 then
					  for k,v in ipairs(jobVehicles) do
						  local props = json.decode(v.vehicle)
						  local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						  local label = ('%s - <span class="orange-text">%s</span>: '):format(vehicleName, props.plate)
  
						  if v.stored then
							  label = label .. ('<span class="green-text">%s</span>'):format(_U('garage_stored'))
						  else
							  label = label .. ('<span class="red-text">%s</span>'):format(_U('garage_notstored'))
						  end
  
						  table.insert(garage, {
							  label = label,
							  stored = v.stored,
							  model = props.model,
							  vehicleProps = props
						  })
					  end
  
					  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage', {
						  title    = _U('garage_title'),
						  align    = 'top-left',
						  elements = garage
					  }, function(data2, menu2)
						  if data2.current.stored then
							  local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)
  
							  if foundSpawn then
								  menu2.close()
  
								  ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
									  ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)
  
									  TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.vehicleProps.plate, false)
									  exports.nc_notify:PushNotification({
										title = ' นำรถของคุณออกมาเรียบร้อยแล้ว ',
										description = message,
										color = '#94dcfc',
										icon = 'message',
										direction = 'right',
										duration = 3000
									})
								  end)
							  end
						  else
							exports.nc_notify:PushNotification({
								title = ' รถของคุณไม่ได้เก็บไว้ในโรงรถ ',
								description = message,
								color = '#94dcfc',
								icon = 'message',
								direction = 'right',
								duration = 3000
							})
						  end
					  end, function(data2, menu2)
						  menu2.close()
					  end)
  
				  else
					exports.nc_notify:PushNotification({
						title = ' ไม่มีรถในโรงรถ ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, type)
  
		  elseif data.current.action == 'store_garage' then
			  StoreNearbyVehicle(playerCoords)
		  elseif data.current.action == 'police_vehicle' then
			  
			  local garage_spd = {}
			  ESX.TriggerServerCallback('esx_spdjob:getVehicleFromspd', function(jobVehicles)
				  if #jobVehicles > 0 then
					  for k,v in ipairs(jobVehicles) do
						  local props = json.decode(v.vehicle)
						  local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						  local label = ('<span class="orange-text">%s</span>: '):format(props.plate)
  
						  if v.spd_by then
							  label = label .. ('โดย: %s'):format(v.spd_by).." ".. v.time
						  else
							  label = label .. ('โดย: %s'):format("Unknow").." ".. v.time
						  end
  
						  table.insert(garage_spd, {
							  label = label,
							  value = k
							  -- stored = v.stored,
							  -- value = props
						  })
					  end
  
					  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage1', {
						  title    = "รายชื่อรถ",
						  align    = 'top-left',
						  elements = garage_spd
					  }, function(data2, menu2)
						  local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)
						  if foundSpawn then
							  local value = data2.current.value
							  local props = json.decode(jobVehicles[value].vehicle)
  
							  ESX.Game.SpawnVehicle(props.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
								  ESX.Game.SetVehicleProperties(vehicle, props)
  
								  TriggerServerEvent('esx_spdjob:setVehicleFromspd', props.plate)
								  exports.nc_notify:PushNotification({
									title = ' เบิกรถเรียบร้อยแล้ว ',
									description = message,
									color = '#94dcfc',
									icon = 'message',
									direction = 'right',
									duration = 3000
								})
							  end)
							  menu2.close()
						  end
					  end, function(data2, menu2)
						  menu2.close()
					  end)
  
				  else
					exports.nc_notify:PushNotification({
						title = ' ไม่มีรถที่โดนยึด ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end)
  
		  end
  
	  end, function(data, menu)
		  menu.close()
	  end)
  
  end
  
  function StoreNearbyVehicle(playerCoords)
	  local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}
  
	  if #vehicles > 0 then
		  for k,v in ipairs(vehicles) do
  
			  -- Make sure the vehicle we're saving is empty, or else it wont be deleted
			  if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				  table.insert(vehiclePlates, {
					  vehicle = v,
					  plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				  })
			  end
		  end
	  else
		exports.nc_notify:PushNotification({
			title = ' ไม่มียานพาหนะใกล้เคียง ',
			description = message,
			color = '#94dcfc',
			icon = 'message',
			direction = 'right',
			duration = 3000
		})
		  return
	  end
  
	  ESX.TriggerServerCallback('esx_spdjob:storeNearbyVehicle', function(storeSuccess, foundNum)
		  if storeSuccess then
			  local vehicleId = vehiclePlates[foundNum]
			  local attempts = 0
			  ESX.Game.DeleteVehicle(vehicleId.vehicle)
			  IsBusy = true
  
			  Citizen.CreateThread(function()
				  while IsBusy do
					  Citizen.Wait(0)
					  drawLoadingText(_U('garage_storing'), 255, 255, 255, 255)
				  end
			  end)
  
			  -- Workaround for vehicle not deleting when other players are near it.
			  while DoesEntityExist(vehicleId.vehicle) do
				  Citizen.Wait(500)
				  attempts = attempts + 1
  
				  -- Give up
				  if attempts > 30 then
					  break
				  end
  
				  vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				  if #vehicles > 0 then
					  for k,v in ipairs(vehicles) do
						  if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							  ESX.Game.DeleteVehicle(v)
							  break
						  end
					  end
				  end
			  end
  
			  IsBusy = false
			  exports.nc_notify:PushNotification({
				title = ' เก็บรถเรียบร้อยแล้ว ',
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
		  else
			exports.nc_notify:PushNotification({
				title = ' ไม่พบยานพาหนะที่เป็นของใกล้เคียง ',
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
		  end
	  end, vehiclePlates)
  end
  
  function GetAvailableVehicleSpawnPoint(station, part, partNum)
	  local spawnPoints = Config.spdStations[station][part][partNum].SpawnPoints
	  local found, foundSpawnPoint = false, nil
  
	  for i=1, #spawnPoints, 1 do
		  if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			  found, foundSpawnPoint = true, spawnPoints[i]
			  break
		  end
	  end
  
	  if found then
		  return true, foundSpawnPoint
	  else
		exports.nc_notify:PushNotification({
			title = ' จุดเรียกรถที่มีอยู่ทั้งหมดถูกบล็อกในขณะนี้ ',
			description = message,
			color = '#94dcfc',
			icon = 'message',
			direction = 'right',
			duration = 3000
		})
		  return false
	  end
  end
  
  function OpenShopMenu(elements, restoreCoords, shopCoords)
	  local playerPed = PlayerPedId()
	  isInShopMenu = true
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		  title    = _U('vehicleshop_title'),
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm',
		  {
			  title    = _U('vehicleshop_confirm', data.current.name, data.current.price),
			  align    = 'top-left',
			  elements = {
				  { label = _U('confirm_no'), value = 'no' },
				  { label = _U('confirm_yes'), value = 'yes' }
			  }
		  }, function(data2, menu2)
  
			  if data2.current.value == 'yes' then
				  local newPlate = exports['esx_vehicleshop']:GeneratePlate()
				  local vehicle  = GetVehiclePedIsIn(playerPed, false)
				  local props    = ESX.Game.GetVehicleProperties(vehicle)
				  props.plate    = newPlate
  
				  ESX.TriggerServerCallback('esx_spdjob:buyJobVehicle', function (bought)
					  if bought then
						  TriggerEvent("pNotify:SendNotification", {
							  text = _U('vehicleshop_bought', data.current.name, ESX.Math.GroupDigits(data.current.price)),
							  type = "success",
							  timeout = 3000,
							  layout = "bottomCenter",
							  queue = "global"
						  })
  
						  isInShopMenu = false
						  ESX.UI.Menu.CloseAll()
				  
						  DeleteSpawnedVehicles()
						  FreezeEntityPosition(playerPed, false)
						  SetEntityVisible(playerPed, true)
				  
						  ESX.Game.Teleport(playerPed, restoreCoords)
					  else
						exports.nc_notify:PushNotification({
							title = ' คุณมีเงินไม่เพียงพอ ',
							description = message,
							color = '#94dcfc',
							icon = 'message',
							direction = 'right',
							duration = 3000
						})
						  menu2.close()
					  end
				  end, props, data.current.type)
			  else
				  menu2.close()
			  end
  
		  end, function(data2, menu2)
			  menu2.close()
		  end)
  
		  end, function(data, menu)
		  isInShopMenu = false
		  ESX.UI.Menu.CloseAll()
  
		  DeleteSpawnedVehicles()
		  FreezeEntityPosition(playerPed, false)
		  SetEntityVisible(playerPed, true)
  
		  ESX.Game.Teleport(playerPed, restoreCoords)
	  end, function(data, menu)
		  DeleteSpawnedVehicles()
  
		  WaitForVehicleToLoad(data.current.model)
		  ESX.Game.SpawnLocalVehicle(data.current.model, shopCoords, 0.0, function(vehicle)
			  table.insert(spawnedVehicles, vehicle)
			  TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			  FreezeEntityPosition(vehicle, true)
  
			  if data.current.livery then
				  SetVehicleModKit(vehicle, 0)
				  SetVehicleLivery(vehicle, data.current.livery)
			  end
		  end)
	  end)
  
	  WaitForVehicleToLoad(elements[1].model)
	  ESX.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0, function(vehicle)
		  table.insert(spawnedVehicles, vehicle)
		  TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		  FreezeEntityPosition(vehicle, true)
  
		  if elements[1].livery then
			  SetVehicleModKit(vehicle, 0)
			  SetVehicleLivery(vehicle,elements[1].livery)
		  end
	  end)
  end
  
  Citizen.CreateThread(function()
	  while true do
		  Citizen.Wait(0)
  
		  if isInShopMenu then
			  DisableControlAction(0, 75, true)  -- Disable exit vehicle
			  DisableControlAction(27, 75, true) -- Disable exit vehicle
		  else
			  Citizen.Wait(500)
		  end
	  end
  end)
  
  function DeleteSpawnedVehicles()
	  while #spawnedVehicles > 0 do
		  local vehicle = spawnedVehicles[1]
		  ESX.Game.DeleteVehicle(vehicle)
		  table.remove(spawnedVehicles, 1)
	  end
  end
  
  function WaitForVehicleToLoad(modelHash)
	  modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))
  
	  if not HasModelLoaded(modelHash) then
		  RequestModel(modelHash)
  
		  while not HasModelLoaded(modelHash) do
			  Citizen.Wait(0)
  
			  DisableControlAction(0, Keys['TOP'], true)
			  DisableControlAction(0, Keys['DOWN'], true)
			  DisableControlAction(0, Keys['LEFT'], true)
			  DisableControlAction(0, Keys['RIGHT'], true)
			  DisableControlAction(0, 176, true) -- ENTER key
			  DisableControlAction(0, Keys['BACKSPACE'], true)
  
			  drawLoadingText(_U('vehicleshop_awaiting_model'), 255, 255, 255, 255)
		  end
	  end
  end
  
  function drawLoadingText(text, red, green, blue, alpha)
	  SetTextFont(4)
	  SetTextProportional(0)
	  SetTextScale(0.0, 0.5)
	  SetTextColour(red, green, blue, alpha)
	  SetTextDropShadow(0, 0, 0, 0, 255)
	  SetTextEdge(1, 0, 0, 0, 255)
	  SetTextDropShadow()
	  SetTextOutline()
	  SetTextCentre(true)
  
	  BeginTextCommandDisplayText("STRING")
	  AddTextComponentSubstringPlayerName(text)
	  EndTextCommandDisplayText(0.5, 0.5)
  end
  
  function OpenspdActionsMenu()
	  ESX.UI.Menu.CloseAll()
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spd_actions',
	  {
		  title    = 'SPD',
		  align    = 'top-left',
		  elements = {
			  {label = _U('citizen_interaction'),	value = 'citizen_interaction'},
			  {label = _U('vehicle_interaction'),	value = 'vehicle_interaction'},
			  --{label = _U('object_spawner'),		value = 'object_spawner'},
			--  {label = "เจล เมนูตู้ปลา",               value = 'jail_menu'},
			--  {label = "เจล เมนูใต้สน.",               value = 'jail_menu2'},
			  {label = "เจล เมนูเรื่อนจำ",               value = 'jail_menu3'},
			  -- {label = "Squad",               value = 'squad'},
			  -- {label = "เบิกใบ Pound",               value = 'xenon_pound'}
		  }
	  }, function(data, menu)
  
		  if data.current.value == 'jail_menu' then
		--	  TriggerEvent("esx-qalle-jail:openJailMenu")		
		--  elseif data.current.value == 'jail_menu2' then
		--	  TriggerEvent("esx-qalle-jail2:openJailMenu")	
		  elseif data.current.value == 'jail_menu3' then
			  TriggerEvent("esx-qalle-jail3:openJailMenu")
		  elseif data.current.value == 'citizen_interaction' then
			  local elements = {
				  {label = _U('id_card'),			value = 'identity_card'},
				  {label = _U('search'),			value = 'body_search'},
				  {label = _U('handcuff'),		value = 'handcuff'},
				  {label = _U('unhandcuff'),		value = 'unhandcuff'},
				  {label = _U('drag'),			value = 'drag'},
				  {label = _U('put_in_vehicle'),	value = 'put_in_vehicle'},
				  {label = _U('out_the_vehicle'),	value = 'out_the_vehicle'},
			  --	{label = _U('fine'),			value = 'fine'},
			  --	{label = _U('unpaid_bills'),	value = 'unpaid_bills'}
			  }
		  
			-- if Config.EnableLicenses then
			--	  table.insert(elements, { label = _U('license_check'), value = 'license' })
			-- end
		  
			  ESX.UI.Menu.Open(
			  'default', GetCurrentResourceName(), 'citizen_interaction',
			  {
				  title    = _U('citizen_interaction'),
				  align    = 'top-left',
				  elements = elements
			  }, function(data2, menu2)
				  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				  if closestPlayer ~= -1 and closestDistance <= 3.0 then
					  local action = data2.current.value
  
					  if action == 'identity_card' then
						  OpenIdentityCardMenu(closestPlayer)
						  TriggerServerEvent('cdc5be83-c880-48c9-93a8-c57db0c8f87e', GetPlayerServerId(closestPlayer), GetPlayerServerId(PlayerId()))
					  
					  
					  
						  elseif action == 'body_search' then
	
							ESX.UI.Menu.CloseAll()
							TriggerEvent("mythic_progbar:client:progress", {
								name = "unique_action_name",
								duration = 500,
								label = "SEARCHING",
								useWhileDead = false,
								canCancel = false,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true,
								}
								},   
							  function(status)
							   if not status then
								   -- Do Something If Event Wasn't Cancelled
							  end
							end)
							Citizen.Wait(500)
							invenother = true
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							if IsPedDeadOrDying(closestPlayerPed, 1) then
								exports.nc_notify:PushNotification({
									title = ' ผู้เล่นเสียชีวิตอยู่ ',
									description = message,
									color = '#94dcfc',
									icon = 'message',
									direction = 'right',
									duration = 3000
								})
							else
								OpenBodySearchMenu(closestPlayer)
								TriggerServerEvent('noti', GetPlayerServerId(closestPlayer))
								
							end
					  -- elseif action == 'search' then
						  -- OpenBodySearchMenu(closestPlayer)
						  -- ESX.UI.Menu.CloseAll()
										  
						  
					  elseif action == 'handcuff' then
						  playerheading = GetEntityHeading(GetPlayerPed(-1))
						  playerlocation = GetEntityForwardVector(PlayerPedId())
						  playerCoords = GetEntityCoords(GetPlayerPed(-1))
						  TriggerServerEvent('esx_spdjob:handcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
					  elseif action == 'unhandcuff' then
						  playerheading = GetEntityHeading(GetPlayerPed(-1))
						  playerlocation = GetEntityForwardVector(PlayerPedId())
						  playerCoords = GetEntityCoords(GetPlayerPed(-1))
						  TriggerServerEvent('esx_spdjob:unhandcuff', GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
					  elseif action == 'drag' then
						  TriggerServerEvent('esx_spdjob:drag', GetPlayerServerId(closestPlayer))
						  spdDrag()	
					  elseif action == 'put_in_vehicle' then
						  TriggerServerEvent('esx_spdjob:putInVehicle', GetPlayerServerId(closestPlayer))
					  elseif action == 'out_the_vehicle' then
						  TriggerServerEvent('esx_spdjob:OutVehicle', GetPlayerServerId(closestPlayer))
					  elseif action == 'fine' then
						  OpenFineMenu(closestPlayer)
					  elseif action == 'license' then
						  ShowPlayerLicense(closestPlayer)
					  --elseif action == 'unpaid_bills' then
						  OpenUnpaidBillsMenu(closestPlayer)
					  end
  
				  else
					exports.nc_notify:PushNotification({
						title = ' ไม่มีผู้เล่นอยู่ใกล้คุณ ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, function(data2, menu2)
				  menu2.close()
			  end)
		  elseif data.current.value == 'vehicle_interaction' then
			  local elements  = {}
			  local playerPed = PlayerPedId()
			  local coords    = GetEntityCoords(playerPed)
			  local vehicle   = ESX.Game.GetVehicleInDirection()
			  
			  if DoesEntityExist(vehicle) then
				  table.insert(elements, {label = "ข้อมูลรถ",	value = 'vehicle_infos'})
				  table.insert(elements, {label = "ปลดล็อครถ",	value = 'hijack_vehicle'})
				  table.insert(elements, {label = "พาวท์รถ",		value = 'impound'})
				  table.insert(elements, {label = "ยึดรถ",		value = 'impound_spd'})
			  end
			  
			  table.insert(elements, {label = _U('search_database'), value = 'search_database'})
  
			  ESX.UI.Menu.Open(
			  'default', GetCurrentResourceName(), 'vehicle_interaction',
			  {
				  title    = _U('vehicle_interaction'),
				  align    = 'top-left',
				  elements = elements
			  }, function(data2, menu2)
				  coords  = GetEntityCoords(playerPed)
				  vehicle = ESX.Game.GetVehicleInDirection()
				  action  = data2.current.value
				  
				  if action == 'search_database' then
					  LookupVehicle()
				  elseif DoesEntityExist(vehicle) then
					  local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
					  if action == 'vehicle_infos' then
						  OpenVehicleInfosMenu(vehicleData)
						  
					  elseif action == 'hijack_vehicle' then
						  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
							  TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
							  Citizen.Wait(20000)
							  ClearPedTasksImmediately(playerPed)
  
							  SetVehicleDoorsLocked(vehicle, 1)
							  SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							  exports.nc_notify:PushNotification({
								title = ' ปลดล็อครถเรียบร้อยแล้ว ',
								description = message,
								color = '#94dcfc',
								icon = 'message',
								direction = 'right',
								duration = 3000
							})
  
							  local plate = GetVehicleNumberPlateText(vehicle)
							  local content = '' .. GetPlayerName(PlayerId()) .. ' งัดรถ ทะเบียน ' .. plate .. ''
							  TriggerServerEvent('azael_dc-serverlogs:insertData', 'spdHijack', content, GetPlayerServerId(PlayerId()), '^5')
						  end
					  elseif action == 'impound' then
					  
						  -- is the script busy?
						  if CurrentTask.Busy then
							  return
						  end
  
						  ESX.ShowHelpNotification(_U('impound_prompt'))
						  
						  TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
						  
						  CurrentTask.Busy = true
						  CurrentTask.Task = ESX.SetTimeout(10000, function()
							  ClearPedTasks(playerPed)
							  ImpoundVehicle(vehicle)
							  Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
						  end)
						  
						  -- keep track of that vehicle!
						  Citizen.CreateThread(function()
							  while CurrentTask.Busy do
								  Citizen.Wait(1000)
							  
								  vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
								  if not DoesEntityExist(vehicle) and CurrentTask.Busy then
									exports.nc_notify:PushNotification({
										title = ' พาวท์รถถูกยกเลิกเนื่องจากรถเคลื่อนที่ ',
										description = message,
										color = '#94dcfc',
										icon = 'message',
										direction = 'right',
										duration = 3000
									})
									  ESX.ClearTimeout(CurrentTask.Task)
									  ClearPedTasks(playerPed)
									  CurrentTask.Busy = false
									  break
								  end
							  end
						  end)
					  elseif action == 'impound_spd' then
  
						  -- print(GetVehicleNumberPlateText(vehicle))
						  ESX.UI.Menu.CloseAll()
  
						  -- is the script busy?
						  if CurrentTask.Busy then
							  return
						  end
  
						  ESX.ShowHelpNotification(_U('impound_prompt'))
						  
						  TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
						  
						  CurrentTask.Busy = true
						  CurrentTask.Task = ESX.SetTimeout(10000, function()
							  ClearPedTasks(playerPed)
							  ImpoundVehiclespd(vehicle)
							  Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
						  end)
						  
						  -- keep track of that vehicle!
						  Citizen.CreateThread(function()
							  while CurrentTask.Busy do
								  Citizen.Wait(1000)
							  
								  vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
								  if not DoesEntityExist(vehicle) and CurrentTask.Busy then
									exports.nc_notify:PushNotification({
										title = ' พาวท์รถถูกยกเลิกเนื่องจากรถเคลื่อนที่ ',
										description = message,
										color = '#94dcfc',
										icon = 'message',
										direction = 'right',
										duration = 3000
									})
									  ESX.ClearTimeout(CurrentTask.Task)
									  ClearPedTasks(playerPed)
									  CurrentTask.Busy = false
									  break
								  end
							  end
						  end)
					  end
				  else
					exports.nc_notify:PushNotification({
						title = ' คุณอยู่ไกลจากรถเกินไป ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
  
			  end, function(data2, menu2)
				  menu2.close()
			  end)
  
		  elseif data.current.value == 'object_spawner' then
			  ESX.UI.Menu.Open(
			  'default', GetCurrentResourceName(), 'citizen_interaction',
			  {
				  title    = _U('traffic_interaction'),
				  align    = 'top-left',
				  elements = {
					  {label = _U('cone'),		value = 'prop_roadcone02a'},
					  {label = _U('barrier'),		value = 'prop_barrier_work05'},
					  {label = _U('spikestrips'),	value = 'p_ld_stinger_s'},
					  {label = _U('box'),			value = 'prop_boxpile_07d'},
					  {label = _U('cash'),		value = 'hei_prop_cash_crate_half_full'}
				  }
			  }, function(data2, menu2)
				  local model     = data2.current.value
				  local playerPed = PlayerPedId()
				  local coords    = GetEntityCoords(playerPed)
				  local forward   = GetEntityForwardVector(playerPed)
				  local x, y, z   = table.unpack(coords + forward * 1.0)
  
				  if model == 'prop_roadcone02a' then
					  z = z - 2.0
				  end
  
				  ESX.Game.SpawnObject(model, {
					  x = x,
					  y = y,
					  z = z
				  }, function(obj)
					  SetEntityHeading(obj, GetEntityHeading(playerPed))
					  PlaceObjectOnGroundProperly(obj)
				  end)
  
			  end, function(data2, menu2)
				  menu2.close()
			  end)
		  -- elseif data.current.value == 'squad' then
			  -- TriggerEvent("meeta_spd:squadMenu")
		  
  
		  elseif data.current.value == 'xenon_pound' then
			  TriggerServerEvent("Xenon:RecivePound")
		  end
  
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function OpenIdentityCardMenu(player)
  
	  ESX.TriggerServerCallback('esx_spdjob:getOtherPlayerData', function(data)
  
		  local elements    = {}
		  local nameLabel   = _U('name', data.name)
		  local jobLabel    = nil
		  local sexLabel    = nil
		  local dobLabel    = nil
		  local heightLabel = nil
		  local idLabel     = nil
	  
		  if data.job.grade_label ~= nil and  data.job.grade_label ~= '' then
			  jobLabel = _U('job', data.job.label .. ' - ' .. data.job.grade_label)
		  else
			  jobLabel = _U('job', data.job.label)
		  end
	  
		  if Config.EnableESXIdentity then
	  
			  nameLabel = _U('name', data.firstname .. ' ' .. data.lastname)
	  
			  if data.sex ~= nil then
				  if string.lower(data.sex) == 'm' then
					  sexLabel = _U('sex', _U('male'))
				  else
					  sexLabel = _U('sex', _U('female'))
				  end
			  else
				  sexLabel = _U('sex', _U('unknown'))
			  end
	  
			  if data.dob ~= nil then
				  dobLabel = _U('dob', data.dob)
			  else
				  dobLabel = _U('dob', _U('unknown'))
			  end
	  
			  if data.height ~= nil then
				  heightLabel = _U('height', data.height)
			  else
				  heightLabel = _U('height', _U('unknown'))
			  end
	  
			  if data.name ~= nil then
				  idLabel = _U('id', data.name)
			  else
				  idLabel = _U('id', _U('unknown'))
			  end
	  
		  end
	  
		  local elements = {
			  {label = nameLabel, value = nil},
			  {label = jobLabel,  value = nil},
		  }
	  
		  if Config.EnableESXIdentity then
			  table.insert(elements, {label = sexLabel, value = nil})
			  table.insert(elements, {label = dobLabel, value = nil})
			  table.insert(elements, {label = heightLabel, value = nil})
			  table.insert(elements, {label = idLabel, value = nil})
		  end
	  
		  if data.drunk ~= nil then
			  table.insert(elements, {label = _U('bac', data.drunk), value = nil})
		  end
	  
		  if data.licenses ~= nil then
	  
			  table.insert(elements, {label = _U('license_label'), value = nil})
	  
			  for i=1, #data.licenses, 1 do
				  table.insert(elements, {label = data.licenses[i].label, value = nil})
			  end
	  
		  end
	  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction',
		  {
			  title    = _U('citizen_interaction'),
			  align    = 'top-left',
			  elements = elements,
		  }, function(data, menu)
	  
		  end, function(data, menu)
			  menu.close()
		  end)
	  
	  end, GetPlayerServerId(player))
  
  end
  
	  function OpenBodySearchMenu(player)
		exports.nc_inventory:SearchInventory(GetPlayerServerId(player), 'admin')
  end
  
  -- function OpenBodySearchMenu(player)     
	  -- TriggerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(player), GetPlayerName(player))
  -- end
  
  -- function OpenBodySearchMenu(player)
  
	  -- ESX.TriggerServerCallback('esx_spdjob:getOtherPlayerData', function(data)
  
		  -- local data1 = {
			  -- vehicle = true,
			  -- house = true
		  -- }
		  -- TriggerEvent("esx_inventoryhud:openOtherInventory", GetPlayerServerId(player), data.firstname, data.lastname, data.weapons, data1)
  
	  -- end, GetPlayerServerId(player))
  
  -- end
  --[[
  function OpenFineMenu(player)
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine',
	  {
		  title    = _U('fine'),
		  align    = 'top-left',
		  elements = {
			  {label = "สร้างบิล",   value = 'create_bills'}
			  -- {label = _U('traffic_offense'), value = 0},
			  -- {label = _U('minor_offense'),   value = 1},
			  -- {label = _U('average_offense'), value = 2},
			  -- {label = _U('major_offense'),   value = 3}
		  }
	  }, function(data, menu)
		  CreateBilling(player)
		  -- OpenFineCategoryMenu(player, data.current.value)
	  end, function(data, menu)
		  menu.close()
	  end)
  
  end
  
  function CreateBilling(player)
	  ESX.UI.Menu.CloseAll()
	  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_createbill',
	  {
		  title = "ใส่ชื่อบิล",
	  }, function(data, menu)
		  --local length = string.len(data.value)
		  if data.value == nil then
				exports.nc_notify:PushNotification({
						title = ' กรุณาใส่รายละเอียดด้วย ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
		  else
			  CreateBillingPrice(player, data.value)
			  menu.close()
		  end
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function CreateBillingPrice(player, value)
	  ESX.UI.Menu.CloseAll()
	  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialog_createbill_price',
	  {
		  title = "ใส่จำนวนเงิน",
	  }, function(data2, menu2)
		  --local length = string.len(data.value)
		  if tonumber(data2.value) then
			  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_spd',"spd: "..value, tonumber(data2.value))  --society_spd
			  menu2.close()
			  
			  		exports.nc_notify:PushNotification({
						title = ' สร้างบิลเรียบร้อยแล้ว ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
		  else
				exports.nc_notify:PushNotification({
						title = ' กรุณาใส่จำนวนเงิน ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
		  end
	  end, function(data2, menu2)
		  menu2.close()
	  end)
  end
  
  function OpenFineCategoryMenu(player, category)
  
	  ESX.TriggerServerCallback('esx_spdjob:getFineList', function(fines)
  
		  local elements = {}
  
		  for i=1, #fines, 1 do
			  table.insert(elements, {
				  label     = fines[i].label .. ' <span class="green-text"">$' .. fines[i].amount .. '</span>',
				  value     = fines[i].id,
				  amount    = fines[i].amount,
				  fineLabel = fines[i].label
			  })
		  end
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category',
		  {
			  title    = _U('fine'),
			  align    = 'top-left',
			  elements = elements,
		  }, function(data, menu)
  
			  local label  = data.current.fineLabel
			  local amount = data.current.amount
  
			  menu.close()
  
			  if Config.EnablePlayerManagement then
				  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_spd', _U('fine_total', label), amount)
			  else
				  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_spd', _U('fine_total', label), amount)
			  end
  
			  ESX.SetTimeout(300, function()
				  OpenFineCategoryMenu(player, category)
			  end)
  
		  end, function(data, menu)
			  menu.close()
		  end)
  
	  end, category)
  
  end  --]]
  
  function OpenSearchInfo()
	  local elements = {
		  {label = "ข้อมูลการซื้อรถ", value = 'history_vehicle'},
		  {label = "ข้อมูลการซื้อบ้าน", value = 'history_house'},
		  --{label = "Boss Action", value = 'boss_actions'},
	  }
  
	  if ESX.GetPlayerData().job.grade_name == 'boss' then
		  table.insert(elements, {label = 'Boss Action', value = 'boss_actions'})
	  end
  
	  ESX.UI.Menu.CloseAll()
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'seach_info',
	  {
		  title    = "ฐานข้อมูล",
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  if data.current.value == 'history_vehicle' then
			  SearchHistoryVehicleByName()
		  elseif data.current.value == 'history_house' then
			  SearchHistoryHouseByName()
		  elseif data.current.value == 'boss_actions' then
			  TriggerEvent('esx_society:openBossMenu', 'spd', function(data, menu)
				  menu.close()
			  end, {wash = false})
		  end
  
	  end, function(data, menu)
		  menu.close()
  
		  CurrentAction     = 'menu_search_actions'
		  CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to open the menu'
		  CurrentActionData = {station = station}
	  end)
  end
  
  function SearchHistoryVehicleByName()
	  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle',
	  {
		  title = "ตรวจสอบข้อมูลการซื้อรถของประชาชน (ชื่อ นามสกุล)",
	  }, function(data, menu)
		  --local length = string.len(data.value)
		  if data.value == nil then
			exports.nc_notify:PushNotification({
				title = ' ชื่อ-นามสกุล ไม่ถูกต้อง ',
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
		  else
			  ESX.TriggerServerCallback('esx_spdjob:getVehicleByName', function(result, found)
				  if found then
					  ShowSearchVehicle(result, data.value)
				  else
					exports.nc_notify:PushNotification({
						title = ' ไม่พบข้อมูล ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, data.value)
			  menu.close()
		  end
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function ShowSearchVehicle(result, name)
  
	  local elements = {}
  
	  for k,v in pairs(result) do
		  table.insert(elements, {label = "Plate : " ..v.plate, value = nil})
	  end
  
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_search_infos',
	  {
		  title    = 'ข้อมูลรถของ ' ..name,
		  align    = 'top-left',
		  elements = elements
	  }, nil, function(data, menu)
		  menu.close()
	  end)
  
  end
  
  function SearchHistoryHouseByName()
	  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle',
	  {
		  title = "ตรวจสอบข้อมูลการซื้อบ้านของประชาชน (ชื่อ นามสกุล)",
	  }, function(data, menu)
		  --local length = string.len(data.value)
		  if data.value == nil then
			exports.nc_notify:PushNotification({
				title = ' ชื่อ-นามสกุล ไม่ถูกต้อง ',
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
		  else
			  ESX.TriggerServerCallback('esx_spdjob:getHouseByName', function(result, found)
				  if found then
					  ShowSearchHouse(result, data.value)
				  else
					exports.nc_notify:PushNotification({
						title = ' ไม่พบข้อมูล ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, data.value)
			  menu.close()
		  end
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function ShowSearchHouse(result, name)
  
	  local elements = {}
  
	  for k,v in pairs(result) do
		  table.insert(elements, {label = "บ้าน : " ..v.name, value = nil})
	  end
  
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_search_infos',
	  {
		  title    = 'ข้อมูลบ้านของ ' ..name,
		  align    = 'top-left',
		  elements = elements
	  }, nil, function(data, menu)
		  menu.close()
	  end)
  
  end
  
  function LookupVehicle()
	  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle',
	  {
		  title = _U('search_database_title'),
	  }, function(data, menu)
		  local length = string.len(data.value)
		  if data.value == nil or length < 2 or length > 13 then
			exports.nc_notify:PushNotification({
				title = ' เลขทะเบียนไม่ถูกต้อง ',
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
		  else
			  ESX.TriggerServerCallback('esx_spdjob:getVehicleFromPlate', function(owner, found)
				  if found then
					exports.nc_notify:PushNotification({
						title = ' รถคันนี้ลงทะเบียนโดย ' ..owner,
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  else
					exports.nc_notify:PushNotification({
						title = ' ไม่มีข้อมูลนี้อยู่ในระบบ ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, data.value)
			  menu.close()
		  end
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function ShowPlayerLicense(player)
	  local elements = {}
	  local targetName
	  ESX.TriggerServerCallback('esx_spdjob:getOtherPlayerData', function(data)
		  if data.licenses then
			  for i=1, #data.licenses, 1 do
				  if data.licenses[i].label and data.licenses[i].type then
					  table.insert(elements, {
						  label = data.licenses[i].label,
						  type = data.licenses[i].type
					  })
				  end
			  end
		  end
		  
		  if Config.EnableESXIdentity then
			  targetName = data.firstname .. ' ' .. data.lastname
		  else
			  targetName = data.name
		  end
		  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license',
		  {
			  title    = _U('license_revoke'),
			  align    = 'top-left',
			  elements = elements,
		  }, function(data, menu)
			exports.nc_notify:PushNotification({
				title = ' คุณเพิกถอน ' ..data.current.label.. ' ซึ่งเป็นของ ' ..targetName,
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
			  TriggerServerEvent('esx_spdjob:message', GetPlayerServerId(player), _U('license_revoked', data.current.label))
			  
			  TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)
			  
			  ESX.SetTimeout(300, function()
				  ShowPlayerLicense(player)
			  end)
		  end, function(data, menu)
			  menu.close()
		  end)
  
	  end, GetPlayerServerId(player))
  end
  
  function OpenUnpaidBillsMenu(player)
	  local elements = {}
  
	  ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		  if #bills > 0 then
			  for i=1, #bills, 1 do
				  table.insert(elements, {
					  label = bills[i].label .. ' - <span class="red-text"">$' .. bills[i].amount .. '</span>',
					  value = bills[i].id
				  })
			  end
		  else
			  table.insert(elements, {
				  label = '<strong class="black-text">ไม่มีบิล</strong>'
			  })
		  end
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing-list',
		  {
			  title    = _U('unpaid_bills'),
			  align    = 'top-left',
			  elements = elements
		  }, function(data, menu)
			  ESX.TriggerServerCallback('esx_billing:getBillsIdView', function(data_billing)
				  
				  local elements1 = {}
				  table.insert(elements1, {label = data_billing.label, value = data_billing.id})
				  table.insert(elements1, {label = "วันที่แจ้งบิล : "..data_billing.time, value = data_billing.id})
				  table.insert(elements1, {label = "ลบบิล", value = "pay"})
  
				  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing-list-'..data.current.value,
				  {
					  title    = "#"..data.current.value,
					  align    = 'top-left',
					  elements = elements1
				  }, function(data2, menu2)
  
					  menu2.close()
  
					  if data2.current.value == "pay" then
						  TriggerServerEvent('esx_billing:sendBill', data_billing.id)
						  OpenUnpaidBillsMenu(player)
					  end
  
				  end, function(data2, menu2)
					  menu2.close()
				  end)
  
			  end, data.current.value)
		  end, function(data, menu)
			  menu.close()
		  end)
	  end, GetPlayerServerId(player))
  end  --]]
  
  function OpenVehicleInfosMenu(vehicleData)
  
	  ESX.TriggerServerCallback('esx_spdjob:getVehicleInfos', function(retrivedInfo)
  
		  local elements = {}
  
		  table.insert(elements, {label = _U('plate', retrivedInfo.plate), value = nil})
  
		  if retrivedInfo.owner == nil then
			  table.insert(elements, {label = _U('owner_unknown'), value = nil})
		  else
			  table.insert(elements, {label = _U('owner', retrivedInfo.owner), value = nil})
		  end
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos',
		  {
			  title    = _U('vehicle_info'),
			  align    = 'top-left',
			  elements = elements
		  }, nil, function(data, menu)
			  menu.close()
		  end)
  
	  end, vehicleData.plate)
  
  end
  
  function OpenGetWeaponMenu()
  
	  ESX.TriggerServerCallback('esx_spdjob:getArmoryWeapons', function(weapons)
		  local elements = {}
  
		  for i=1, #weapons, 1 do
			  if weapons[i].count > 0 then
				  table.insert(elements, {
					  label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					  value = weapons[i].name
				  })
			  end
		  end
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon',
		  {
			  title    = _U('get_weapon_menu'),
			  align    = 'top-left',
			  elements = elements
		  }, function(data, menu)
  
			  menu.close()
  
			  ESX.TriggerServerCallback('esx_spdjob:removeArmoryWeapon', function()
				  OpenGetWeaponMenu()
			  end, data.current.value)
  
		  end, function(data, menu)
			  menu.close()
		  end)
	  end)
  
  end
  
  function OpenPutWeaponMenu()
	  local elements   = {}
	  local playerPed  = PlayerPedId()
	  local weaponList = ESX.GetWeaponList()
  
	  for i=1, #weaponList, 1 do
		  local weaponHash = GetHashKey(weaponList[i].name)
  
		  if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			  table.insert(elements, {
				  label = weaponList[i].label,
				  value = weaponList[i].name
			  })
		  end
	  end
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon',
	  {
		  title    = _U('put_weapon_menu'),
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  menu.close()
  
		  ESX.TriggerServerCallback('esx_spdjob:addArmoryWeapon', function()
			  OpenPutWeaponMenu()
		  end, data.current.value, true)
  
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function OpenBuyWeaponsMenu()
  
	  local elements = {}
	  local playerPed = PlayerPedId()
	  PlayerData = ESX.GetPlayerData()
  
	  for k,v in ipairs(Config.AuthorizedWeapons[PlayerData.job.grade_name]) do
		  local weaponNum, weapon = ESX.GetWeapon(v.weapon)
		  local components, label = {}
  
		  local hasWeapon = HasPedGotWeapon(playerPed, GetHashKey(v.weapon), false)
  
		  if v.components then
			  for i=1, #v.components do
				  if v.components[i] then
  
					  local component = weapon.components[i]
					  local hasComponent = HasPedGotWeaponComponent(playerPed, GetHashKey(v.weapon), component.hash)
  
					  if hasComponent then
						  label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_owned'))
					  else
						  if v.components[i] > 0 then
							  label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_item', ESX.Math.GroupDigits(v.components[i])))
						  else
							  label = ('%s: <span class="green-text">%s</span>'):format(component.label, _U('armory_free'))
						  end
					  end
  
					  table.insert(components, {
						  label = label,
						  componentLabel = component.label,
						  hash = component.hash,
						  name = component.name,
						  price = v.components[i],
						  hasComponent = hasComponent,
						  componentNum = i
					  })
				  end
			  end
		  end
  
		  if hasWeapon and v.components then
			  label = ('%s: <span class="green-text">></span>'):format(weapon.label)
		  elseif hasWeapon and not v.components then
			  label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_owned'))
		  else
			  if v.price > 0 then
				  label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_item', ESX.Math.GroupDigits(v.price)))
			  else
				  label = ('%s: <span class="green-text">%s</span>'):format(weapon.label, _U('armory_free'))
			  end
		  end
  
		  table.insert(elements, {
			  label = label,
			  weaponLabel = weapon.label,
			  name = weapon.name,
			  components = components,
			  price = v.price,
			  hasWeapon = hasWeapon
		  })
	  end
  
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons', {
		  title    = 'คลังแสง - ซื้ออาวุธ',
		  align    = 'top-left',
		  elements = elements
	  }, function(data, menu)
  
		  if data.current.hasWeapon then
			  if #data.current.components > 0 then
				  OpenWeaponComponentShop(data.current.components, data.current.name, menu)
			  end
		  else
			  ESX.TriggerServerCallback('esx_spdjob:buyWeapon', function(bought)
				  if bought then
					  if data.current.price > 0 then
						exports.nc_notify:PushNotification({
							title = ' คุณซื้อ ' ..data.current.weaponLabel.. 'ราคา $' ..ESX.Math.GroupDigits(data.current.price),
							description = message,
							color = '#94dcfc',
							icon = 'message',
							direction = 'right',
							duration = 3000
						})
					  end
  
					  menu.close()
  
					  OpenBuyWeaponsMenu()
				  else
					exports.nc_notify:PushNotification({
						title = ' คุณมีเงินไม่เพียงพอ ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, data.current.name, 1)
		  end
  
	  end, function(data, menu)
		  menu.close()
	  end)
  
  end
  
  function OpenWeaponComponentShop(components, weaponName, parentShop)
	  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_buy_weapons_components', {
		  title    = 'คลังแสง - ตกแต่งอาวุธ',
		  align    = 'top-left',
		  elements = components
	  }, function(data, menu)
  
		  if data.current.hasComponent then
			exports.nc_notify:PushNotification({
				title = ' แต่งอุปกรณ์ปืนเรียบร้อยแล้ว ',
				description = message,
				color = '#94dcfc',
				icon = 'message',
				direction = 'right',
				duration = 3000
			})
		  else
			  ESX.TriggerServerCallback('esx_spdjob:buyWeapon', function(bought)
				  if bought then
					  if data.current.price > 0 then
						exports.nc_notify:PushNotification({
							title = ' คุณซื้อ ' ..data.current.componentLabel.. 'ราคา' ..ESX.Math.GroupDigits(data.current.price),
							description = message,
							color = '#94dcfc',
							icon = 'message',
							direction = 'right',
							duration = 3000
						})
					  end
  
					  menu.close()
					  parentShop.close()
  
					  OpenBuyWeaponsMenu()
				  else
					exports.nc_notify:PushNotification({
						title = ' คุณมีเงินไม่เพียงพอ ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  end
			  end, weaponName, 2, data.current.componentNum)
		  end
  
	  end, function(data, menu)
		  menu.close()
	  end)
  end
  
  function OpenGetStocksMenu()
  
	  ESX.TriggerServerCallback('esx_spdjob:getStockItems', function(items)
  
		  local elements = {}
  
		  for i=1, #items, 1 do
			  table.insert(elements, {
				  label = 'x' .. items[i].count .. ' ' .. items[i].label,
				  value = items[i].name
			  })
		  end
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		  {
			  title    = _U('spd_stock'),
			  align    = 'top-left',
			  elements = elements
		  }, function(data, menu)
  
			  local itemName = data.current.value
  
			  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				  title = _U('quantity')
			  }, function(data2, menu2)
  
				  local count = tonumber(data2.value)
  
				  if count == nil then
					exports.nc_notify:PushNotification({
						title = ' ปริมาณที่ไม่ถูกต้อง ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  else
					  menu2.close()
					  menu.close()
					  TriggerServerEvent('esx_spdjob:getStockItem', itemName, count)
  
					  Citizen.Wait(300)
					  OpenGetStocksMenu()
				  end
  
			  end, function(data2, menu2)
				  menu2.close()
			  end)
  
		  end, function(data, menu)
			  menu.close()
		  end)
  
	  end)
  
  end
  
  function OpenPutStocksMenu()
  
	  ESX.TriggerServerCallback('esx_spdjob:getPlayerInventory', function(inventory)
  
		  local elements = {}
  
		  for i=1, #inventory.items, 1 do
			  local item = inventory.items[i]
  
			  if item.count > 0 then
				  table.insert(elements, {
					  label = item.label .. ' x' .. item.count,
					  type = 'item_standard',
					  value = item.name
				  })
			  end
		  end
  
		  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		  {
			  title    = _U('inventory'),
			  align    = 'top-left',
			  elements = elements
		  }, function(data, menu)
  
			  local itemName = data.current.value
  
			  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				  title = _U('quantity')
			  }, function(data2, menu2)
  
				  local count = tonumber(data2.value)
  
				  if count == nil then
					exports.nc_notify:PushNotification({
						title = ' ปริมาณที่ไม่ถูกต้อง ',
						description = message,
						color = '#94dcfc',
						icon = 'message',
						direction = 'right',
						duration = 3000
					})
				  else
					  menu2.close()
					  menu.close()
					  TriggerServerEvent('esx_spdjob:putStockItems', itemName, count)
  
					  Citizen.Wait(300)
					  OpenPutStocksMenu()
				  end
  
			  end, function(data2, menu2)
				  menu2.close()
			  end)
  
		  end, function(data, menu)
			  menu.close()
		  end)
	  end)
  
  end
  
  RegisterNetEvent('esx:setJob')
  AddEventHandler('esx:setJob', function(job)
	  PlayerData.job = job
	  
	  Citizen.Wait(5000)
	  TriggerServerEvent('esx_spdjob:forceBlip')
  end)
  
  RegisterNetEvent('esx_phone:loaded')
  AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	  local specialContact = {
		  name       = _U('phone_spd'),
		  number     = 'spd',
		  base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDFGQTJDRkI0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDFGQTJDRkM0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo0MUZBMkNGOTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo0MUZBMkNGQTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PoW66EYAAAjGSURBVHjapJcLcFTVGcd/u3cfSXaTLEk2j80TCI8ECI9ABCyoiBqhBVQqVG2ppVKBQqUVgUl5OU7HKqNOHUHU0oHamZZWoGkVS6cWAR2JPJuAQBPy2ISEvLN57+v2u2E33e4k6Ngz85+9d++95/zP9/h/39GpqsqiRYsIGz8QZAq28/8PRfC+4HT4fMXFxeiH+GC54NeCbYLLATLpYe/ECx4VnBTsF0wWhM6lXY8VbBE0Ch4IzLcpfDFD2P1TgrdC7nMCZLRxQ9AkiAkQCn77DcH3BC2COoFRkCSIG2JzLwqiQi0RSmCD4JXbmNKh0+kc/X19tLtc9Ll9sk9ZS1yoU71YIk3xsbEx8QaDEc2ttxmaJSKC1ggSKBK8MKwTFQVXRzs3WzpJGjmZgvxcMpMtWIwqsjztvSrlzjYul56jp+46qSmJmMwR+P3+4aZ8TtCprRkk0DvUW7JjmV6lsqoKW/pU1q9YQOE4Nxkx4ladE7zd8ivuVmJQfXZKW5dx5EwPRw4fxNx2g5SUVLw+33AkzoRaQDP9SkFu6OKqz0uF8yaz7vsOL6ycQVLkcSg/BlWNsjuFoKE1knqDSl5aNnmPLmThrE0UvXqQqvJPyMrMGorEHwQfEha57/3P7mXS684GFjy8kreLppPUuBXfyd/ibeoS2kb0mWPANhJdYjb61AxUvx5PdT3+4y+Tb3mTd19ZSebE+VTXVGNQlHAC7w4VhH8TbA36vKq6ilnzlvPSunHw6Trc7XpZ14AyfgYeyz18crGN1Alz6e3qwNNQSv4dZox1h/BW9+O7eIaEsVv41Y4XeHJDG83Nl4mLTwzGhJYtx0PzNTjOB9KMTlc7Nkcem39YAGU7cbeBKVLMPGMVf296nMd2VbBq1wmizHoqqm/wrS1/Zf0+N19YN2PIu1fcIda4Vk66Zx/rVi+jo9eIX9wZGGcFXUMR6BHUa76/2ezioYcXMtpyAl91DSaTfDxlJbtLprHm2ecpObqPuTPzSNV9yKz4a4zJSuLo71/j8Q17ON69EmXiPIlNMe6FoyzOqWPW/MU03Lw5EFcyKghTrNDh7+/vw545mcJcWbTiGKpRdGPMXbx90sGmDaux6sXk+kimjU+BjnMkx3kYP34cXrFuZ+3nrHi6iDMt92JITcPjk3R3naRwZhpuNSqoD93DKaFVU7j2dhcF8+YzNlpErbIBTVh8toVccbaysPB+4pMcuPw25kwSsau7BIlmHpy3guaOPtISYyi/UkaJM5Lpc5agq5Xkcl6gIHkmqaMn0dtylcjIyPThCNyhaXyfR2W0I1our0v6qBii07ih5rDtGSOxNVdk1y4R2SR8jR/g7hQD9l1jUeY/WLJB5m39AlZN4GZyIQ1fFJNsEgt0duBIc5GRkcZF53mNwIzhXPDgQPoZIkiMkbTxtstDMVnmFA4cOsbz2/aKjSQjev4Mp9ZAg+hIpFhB3EH5Yal16+X+Kq3dGfxkzRY+KauBjBzREvGN0kNCTARu94AejBLMHorAQ7cEQMGs2cXvkWshYLDi6e9l728O8P1XW6hKeB2yv42q18tjj+iFTGoSi+X9jJM9RTxS9E+OHT0krhNiZqlbqraoT7RAU5bBGrEknEBhgJks7KXbLS8qERI0ErVqF/Y4K6NHZfLZB+/wzJvncacvFd91oXO3o/O40MfZKJOKu/rne+mRQByXM4lYreb1tUnkizVVA/0SpfpbWaCNBeEE5gb/UH19NLqEgDF+oNDQWcn41Cj0EXFEWqzkOIyYekslFkThsvMxpIyE2hIc6lXGZ6cPyK7Nnk5OipixRdxgUESAYmhq68VsGgy5CYKCUAJTg0+izApXne3CJFmUTwg4L3FProFxU+6krqmXu3MskkhSD2av41jLdzlnfFrSdCZxyqfMnppN6ZUa7pwt0h3fiK9DCt4IO9e7YqisvI7VYgmNv7mhBKKD/9psNi5dOMv5ZjukjsLdr0ffWsyTi6eSlfcA+dmiVyOXs+/sHNZu3M6PdxzgVO9GmDSHsSNqmTz/R6y6Xxqma4fwaS5Mn85n1ZE0Vl3CHBER3lUNEhiURpPJRFdTOcVnpUJnPIhR7cZXfoH5UYc5+E4RzRH3sfSnl9m2dSMjE+Tz9msse+o5dr7UwcQ5T3HwlWUkNuzG3dKFSTbsNs7m/Y8vExOlC29UWkMJlAxKoRQMR3IC7x85zOn6fHS50+U/2Untx2R1voinu5no+DQmz7yPXmMKZnsu0wrm0Oe3YhOVHdm8A09dBQYhTv4T7C+xUPrZh8Qn2MMr4qcDSRfoirWgKAvtgOpv1JI8Zi77X15G7L+fxeOUOiUFxZiULD5fSlNzNM62W+k1yq5gjajGX/ZHvOIyxd+Fkj+P092rWP/si0Qr7VisMaEWuCiYonXFwbAUTWWPYLV245NITnGkUXnpI9butLJn2y6iba+hlp7C09qBcvoN7FYL9mhxo1/y/LoEXK8Pv6qIC8WbBY/xr9YlPLf9dZT+OqKTUwfmDBm/GOw7ws4FWpuUP2gJEZvKqmocuXPZuWYJMzKuSsH+SNwh3bo0p6hao6HeEqwYEZ2M6aKWd3PwTCy7du/D0F1DsmzE6/WGLr5LsDF4LggnYBacCOboQLHQ3FFfR58SR+HCR1iQH8ukhA5s5o5AYZMwUqOp74nl8xvRHDlRTsnxYpJsUjtsceHt2C8Fm0MPJrphTkZvBc4It9RKLOFx91Pf0Igu0k7W2MmkOewS2QYJUJVWVz9VNbXUVVwkyuAmKTFJayrDo/4Jwe/CT0aGYTrWVYEeUfsgXssMRcpyenraQJa0VX9O3ZU+Ma1fax4xGxUsUVFkOUbcama1hf+7+LmA9juHWshwmwOE1iMmCFYEzg1jtIm1BaxW6wCGGoFdewPfvyE4ertTiv4rHC73B855dwp2a23bbd4tC1hvhOCbX7b4VyUQKhxrtSOaYKngasizvwi0RmOS4O1QZf2yYfiaR+73AvhTQEVf+rpn9/8IMAChKDrDzfsdIQAAAABJRU5ErkJggg=='
	  }
  
	  TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
  end)
  
  -- don't show dispatches if the player isn't in service
  AddEventHandler('esx_phone:cancelMessage', function(dispatchNumber)
	  if type(PlayerData.job.name) == 'string' and PlayerData.job.name == 'spd' and PlayerData.job.name == dispatchNumber then
		  -- if esx_service is enabled
		  if Config.MaxInService ~= -1 and not playerInService then
			  CancelEvent()
		  end
	  end
  end)
  
  AddEventHandler('esx_spdjob:hasEnteredMarker', function(station, part, partNum)
  
	  if part == 'Cloakroom' then
		  CurrentAction     = 'menu_cloakroom'
		  CurrentActionMsg  = _U('open_cloackroom')
		  CurrentActionData = {}
  
	  elseif part == 'Armory' then
  
		  CurrentAction     = 'menu_armory'
		  CurrentActionMsg  = _U('open_armory')
		  CurrentActionData = {station = station}
  
	  elseif part == 'Vehicles' then
  
		  CurrentAction     = 'menu_vehicle_spawner'
		  CurrentActionMsg  = _U('garage_prompt')
		  CurrentActionData = {station = station, part = part, partNum = partNum}
  
	  elseif part == 'Helicopters' then
  
		  CurrentAction     = 'Helicopters'
		  CurrentActionMsg  = _U('helicopter_prompt')
		  CurrentActionData = {station = station, part = part, partNum = partNum}
  
	  elseif part == 'BossActions' then
  
		  CurrentAction     = 'menu_boss_actions'
		  CurrentActionMsg  = _U('open_bossmenu')
		  CurrentActionData = {}
  
	  elseif part == 'SearchInfoActions' then
  
		  CurrentAction     = 'menu_search_actions'
		  CurrentActionMsg  = 'press ~INPUT_CONTEXT~ to open the menu'
		  CurrentActionData = {}
  
	  end
  
  end)
  
  AddEventHandler('esx_spdjob:hasExitedMarker', function(station, part, partNum)
	  if not isInShopMenu then
		  ESX.UI.Menu.CloseAll()
	  end
  
	  CurrentAction = nil
  end)
  
  AddEventHandler('esx_spdjob:hasEnteredEntityZone', function(entity)
	  local playerPed = PlayerPedId()
  
	  if PlayerData.job ~= nil and PlayerData.job.name == 'spd' and IsPedOnFoot(playerPed) then
		  CurrentAction     = 'remove_entity'
		  CurrentActionMsg  = _U('remove_prop')
		  CurrentActionData = {entity = entity}
	  end
  
	  if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then
		  local playerPed = PlayerPedId()
		  local coords    = GetEntityCoords(playerPed)
  
		  if IsPedInAnyVehicle(playerPed, false) then
			  local vehicle = GetVehiclePedIsIn(playerPed)
  
			  SetVehicleTyreBurst(vehicle, 0, true, 1000.0)
			  SetVehicleTyreBurst(vehicle, 1, true, 1000.0)
			  Citizen.Wait(200)
			  SetVehicleTyreBurst(vehicle, 2, true, 1000.0)
			  SetVehicleTyreBurst(vehicle, 3, true, 1000.0)
			  Citizen.Wait(200)
			  SetVehicleTyreBurst(vehicle, 4, true, 1000.0)
			  SetVehicleTyreBurst(vehicle, 5, true, 1000.0)
			  SetVehicleTyreBurst(vehicle, 6, true, 1000.0)
			  SetVehicleTyreBurst(vehicle, 7, true, 1000.0)
  
			  -- for i=0, 7, 1 do
			  --	SetVehicleTyreBurst(vehicle, i, true, 1000)
			  -- end
		  end
	  end
  end)
  
  AddEventHandler('esx_spdjob:hasExitedEntityZone', function(entity)
	  if CurrentAction == 'remove_entity' then
		  CurrentAction = nil
	  end
  end)
  
  RegisterNetEvent('esx_spdjob:getarrested')
  AddEventHandler('esx_spdjob:getarrested', function(playerheading, playercoords, playerlocation)
	  playerPed = GetPlayerPed(-1)
	  local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	  SetEntityCoords(GetPlayerPed(-1), x, y, z)
	  SetEntityHeading(GetPlayerPed(-1), playerheading)
	  Citizen.Wait(250)
	  ESX.Streaming.RequestAnimDict("mp_arrest_paired", function()
		  TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
		  Citizen.Wait(3060)
		  TriggerEvent("esx_spdjob:handcuff")
	  end)
	  
  end)
  
  RegisterNetEvent('esx_spdjob:douncuffing')
  AddEventHandler('esx_spdjob:douncuffing', function()
	  Citizen.Wait(250)
	  ESX.Streaming.RequestAnimDict("mp_arresting", function()
		  TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'a_uncuff', 8.0, -8,3750, 2, 0, 0, 0, 0)
	  end)
	  Citizen.Wait(5500)
	  ClearPedTasks(GetPlayerPed(-1))
  end)
  
  RegisterNetEvent('esx_spdjob:getuncuffed')
  AddEventHandler('esx_spdjob:getuncuffed', function(playerheading, playercoords, playerlocation)
	  local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	  SetEntityCoords(GetPlayerPed(-1), x, y, z)
	  SetEntityHeading(GetPlayerPed(-1), playerheading)
	  Citizen.Wait(250)
	  ESX.Streaming.RequestAnimDict("mp_arresting", function()
		  TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'b_uncuff', 8.0, -8,3750, 2, 0, 0, 0, 0)
		  Citizen.Wait(3000)
		  TriggerEvent("esx_spdjob:handcuff")
	  end)
	  
  end)
  
  
  RegisterNetEvent('esx_spdjob:doarrested')
  AddEventHandler('esx_spdjob:doarrested', function()
	  Citizen.Wait(250)
	  ESX.Streaming.RequestAnimDict("mp_arrest_paired", function()
		  TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
	  end)
	  Citizen.Wait(3000)
  end)
  
  
  RegisterNetEvent('esx_spdjob:handcuff')
  AddEventHandler('esx_spdjob:handcuff', function()
	  IsHandcuffed    = not IsHandcuffed
	  local playerPed = PlayerPedId()
  
	  Citizen.CreateThread(function()
		  
		  if IsHandcuffed then
  
			  SetEnableHandcuffs(playerPed, true)
			  DisablePlayerFiring(playerPed, true)
			  SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
			  SetPedCanPlayGestureAnims(playerPed, false)
			  --FreezeEntityPosition(playerPed, true)
			  DisableControlAction(0, Keys['M'], true)
			  DisplayRadar(false)
  
			  if Config.EnableHandcuffTimer then
  
				  if HandcuffTimer.Active then
					  ESX.ClearTimeout(HandcuffTimer.Task)
				  end
  
				  StartHandcuffTimer()
			  end
  
		  else
  
			  if Config.EnableHandcuffTimer and HandcuffTimer.Active then
				  ESX.ClearTimeout(HandcuffTimer.Task)
			  end
  
			  ClearPedSecondaryTask(playerPed)
			  SetEnableHandcuffs(playerPed, false)
			  DisablePlayerFiring(playerPed, false)
			  SetPedCanPlayGestureAnims(playerPed, true)
			  FreezeEntityPosition(playerPed, false)
			  DisplayRadar(true)
		  end
	  end)
  
  end)
  
  RegisterNetEvent('esx_spdjob:unrestrain')
  AddEventHandler('esx_spdjob:unrestrain', function()
	  if IsHandcuffed then
		  local playerPed = PlayerPedId()
		  IsHandcuffed = false
  
		  ClearPedSecondaryTask(playerPed)
		  SetEnableHandcuffs(playerPed, false)
		  DisablePlayerFiring(playerPed, false)
		  SetPedCanPlayGestureAnims(playerPed, true)
		  FreezeEntityPosition(playerPed, false)
		  DisplayRadar(true)
  
		  -- end timer
		  if Config.EnableHandcuffTimer and HandcuffTimer.Active then
			  ESX.ClearTimeout(HandcuffTimer.Task)
		  end
	  end
  end)
  
  RegisterNetEvent('esx_spdjob:drag')
  AddEventHandler('esx_spdjob:drag', function(copID)
	  if not IsHandcuffed and not IsPedSittingInAnyVehicle(targetPed) then
		  return
	  end
  
	  DragStatus.IsDragged = not DragStatus.IsDragged
	  DragStatus.CopId     = tonumber(copID)
  end)
  
  Citizen.CreateThread(function()
  
	  ObjectName = GetHashKey("prop_gas_pump_1b")
	  RequestModel(ObjectName)
	  while not HasModelLoaded(ObjectName) do
		  Wait(1)
	  end
  
	  local object = CreateObject(ObjectName, 442.05, -1014.26, 27.64, false, false, true)
	  PlaceObjectOnGroundProperly(object)
	  FreezeEntityPosition(object, true)
  
	  local playerPed
	  local targetPed
  
	  while true do
		  Citizen.Wait(1)
  
		  if IsHandcuffed then
			  playerPed = PlayerPedId()
  
			  if DragStatus.IsDragged then
				  targetPed = GetPlayerPed(GetPlayerFromServerId(DragStatus.CopId))
  
				  -- undrag if target is in an vehicle
				  if not IsPedSittingInAnyVehicle(targetPed) then
					  AttachEntityToEntity(PlayerPedId(), targetPed, 11816, 0.47, 0.20, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					  DragStatus.IsDragged = true
				  else
					  DragStatus.IsDragged = false
					  DetachEntity(playerPed, true, false)
				  end
  
				  if IsPedDeadOrDying(targetPed, true) then
					  DragStatus.IsDragged = false
					  DetachEntity(playerPed, true, false)
				  end
  
			  else
				  DetachEntity(playerPed, true, false)
			  end
		  else
			  Citizen.Wait(500)
		  end
	  end
  end)
  
  RegisterNetEvent('esx_spdjob:putInVehicle')
  AddEventHandler('esx_spdjob:putInVehicle', function()
	  local playerPed = PlayerPedId()
	  local coords = GetEntityCoords(playerPed)
  
	  if not IsHandcuffed and not Drag and not DragStatus then
		  return	
	  end
  
	  if IsAnyVehicleNearPoint(coords, 5.0) then
		  local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)
  
		  if DoesEntityExist(vehicle) and not Drag then
			  local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
  
			  for i=maxSeats - 1, 0, -1 do
				  if IsVehicleSeatFree(vehicle, i) then
					  freeSeat = i
					  break
				  end
			  end
  
			  if freeSeat and not Drag then
				  TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				  DragStatus.IsDragged = false
			  end
		  end
	  end
  end)
  
  RegisterNetEvent('esx_spdjob:OutVehicle')
  AddEventHandler('esx_spdjob:OutVehicle', function()
	  local playerPed = PlayerPedId()
  
	  if not IsPedSittingInAnyVehicle(playerPed) then
		  return
	  end
  
	  local vehicle = GetVehiclePedIsIn(playerPed, false)
	  TaskLeaveVehicle(playerPed, vehicle, 16)
  end)
  
  -- Handcuff
  Citizen.CreateThread(function()
	  while true do
		  Citizen.Wait(1)
		  local playerPed = PlayerPedId()
  
		  if IsHandcuffed then
			  DisableControlAction(0, 1, true) -- Disable pan
			  DisableControlAction(0, 2, true) -- Disable tilt
			  DisableControlAction(0, 24, true) -- Attack
			  DisableControlAction(0, 257, true) -- Attack 2
			  DisableControlAction(0, 25, true) -- Aim
			  DisableControlAction(0, 263, true) -- Melee Attack 1
			  DisableControlAction(0, Keys['W'], true) -- W
			  DisableControlAction(0, Keys['A'], true) -- A
			  DisableControlAction(0, 31, true) -- S (fault in Keys table!)
			  DisableControlAction(0, 30, true) -- D (fault in Keys table!)
  
			  DisableControlAction(0, Keys['R'], true) -- Reload
			  DisableControlAction(0, Keys['SPACE'], true) -- Jump
			  DisableControlAction(0, Keys['Q'], true) -- Cover
			  DisableControlAction(0, Keys['TAB'], true) -- Select Weapon
			  DisableControlAction(0, Keys['F'], true) -- Also 'enter'?
  
			  DisableControlAction(0, Keys['F1'], true) -- Disable phone
			  DisableControlAction(0, Keys['F2'], true) -- Inventory
			  DisableControlAction(0, Keys['F3'], true) -- Animations
			  DisableControlAction(0, Keys['F6'], true) -- Job
  
			  DisableControlAction(0, Keys['V'], true) -- Disable changing view
			  DisableControlAction(0, Keys['C'], true) -- Disable looking behind
			  DisableControlAction(0, Keys['X'], true) -- Disable clearing animation
			  DisableControlAction(2, Keys['P'], true) -- Disable pause screen
   
			  DisableControlAction(0, Keys['M'], true) -- Phone
			  DisableControlAction(0, 59, true) -- Disable steering in vehicle
			  DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			  DisableControlAction(0, 72, true) -- Disable reversing in vehicle
			  
			  
			  
			  DisableControlAction(2, Keys['LEFTCTRL'], true) -- Disable going stealth
  
			  DisableControlAction(0, 47, true)  -- Disable weapon
			  DisableControlAction(0, 264, true) -- Disable melee
			  DisableControlAction(0, 257, true) -- Disable melee
			  DisableControlAction(0, 140, true) -- Disable melee
			  DisableControlAction(0, 141, true) -- Disable melee
			  DisableControlAction(0, 142, true) -- Disable melee
			  DisableControlAction(0, 143, true) -- Disable melee
			  DisableControlAction(0, 75, true)  -- Disable exit vehicle
			  DisableControlAction(27, 75, true) -- Disable exit vehicle
  
			  if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				  ESX.Streaming.RequestAnimDict('mp_arresting', function()
					  TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				  end)
			  end
		  else
			  Citizen.Wait(500)
		  end
	  end
  end)
  
  -- Create blips
  --Citizen.CreateThread(function()
  --
  --	for k,v in pairs(Config.spdStations) do
  --		local blip = AddBlipForCoord(v.Blip.Coords)
  --
  --		SetBlipSprite (blip, v.Blip.Sprite)
  --		SetBlipDisplay(blip, v.Blip.Display)
  --		SetBlipScale  (blip, v.Blip.Scale)
  --		SetBlipColour (blip, v.Blip.Colour)
  --		SetBlipAsShortRange(blip, true)
  --
  --		BeginTextCommandSetBlipName("STRING")
  --		AddTextComponentString(_U('map_blip'))
  --		EndTextCommandSetBlipName(blip)
  --	end
  --
  --end)
  
  -- Display markers
  Citizen.CreateThread(function()
	  while true do
  
		  Citizen.Wait(0)
  
		  if PlayerData.job ~= nil and PlayerData.job.name == 'spd' then
  
			  local playerPed = PlayerPedId()
			  local coords    = GetEntityCoords(playerPed)
			  local isInMarker, hasExited, letSleep = false, false, true
			  local currentStation, currentPart, currentPartNum
  
			  for k,v in pairs(Config.spdStations) do
  
			  --	for i=1, #v.Cloakrooms, 1 do
			  --		local distance = GetDistanceBetweenCoords(coords, v.Cloakrooms[i], true)
			  --
			  --		if distance < Config.DrawDistance then
			  --			DrawMarker(20, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			  --			letSleep = false
			  --		end
			  --
			  --		if distance < Config.MarkerSize.x then
			  --			isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
			  --		end
			  --	end
  
				  for i=1, #v.Armories, 1 do
					  local distance = GetDistanceBetweenCoords(coords, v.Armories[i], true)
  
					  if distance < Config.DrawDistance then
						  DrawMarker(21, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						  letSleep = false
					  end
  
					  if distance < Config.MarkerSize.x then
						  isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
					  end
				  end
  
				  for i=1, #v.Vehicles, 1 do
					  local distance = GetDistanceBetweenCoords(coords, v.Vehicles[i].Spawner, true)
  
					  if distance < Config.DrawDistance then
						  DrawMarker(36, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						  letSleep = false
					  end
  
					  if distance < Config.MarkerSize.x then
						  isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
					  end
				  end
  
				  for i=1, #v.Helicopters, 1 do
					  local distance =  GetDistanceBetweenCoords(coords, v.Helicopters[i].Spawner, true)
  
					  if distance < Config.DrawDistance then
						  DrawMarker(34, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						  letSleep = false
					  end
  
					  if distance < Config.MarkerSize.x then
						  isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Helicopters', i
					  end
				  end
  
				  if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'recruit' then
					  for i=1, #v.BossActions, 1 do
						  local distance = GetDistanceBetweenCoords(coords, v.BossActions[i], true)
  
						  if distance < Config.DrawDistance then
							  DrawMarker(22, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
							  letSleep = false
						  end
  
						  if distance < Config.MarkerSize.x then
							  isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
						  end
					  end
				  end
  
				  if Config.EnablePlayerManagement then
					  for i=1, #v.SearchInfoActions, 1 do
						  local distance = GetDistanceBetweenCoords(coords, v.SearchInfoActions[i], true)
  
						  if distance < Config.DrawDistance then
							  DrawMarker(22, v.SearchInfoActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
							  letSleep = false
						  end
  
						  if distance < Config.MarkerSize.x then
							  isInMarker, currentStation, currentPart, currentPartNum = true, k, 'SearchInfoActions', i
						  end
					  end
				  end
  
			  end
  
			  if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
	  
				  if
					  (LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
					  (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				  then
					  TriggerEvent('esx_spdjob:hasExitedMarker', LastStation, LastPart, LastPartNum)
					  hasExited = true
				  end
  
				  HasAlreadyEnteredMarker = true
				  LastStation             = currentStation
				  LastPart                = currentPart
				  LastPartNum             = currentPartNum
  
				  TriggerEvent('esx_spdjob:hasEnteredMarker', currentStation, currentPart, currentPartNum)
  
			  end
  
			  if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				  HasAlreadyEnteredMarker = false
				  TriggerEvent('esx_spdjob:hasExitedMarker', LastStation, LastPart, LastPartNum)
			  end
  
			  if letSleep then
				  Citizen.Wait(500)
			  end
  
		  else
			  Citizen.Wait(500)
		  end
  
	  end
  end)
  
  -- Enter / Exit entity zone events
  Citizen.CreateThread(function()
	  local trackedEntities = {
		  'prop_roadcone02a',
		  'prop_barrier_work05',
		  'p_ld_stinger_s',
		  'prop_boxpile_07d',
		  'hei_prop_cash_crate_half_full'
	  }
  
	  while true do
		  Citizen.Wait(500)
  
		  local playerPed = PlayerPedId()
		  local coords    = GetEntityCoords(playerPed)
  
		  local closestDistance = -1
		  local closestEntity   = nil
  
		  for i=1, #trackedEntities, 1 do
			  local object = GetClosestObjectOfType(coords, 3.0, GetHashKey(trackedEntities[i]), false, false, false)
  
			  if DoesEntityExist(object) then
				  local objCoords = GetEntityCoords(object)
				  local distance  = GetDistanceBetweenCoords(coords, objCoords, true)
  
				  if closestDistance == -1 or closestDistance > distance then
					  closestDistance = distance
					  closestEntity   = object
				  end
			  end
		  end
  
		  if closestDistance ~= -1 and closestDistance <= 3.0 then
			  if LastEntity ~= closestEntity then
				  TriggerEvent('esx_spdjob:hasEnteredEntityZone', closestEntity)
				  LastEntity = closestEntity
			  end
		  else
			  if LastEntity ~= nil then
				  TriggerEvent('esx_spdjob:hasExitedEntityZone', LastEntity)
				  LastEntity = nil
			  end
		  end
	  end
  end)
  
  -- Key Controls
  Citizen.CreateThread(function()
	  while true do
  
		  Citizen.Wait(0)
  
		  if CurrentAction ~= nil then
			  ESX.ShowHelpNotification(CurrentActionMsg)
  
			  if IsControlJustReleased(0, Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'spd' then
  
				  if CurrentAction == 'menu_cloakroom' then
					  OpenCloakroomMenu()
				  elseif CurrentAction == 'menu_armory' then
					  if Config.MaxInService == -1 then
						  OpenArmoryMenu(CurrentActionData.station)
					  elseif playerInService then
						  OpenArmoryMenu(CurrentActionData.station)
		  
					  else
						  ESX.ShowNotification(_U('service_not'))
					  end
				  elseif CurrentAction == 'menu_vehicle_spawner' then
					  if Config.MaxInService == -1 then
						  OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					  elseif playerInService then
						  OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					  else
						  ESX.ShowNotification(_U('service_not'))
					  end
				  elseif CurrentAction == 'Helicopters' then
					  if Config.MaxInService == -1 then
						  OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					  elseif playerInService then
						  OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
					  else
						  ESX.ShowNotification(_U('service_not'))
					  end
				  elseif CurrentAction == 'delete_vehicle' then
					  ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				  elseif CurrentAction == 'menu_boss_actions' then
					  ESX.UI.Menu.CloseAll()
					  TriggerEvent('esx_society:openBossMenu', 'spd', function(data, menu)
						  menu.close()
  
						  CurrentAction     = 'menu_boss_actions'
						  CurrentActionMsg  = _U('open_bossmenu')
						  CurrentActionData = {}
					  end, { wash = false }) -- disable washing money
				  elseif CurrentAction == 'menu_search_actions' then
					  ESX.UI.Menu.CloseAll()
					  OpenSearchInfo()
				  elseif CurrentAction == 'remove_entity' then
					  DeleteEntity(CurrentActionData.entity)
				  end
				  
				  CurrentAction = nil
			  end
		  end -- CurrentAction end
		  
		  if IsControlJustReleased(0, Keys['F6']) and not isDead and PlayerData.job ~= nil and PlayerData.job.name == 'spd' and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'spd_actions') then
			  if Config.MaxInService == -1 then
				  OpenspdActionsMenu()
			  elseif playerInService then
				  OpenspdActionsMenu()
			  else
				  ESX.ShowNotification(_U('service_not'))
			  end
		  end
		  
		  if IsControlJustReleased(0, Keys['E']) and CurrentTask.Busy then
			  ESX.ShowNotification(_U('impound_canceled'))
			  ESX.ClearTimeout(CurrentTask.Task)
			  ClearPedTasks(PlayerPedId())
			  
			  CurrentTask.Busy = false
		  end
	  end
  end)
  
  -- Create blip for colleagues
  function createBlip(id)
	  local ped = GetPlayerPed(id)
	  local blip = GetBlipFromEntity(ped)
  
	  if not DoesBlipExist(blip) then -- Add blip and create head display on player
		  blip = AddBlipForEntity(ped)
		  SetBlipSprite(blip, 1)
		  ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		  SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		  SetBlipNameToPlayerName(blip, id) -- update blip name
		  SetBlipScale(blip, 0.85) -- set scale
		  SetBlipAsShortRange(blip, true)
		  
		  table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	  end
  end
  
  RegisterNetEvent('esx_spdjob:updateBlip')
  AddEventHandler('esx_spdjob:updateBlip', function()
	  
	  -- Refresh all blips
	  for k, existingBlip in pairs(blipsCops) do
		  RemoveBlip(existingBlip)
	  end
	  
	  -- Clean the blip table
	  blipsCops = {}
  
	  -- Enable blip?
	  if Config.MaxInService ~= -1 and not playerInService then
		  return
	  end
  
	  if not Config.EnableJobBlip then
		  return
	  end
	  
	  -- Is the player a cop? In that case show all the blips for other cops
  --[[ 	if PlayerData.job ~= nil and PlayerData.job.name == 'spd' then
		  ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
			  for i=1, #players, 1 do
				  if players[i].job.name == 'spd' then
					  local id = GetPlayerFromServerId(players[i].source)
					  if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						  createBlip(id)
					  end
				  end
			  end
		  end)
	  end ]]
  
  end)
  
  AddEventHandler('playerSpawned', function(spawn)
	  isDead = false
	  TriggerEvent('esx_spdjob:unrestrain')
	  
	  if not hasAlreadyJoined then
		  TriggerServerEvent('esx_spdjob:spawned')
	  end
	  hasAlreadyJoined = true
  end)
  
  AddEventHandler('esx:onPlayerDeath', function(data)
	  isDead = true
  end)
  
  -- AddEventHandler('onResourceStop', function(resource)
  -- 	if resource == GetCurrentResourceName() then
  -- 		TriggerEvent('esx_spdjob:unrestrain')
  -- 		TriggerEvent('esx_phone:removeSpecialContact', 'spd')
  -- 
  -- 		if Config.MaxInService ~= -1 then
  -- 			TriggerServerEvent('esx_service:disableService', 'spd')
  -- 		end
  -- 
  -- 		if Config.EnableHandcuffTimer and HandcuffTimer.Active then
  -- 			ESX.ClearTimeout(HandcuffTimer.Task)
  -- 		end
  -- 	end
  -- end)
  -- 
  -- handcuff timer, unrestrain the player after an certain amount of time
  function StartHandcuffTimer()
	  if Config.EnableHandcuffTimer and HandcuffTimer.Active then
		  ESX.ClearTimeout(HandcuffTimer.Task)
	  end
  
	  HandcuffTimer.Active = true
  
	  HandcuffTimer.Task = ESX.SetTimeout(Config.HandcuffTimer, function()
		  -- ESX.ShowNotification(_U('unrestrained_timer'))
		  TriggerEvent('esx_spdjob:unrestrain')
		  HandcuffTimer.Active = false
	  end)
  end
  
  -- TODO
  --   - return to garage if owned
  --   - message owner that his vehicle has been impounded
  function ImpoundVehicle(vehicle)
	  local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
	  local content = '' .. GetPlayerName(PlayerId()) .. ' ส่งรถ ทะเบียน ' .. plate .. ' ไปยังพาวท์'
	  TriggerServerEvent('azael_dc-serverlogs:insertData', 'spdImPound', content, GetPlayerServerId(PlayerId()), '^5')
  
	  ESX.Game.DeleteVehicle(vehicle) 
	  exports.nc_notify:PushNotification({
		title = ' พาวน์รถเรียบร้อยแล้ว ',
		description = message,
		color = '#94dcfc',
		icon = 'message',
		direction = 'right',
		duration = 3000
	})
	  CurrentTask.Busy = false
  end
  
  function ImpoundVehiclespd(vehicle)
	  local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
	  local content = '' .. GetPlayerName(PlayerId()) .. ' ยึดรถ ทะเบียน ' .. plate .. ' ไปยังพาวท์'
	  TriggerServerEvent('azael_dc-serverlogs:insertData', 'spdImPound', content, GetPlayerServerId(PlayerId()), '^3')
  
	  TriggerServerEvent('esx_spdjob:updateVehicleFromspd', plate)
	  ESX.Game.DeleteVehicle(vehicle) 
	  exports.nc_notify:PushNotification({
		title = ' พาวน์รถเรียบร้อยแล้ว ',
		description = message,
		color = '#94dcfc',
		icon = 'message',
		direction = 'right',
		duration = 3000
	})
	  CurrentTask.Busy = false
  end
  
  
  AddEventHandler("esx_spdjob:closeall", function()
	  ESX.UI.Menu.CloseAll()
  end) 
  
  RegisterCommand('Closeall', function()
	  TriggerEvent('esx_spdjob:closeall')
	  exports.PorNotify:SendNotification(
		  {
			  text = "Close UI.Menu()!!!!!",
			  type = "success",
			  timeout = 3000,
			  layout = "bottomCenter"
		  }
	  )
  end)
  
  
  System = {
	  ['esx_spdjob:drag'] = function(copID)	
		  if IsHandcuffed then
				  playerPed = PlayerPedId()	
			  if Drag == false then		
				  local targetPed = GetPlayerPed(GetPlayerFromServerId(copID))
				  AttachEntityToEntity(PlayerPedId(), targetPed, 11816, 0.54, -0.10, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
				  RequestAnimDict("move_action@generic@core")	
				  TaskPlayAnim(PlayerPedId(), 'move_action@generic@core', 'walk', 5.0, -1, -1, 9, 0, false, false, false)
				  Drag = true
			  else
				  DetachEntity(PlayerPedId(), true, false)
				  ClearPedTasksImmediately(targetPed)
				  ClearPedTasksImmediately(PlayerPedId())
				  
				  Drag = false
			  end	
		  end	
	  end,
  }
  
  for k,v in pairs(System) do
	  RegisterNetEvent(k)
	  AddEventHandler(k, v)
  end
  
  function spdDrag()
	  Citizen.CreateThread(function()
		  if animation == false then
		  RequestAnimDict("anim@heists@ornate_bank@grab_cash")
		  TaskPlayAnim(PlayerPedId(), 'anim@heists@ornate_bank@grab_cash', 'grab_idle', 5.0, -1, -1, 50, 0, false, false, false)
		  animation = true
		  else
			  ClearPedTasksImmediately(PlayerPedId())
			  animation = false
		  end
	  end)
  end
  