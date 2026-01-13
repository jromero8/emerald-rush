extends Node
class_name Progress

var day : int = 0
var money : int = 0
var resources = {}
var upgrades = {}
var inventory = {}

func add_resource(res : Game.ResourceType, amount : int) -> void:
	if !resources.has(res):
		resources[res] = 0
	resources[res] = resources[res] + amount
	Game.resource_updated.emit(res)

func can_afford(it : Game.ShopItem) -> bool:
	return Game.get_item_cost(it) <= money

func add_money(amount : int) -> void:
	money += amount
	Game.money_updated.emit()

func get_resource(res : Game.ResourceType) -> int:
	if !resources.has(res):
		return 0
	return resources[res]

func sell_resource(res : Game.ResourceType, amount : int) -> void:
	var res_amount : int = get_resource(res)
	var amount_to_sell : int = amount
	if amount_to_sell > res_amount:
		amount_to_sell = res_amount
	add_money(amount_to_sell * Game.get_resource_value(res) * (Game.progress.get_upgrade(Game.UpgradeType.PROFIT) + 1))
	add_resource(res, amount_to_sell * (-1))

func buy_upgrade(up : Game.UpgradeType, amount : int = 1) -> void:
	if !upgrades.has(up):
		upgrades[up] = 0
	if upgrades[up] + amount <= get_max_upgrade(up):
		if Game.can_afford_upgrade(up):
			remove_resources(up)
			upgrades[up] = upgrades[up] + amount
			Game.upgrade_applied.emit(up)

func remove_resources(up : Game.UpgradeType) -> void:
	var cost : Array[int] = Game.get_upgrade_cost(up)
	for i : int in cost.size():
		var value : int = cost[i]
		add_resource(i, value * (-1))

func get_upgrade(up : Game.UpgradeType) -> int:
	if !upgrades.has(up):
		return 0
	return upgrades[up]

func get_max_upgrade(up : Game.UpgradeType) -> int:
	return 10

func is_max_upgrade(up : Game.UpgradeType) -> bool:
	return get_upgrade(up) >= get_max_upgrade(up)

func is_max_inventory(it : Game.ShopItem) -> bool:
	return get_inventory(it) >= get_max_inventory(it)

func buy_inventory(it : Game.ShopItem) -> void:
	if !is_max_inventory(it) and can_afford(it):
		add_money(Game.get_item_cost(it) * (-1))
		add_inventory(it, 1)


func add_inventory(it : Game.ShopItem, amount : int = 1) -> void:
	if !inventory.has(it):
		inventory[it] = 0
	if inventory[it] + amount <= get_max_inventory(it):
		inventory[it] = inventory[it] + amount
		Game.inventory_updated.emit(it)

func get_inventory(it : Game.ShopItem) -> int:
	if !inventory.has(it):
		return 0
	return inventory[it]

func get_max_inventory(it : Game.ShopItem) -> int:
	match it:
		Game.ShopItem.WORKER:
			return 21
		Game.ShopItem.COFFEE:
			return 10
		Game.ShopItem.CLOVER:
			return 10
	return 10

func use_inventory_item(it : Game.ShopItem) -> void:
	match it:
		Game.ShopItem.COFFEE:
			World.get_instance().use_coffee()
		Game.ShopItem.CLOVER:
			if get_inventory(it) > 0:
				Game.clover_active = 1
				add_inventory(it, -1)

func is_inventory_empty() -> bool:
	for it in Game.ShopItem.values():
		if it != Game.ShopItem.WORKER:
			if get_inventory(it) > 0:
				return false
	return true
