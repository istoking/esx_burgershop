ESX             = nil
local burgershotItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM burgershot LEFT JOIN items ON items.name = burgershot.item', {}, function(burgershotResult)
		for i=1, #burgershotResult, 1 do
			if burgershotResult[i].name then
				if burgershotItems[burgershotResult[i].store] == nil then
					burgershotItems[burgershotResult[i].store] = {}
				end

				if burgershotResult[i].limit == -1 then
					burgershotResult[i].limit = 30
				end

				table.insert(burgershotItems[burgershotResult[i].store], {
					label = burgershotResult[i].label,
					item  = burgershotResult[i].item,
					price = burgershotResult[i].price,
					limit = burgershotResult[i].limit
				})
			else
				print(('esx_burgershot: invalid item "%s" found!'):format(burgershotResult[i].item))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_burgershot:requestDBItems', function(source, cb)
	cb(burgershotItems)
end)

RegisterServerEvent('esx_burgershot:buyItem')
AddEventHandler('esx_burgershot:buyItem', function(itemName, amount, zone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	amount = ESX.Math.Round(amount)

	-- is the player trying to exploit?
	if amount < 0 then
		print('esx_burgershot: ' .. xPlayer.identifier .. ' attempted to exploit the shop!')
		return
	end

	-- get price
	local price = 0
	local itemLabel = ''

	for i=1, #burgershotItems[zone], 1 do
		if burgershotItems[zone][i].item == itemName then
			price = burgershotItems[zone][i].price
			itemLabel = burgershotItems[zone][i].label
			break
		end
	end

	price = price * amount

	-- can the player afford this item?
	if xPlayer.getMoney() >= price then
		-- can the player carry the said amount of x item?
		if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('player_cannot_hold'), length = 5000})
		else
			xPlayer.removeMoney(price)
			xPlayer.addInventoryItem(itemName, amount)
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'success', text = _U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)), length = 5000})
		end
	else
		local missingMoney = price - xPlayer.getMoney()
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = _U('not_enough', ESX.Math.GroupDigits(missingMoney)), length = 5000})
	end
end)
