ESX = nil
local posizioni = Config.Positions
local titlename = ""
local guiEnabled = false
local props = {}

-- ESX
Citizen.CreateThread(function()
  SetNuiFocus(false, false)

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for k in pairs(posizioni) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posizioni[k].x, posizioni[k].y, posizioni[k].z)

			if dist <= 1.2 then
				ESX.ShowHelpNotification (_U('press'))
				if IsControlJustPressed(1,51) then
								
					ESX.TriggerServerCallback('GS_cassetta:getTitle', function(titleresult)	
						ESX.TriggerServerCallback('GS_cassetta:getMailCount', function(countresult)	
							ESX.TriggerServerCallback('GS_cassetta:getUnreadCount', function(unreadresult)	
								ESX.TriggerServerCallback('GS_cassetta:hasItem', function(gotitem)	
									--print("State " ..(gotitem and 'true' or 'false'))
									--print("Item " .. posizioni[k].itemname)
									if titleresult == nil then
										OpenCassetta(gotitem, unreadresult, countresult, _U('mailbox_undefined'), stateresult)
									else
										OpenCassetta(gotitem, unreadresult, countresult, _U('mailbox_prefix') .. titleresult, stateresult)
									end
								end, posizioni[k].itemname)
							end, posizioni[k].dbid)
						end, posizioni[k].dbid)
					end, posizioni[k].dbid)
				end
            end
        end
    end
end)

function EnableGui(enable, mailid, mailtitle, mailtext, mailfooter, maildata, mailautor)
    SetNuiFocus(enable, enable)
    guiEnabled = enable

    SendNUIMessage({
        type = "enableui",
        enable = enable,
		mailid = mailid, 
		mailtitle = mailtitle, 
		mailtext = mailtext, 
		mailfooter = mailfooter, 
		maildata = maildata,
		mailautor = mailautor
    })
end

function EditCassetta()

	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'edit_anschrift', {
		title = _U('mb_change')
	}, function(data2, menu2)

		for k in pairs(posizioni) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posizioni[k].x, posizioni[k].y, posizioni[k].z)

            if dist <= 1.2 then
				menu2.close()
				TriggerServerEvent('GS_cassetta:setTitle', data2.value, posizioni[k].dbid)
				ESX.ShowNotification(_U('mb_changesuccess') .. data2.value)
            end
        end

	end, function(data2, menu2)
		menu2.close()
	end)	
	
end

function SendCassetta()

	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_title', {
		title = _U('mbsd_title')
	}, function(data, menu)

		ESX.UI.Menu.CloseAll()
		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_main', {
			title = _U('mbsd_content')
		}, function(data2, menu2)

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_footer', {
				title = _U('mbsd_footer')
			}, function(data3, menu3)

				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_sender', {
					title = _U('mbsd_author')
				}, function(data4, menu4)

					ESX.UI.Menu.CloseAll()

					for k in pairs(posizioni) do

						local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
						local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posizioni[k].x, posizioni[k].y, posizioni[k].z)
			
						if dist <= 1.2 then
							TriggerServerEvent('GS_cassetta:addMail', data.value, data2.value, data3.value, data4.value, posizioni[k].dbid)
						end
					end

				end, function(data4, menu4)
					ESX.UI.Menu.CloseAll()
				end)

			end, function(data3, menu3)
				ESX.UI.Menu.CloseAll()
			end)
		end, function(data2, menu2)
			ESX.UI.Menu.CloseAll()
		end)
	end, function(data, menu)
		ESX.UI.Menu.CloseAll()
	end)	
end

function GetBriefe() 
	for k in pairs(posizioni) do

		local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
		local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, posizioni[k].x, posizioni[k].y, posizioni[k].z)
			
		if dist <= 1.2 then
			ESX.TriggerServerCallback('GS_cassetta:getMail', function(mails)	
	
				local elements = {}
			
				for k, mail in pairs(mails) do
					table.insert(elements, {label = mail.id .. ' - ' .. mail.title, id = mail.id, title = mail.title, text = mail.text, footer = mail.footer, data = mail.data, autor = mail.autor, unread = mail.unread})
				end
			
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cassetta_show', {
					title    = _U('mailbox_inbox'),
					align    = 'top-left',
					elements = elements
				}, function(data, menu)
					
						local elements2 = {}
						
						table.insert(elements2, {label = _U('mbib_read'), value = 'show'})
						table.insert(elements2, {label = _U('mbib_markread'), value = 'read'})
						table.insert(elements2, {label = _U('mbib_markunread'), value = 'unread'})
						table.insert(elements2, {label = _U('mbib_delete'), value = 'delete'})
				
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cassetta_show2', {
							title    = _U('mbsd_menu'),
							align    = 'top-left',
							elements = elements2
						}, function(data2, menu2)
							
							if data2.current.value == 'show' then
								ESX.UI.Menu.CloseAll()
								EnableGui(true, data.current.id, data.current.title, data.current.text, data.current.footer, data.current.data, data.current.autor)
							elseif data2.current.value == 'read' then
								TriggerServerEvent('GS_cassetta:setRead', data.current.id)
							elseif data2.current.value == 'unread' then
								TriggerServerEvent('GS_cassetta:setUnread', data.current.id)
							elseif data2.current.value == 'delete' then
								TriggerServerEvent('GS_cassetta:delete', data.current.id)
							end
							
						end, function(data2, menu2)
							menu2.close()
							EnableGui(false, data.current.id, data.current.title, data.current.text, data.current.footer, data.current.data, data.current.autor)
						end)
					
				end, function(data, menu)
					menu.close()
					EnableGui(false, data.current.id, data.current.title, data.current.text, data.current.footer, data.current.data, data.current.autor)
				end)
			end, posizioni[k].dbid)
		end
	end

end

function OpenCassetta(isOwner, unread, total, title, canopen)
	
	local elements = {}

	table.insert(elements, {label = _U('mbsd_submenu'), value = 'send'})

	if isOwner == true then
		table.insert(elements, {label = _U('mbsd_submenu_counter', unread, total), value = 'get'})
		table.insert(elements, {label = _U('mbsd_changename'), value = 'edit'})
	end

	ESX.UI.Menu.CloseAll()
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cassetta', {
		title    = title,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'edit' then
			EditCassetta()		
		elseif data.current.value == 'get' then
			GetBriefe()
		elseif data.current.value == 'send' then			
			SendCassetta()			
		end

	end, function(data, menu)
		menu.close()
	end)
	
end

function closeGui()
  SetNuiFocus(false, false)
  SendNUIMessage({type = "enableui", enable = false})
end

RegisterNUICallback('quit', function(data, cb)
  closeGui()
  cb('ok')
end)

function convertDate(vardate)
    local y, m, d = string.match(vardate, '(%d+)-(%d+)-(%d+)')
    return string.format('%s-%s-%s', y,m,d)
end

Citizen.CreateThread(function()
	Citizen.Wait(0)
	
	for k in pairs(posizioni) do
		ESX.Game.SpawnLocalObject('prop_postbox_01a', vector3(posizioni[k].x, posizioni[k].y, posizioni[k].z), function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)
			SetEntityHeading(obj, posizioni[k].h)

			table.insert(props, obj)
		end)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(props) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

-- 3d Text Function
DrawText3Ds = function(coords, text, scale)
    local x,y,z = coords.x, coords.y, coords.z
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 215)

    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 280

    --DrawRect(_x, _y + 0.0115, 0.032 + factor, 0.033, 41, 11, 41, 100)
end
