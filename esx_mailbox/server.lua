ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

---------------------------------------------
----------------- Functions -----------------
---------------------------------------------

RegisterServerEvent('GS_cassetta:setTitle')
AddEventHandler('GS_cassetta:setTitle', function(title, dbid)
	MySQL.Async.execute('UPDATE `mail_setting` SET `value` = "' .. title .. '" WHERE `key` = "title" AND dbid = "' .. dbid .. '"', {}, function(rowsChanged) end)
end)

RegisterServerEvent('GS_cassetta:addMail')
AddEventHandler('GS_cassetta:addMail', function(title, text, footer, autor, dbid)
	MySQL.Sync.execute("INSERT INTO `mail` (`id`, `dbid`, `title`, `text`, `footer`, `data`, `autor`, `unread`) VALUES (NULL, @dbid, @title, @text, @footer, @datum, @autor, 1)", {
		['@title'] = title,
		['@text'] = text,
		['@footer'] = footer,
		['@datum'] = os.date("%Y-%m-%d"),
		['@autor'] = autor,
		['@dbid'] = dbid}
	)
end)

RegisterServerEvent('GS_cassetta:setRead')
AddEventHandler('GS_cassetta:setRead', function(id)
	MySQL.Async.execute('UPDATE `mail` SET `unread` = "0" WHERE `id` = "' .. id .. '"', {}, function(rowsChanged) end)
end)

RegisterServerEvent('GS_cassetta:setUnread')
AddEventHandler('GS_cassetta:setUnread', function(id)
	MySQL.Async.execute('UPDATE `mail` SET `unread` = "1" WHERE `id` = "' .. id .. '"', {}, function(rowsChanged) end)
end)

RegisterServerEvent('GS_cassetta:delete')
AddEventHandler('GS_cassetta:delete', function(id)
	MySQL.Async.execute('DELETE FROM `mail` WHERE `mail`.`id` = "' .. id .. '"', {}, function(rowsChanged) end)
end)

---------------------------------------------
------------------------------ Callbacks ---- 
---------------------------------------------

ESX.RegisterServerCallback('GS_cassetta:getTitle', function(source, cb, dbid)
	MySQL.Async.fetchScalar('SELECT value FROM mail_setting WHERE `key` = "title" AND dbid = ' .. dbid .. '', {}, function(title)
		cb(title)
	end)
end)

ESX.RegisterServerCallback('GS_cassetta:getUnreadCount', function(source, cb, dbid)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM mail WHERE mail.unread = 1 AND dbid = ' .. dbid .. '', {}, function(count)
		cb(count)
	end)
end)

ESX.RegisterServerCallback('GS_cassetta:getMailCount', function(source, cb, dbid)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM mail WHERE `dbid` = ' .. dbid .. '', {}, function(count)
		cb(count)
	end)
end)

ESX.RegisterServerCallback('GS_cassetta:getMail', function(source, cb, dbid)
	MySQL.Async.fetchAll('SELECT * FROM mail WHERE `dbid` = "' .. dbid .. '"', {}, function(mails)
		cb(mails)
	end)
end)

ESX.RegisterServerCallback('GS_cassetta:hasItem', function(source, cb, itemname)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local xItem = sourceXPlayer.getInventoryItem(itemname)

	if xItem.count >= 1 then
	   cb(true)
	else
	   cb(false)
	end
end)
