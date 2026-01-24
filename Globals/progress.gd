extends Node

enum ResourceType {
	ROCK,
	IRON,
	COPPER,
	SILVER,
	GOLD,
	PLATINUM,
	EMERALD,
}


enum UpgradeType {
	SPEED,
	ENERGY,
	STRENGTH,
	LUCK,
	SPAWN,
	PROFIT,
	PRESTIGE_STARTING_WORKERS,
	PRESTIGE_PICKAXE,
	PRESTIGE_EMERALDS,
	PRESTIGE_ARTIFACTS,
	PRESTIGE_ARCHAEOLOGY,
	PRESTIGE_VISITOR,
}

enum InventoryItem {
	WORKER,
	COFFEE,
	CLOVER,
}

const amount_per_resource = [
	3,
	6,
	8,
	12,
	15,
	20,
	20
]

const money_per_resource = [
	1,
	5,
	20,
	50,
	120,
	200,
	0
]

const item_base_cost = [
	20,
	100,
	200,
]

signal resource_updated(res : ResourceType)
signal money_updated
signal upgrade_applied(up : UpgradeType)
signal inventory_updated(it : InventoryItem)

var day : int = 0
var money : int = 0
var prestige_level : int = 0
var resources = {}
var upgrades = {}
var inventory = {}
var coffee_used : bool = false
var clover_used : bool = false

var last_save : int = 0
var save_interval : int = 5000
var force_save = false
var progress_modified = false

func _ready() -> void:
	load_progress()

func _ssssphysics_process(_delta: float) -> void:
	if force_save or (Time.get_ticks_msec() > last_save + save_interval and progress_modified):
		var p_msg = "progress saved" if !force_save else "progress saved (forced)"
		print(p_msg)
		force_save = false
		progress_modified = false
		last_save = Time.get_ticks_msec()
		save_progress()

func save_progress():
	var data = {}
	data.set("day", day)
	data.set("money", money)
	data.set("prestige_level", prestige_level)
	data.set("resources", resources)
	data.set("upgrades", upgrades)
	data.set("inventory", inventory)
	SaveGame.save_data("progress", data)

func load_progress():
	var p : Dictionary = SaveGame.load_data("progress")
	if p != null:
		for p_id : StringName in p:
			match p_id:
				"day":
					day = p.get(p_id)
				"money":
					money = p.get(p_id)
				"prestige_level":
					prestige_level = p.get(p_id)
				"resources":
					resources = p.get(p_id)
				"upgrades":
					upgrades = p.get(p_id)
				"inventory":
					inventory = p.get(p_id)


func add_resource(res : Progress.ResourceType, amount : int) -> void:
	if !resources.has(res):
		resources[res] = 0
	resources[res] = resources[res] + amount
	resource_updated.emit(res)
	progress_modified = true


func can_afford(it : InventoryItem) -> bool:
	return Progress.get_item_cost(it) <= money

func add_money(amount : int) -> void:
	money += amount
	money_updated.emit()
	progress_modified = true

func get_resource(res : Progress.ResourceType) -> int:
	if !resources.has(res):
		return 0
	return resources[res]

func get_resource_title(rs : ResourceType) -> String:
	var res_name : String = ResourceType.keys()[rs]
	return res_name.capitalize()

func get_upgrade_cost_description(up : UpgradeType) -> String:
	var cost : Array[int] = get_upgrade_cost(up)
	var result : String = ""
	var first = true
	for i : int in cost.size():
		var value : int = cost[i]
		if value > 0:
			if first:
				first = false
			else:
				result += " + "
			result += str(value) + " " + get_resource_title(i)
	return result

func sell_resource(res : Progress.ResourceType, amount : int) -> void:
	var res_amount : int = get_resource(res)
	var amount_to_sell : int = amount
	if amount_to_sell > res_amount:
		amount_to_sell = res_amount
	add_money(amount_to_sell * Progress.get_resource_value(res) * (get_upgrade(Progress.UpgradeType.PROFIT) + 1))
	add_resource(res, amount_to_sell * (-1))

func remove_resources(up : UpgradeType) -> void:
	var cost : Array[int] = get_upgrade_cost(up)
	for i : int in cost.size():
		var value : int = cost[i]
		add_resource(i, value * (-1))

func buy_upgrade(up : UpgradeType, amount : int = 1) -> void:
	if !upgrades.has(up):
		upgrades[up] = 0
	if upgrades[up] + amount <= get_max_upgrade(up):
		if can_afford_upgrade(up):
			remove_resources(up)
			upgrades[up] = upgrades[up] + amount
			upgrade_applied.emit(up)
			progress_modified = true

func downgrade_upgrade(up : UpgradeType) -> void:
	if !upgrades.has(up):
		upgrades[up] = 0
	if upgrades[up] > 0:
		upgrades[up] -= 1
		upgrade_applied.emit(up)
		progress_modified = true

func get_upgrade(up : UpgradeType) -> int:
	if !upgrades.has(up):
		return 0
	return upgrades[up]

func get_max_upgrade(up : UpgradeType) -> int:
	if is_prestige_upgrade(up):
		return 3
	else:
		return 10

func is_max_upgrade(up : UpgradeType) -> bool:
	return get_upgrade(up) >= get_max_upgrade(up)

func is_prestige_upgrade(up: UpgradeType) -> bool:
	for up_name in Progress.UpgradeType.keys():
		if Progress.UpgradeType[up_name] == up:
			return up_name.begins_with("PRESTIGE_")
	return false

func is_max_inventory(it : InventoryItem) -> bool:
	return get_inventory(it) >= get_max_inventory(it)

func buy_inventory(it : InventoryItem) -> void:
	if !is_max_inventory(it) and can_afford(it):
		add_money(get_item_cost(it) * (-1))
		add_inventory(it, 1)

func add_inventory(it : InventoryItem, amount : int = 1) -> void:
	if !inventory.has(it):
		inventory[it] = 0
	if inventory[it] + amount <= get_max_inventory(it):
		inventory[it] = inventory[it] + amount
		inventory_updated.emit(it)
		progress_modified = true

func get_inventory(it : InventoryItem) -> int:
	if !inventory.has(it):
		return 0
	return inventory[it]

func get_max_inventory(it : InventoryItem) -> int:
	match it:
		Progress.InventoryItem.WORKER:
			return 21
		Progress.InventoryItem.COFFEE:
			return 10
		Progress.InventoryItem.CLOVER:
			return 10
	return 10

func use_inventory_item(it : InventoryItem) -> void:
	match it:
		Progress.InventoryItem.COFFEE:
			World.get_instance().use_coffee()
		Progress.InventoryItem.CLOVER:
			if get_inventory(it) > 0:
				clover_used = true
				add_inventory(it, -1)

func is_inventory_empty() -> bool:
	for it in Progress.InventoryItem.values():
		if it != Progress.InventoryItem.WORKER:
			if get_inventory(it) > 0:
				return false
	return true

func next_day() -> void:
	save_progress()
	day += 1
	coffee_used = false
	clover_used = false

func prestige() -> void:
	prestige_level += 1
	day = 0
	money = 0
	reset_resource(Progress.ResourceType.ROCK)
	reset_resource(Progress.ResourceType.IRON)
	reset_resource(Progress.ResourceType.COPPER)
	reset_resource(Progress.ResourceType.SILVER)
	reset_resource(Progress.ResourceType.GOLD)
	reset_resource(Progress.ResourceType.PLATINUM)
	reset_upgrade(Progress.UpgradeType.SPEED)
	reset_upgrade(Progress.UpgradeType.ENERGY)
	reset_upgrade(Progress.UpgradeType.STRENGTH)
	reset_upgrade(Progress.UpgradeType.LUCK)
	reset_upgrade(Progress.UpgradeType.SPAWN)
	reset_upgrade(Progress.UpgradeType.PROFIT)
	inventory = {}
	add_resource(Progress.ResourceType.EMERALD, 1000)
	save_progress()

func reset_resource(res : Progress.ResourceType) -> void:
	add_resource(res, get_resource(res) * (-1))

func reset_upgrade(up : Progress.UpgradeType) -> void:
	upgrades[up] = 0

func get_prestige_level() -> int:
	return prestige_level


func get_amount_per_resource(res : ResourceType) -> int:
	return amount_per_resource[res]

func get_resource_value(res) -> int:
	return money_per_resource[res]


func get_upgrade_title(up : UpgradeType) -> String:
	match up:
		UpgradeType.SPEED:
			return "Speed"
		UpgradeType.ENERGY:
			return "Energy"
		UpgradeType.STRENGTH:
			return "Strength"
		UpgradeType.LUCK:
			return "Luck"
		UpgradeType.SPAWN:
			return "Spawn Rate"
		UpgradeType.PROFIT:
			return "Profit"
		_:
			var upgrade_name : String = UpgradeType.keys()[up]
			upgrade_name = upgrade_name.capitalize()
			upgrade_name = upgrade_name.replace("Prestige ", "")
			return upgrade_name

func get_upgrade_description(up : UpgradeType) -> String:
	match up:
		UpgradeType.SPEED:
			return "Worker's speed"
		UpgradeType.ENERGY:
			return "More energy before getting tired"
		UpgradeType.STRENGTH:
			return "More damage to blocks"
		UpgradeType.LUCK:
			return "+5% chance of double resources"
		UpgradeType.SPAWN:
			return "More resources on the map"
		UpgradeType.PROFIT:
			return "More money from selling"
		UpgradeType.PRESTIGE_STARTING_WORKERS:
			return "Permanently starts with
			+1 worker/level"
		UpgradeType.PRESTIGE_PICKAXE:
			return "Permanently starts with
			+1 strength/level"
		UpgradeType.PRESTIGE_EMERALDS:
			return "1% chance/level of finding
			emeralds (depth 100+)"
		UpgradeType.PRESTIGE_ARTIFACTS:
			return "20% chance/level of spawning
			an artifact (depth 200+)"
		UpgradeType.PRESTIGE_ARCHAEOLOGY:
			return "Permanently starts with
			+1 archearologist/level"
		UpgradeType.PRESTIGE_VISITOR:
			return "Visitors from another planet
			came to help you dig"
		_:
			return ""

func get_resource_chance() -> int:
	return 10 + get_upgrade(Progress.UpgradeType.SPAWN) * 4

func get_shop_item_title(it : InventoryItem) -> String:
	match it:
		InventoryItem.WORKER:
			return "Worker"
		InventoryItem.COFFEE:
			return "Coffee"
		InventoryItem.CLOVER:
			return "Clover"
		_:
			return "---------"

func get_shop_item_tooltip(it : InventoryItem) -> String:
	match it:
		InventoryItem.WORKER:
			return "Hire a new worker"
		InventoryItem.COFFEE:
			return "Refills the energy of 
			workers in the lower levels.
			-Available when all workers are tired
			-Once per day"
		InventoryItem.CLOVER:
			return "Significantly increases the chance 
			of getting more resources per hit.
			-Once per day"
		_:
			return "---------"

func get_item_cost(it : InventoryItem) -> int:
	match it:
		InventoryItem.WORKER:
			var current_workers : int = get_inventory(InventoryItem.WORKER)
			var new_value := floori(item_base_cost[it] + current_workers * item_base_cost[it] * (current_workers + 1))
			if current_workers > 10:
				new_value = new_value * current_workers -8
			return new_value
		InventoryItem.COFFEE:
			return item_base_cost[it]
		InventoryItem.CLOVER:
			return item_base_cost[it]
		_:
			var current_inventory : int = get_inventory(it)
			var new_value := floori(item_base_cost[it] + current_inventory * item_base_cost[it] * (current_inventory + 1))
			return new_value

func get_upgrade_cost(up: UpgradeType) -> Array[int]:
	var cost : Array[int] = [100, 0, 0, 0, 0, 0, 0]
	var level = get_upgrade(up)
	match up:
		UpgradeType.SPEED:
			cost = [100, 20, 0, 0, 0, 0]
		UpgradeType.ENERGY:
			cost = [50, 10, 0, 0, 0, 0, 0]
		UpgradeType.STRENGTH:
			cost = [150, 0, 10, 0, 0, 0, 0]
		UpgradeType.LUCK:
			cost = [0, 50, 20, 0, 0, 0, 0]
		UpgradeType.SPAWN:
			cost = [0, 0, 0, 100, 10, 0, 0]
		UpgradeType.PROFIT:
			cost = [0, 0, 0, 0, 50, 10, 0]
		UpgradeType.PROFIT:
			cost = [0, 0, 0, 0, 50, 10, 0]
		UpgradeType.PRESTIGE_STARTING_WORKERS:
			cost = [0, 0, 0, 0, 0, 0, 250]
		UpgradeType.PRESTIGE_PICKAXE:
			cost = [0, 0, 0, 0, 0, 0, 500]
		UpgradeType.PRESTIGE_EMERALDS:
			cost = [0, 0, 0, 0, 0, 0, 250]
		UpgradeType.PRESTIGE_ARTIFACTS:
			cost = [0, 0, 0, 0, 0, 0, 600]
		UpgradeType.PRESTIGE_VISITOR:
			cost = [0, 0, 0, 0, 0, 0, 400]
		UpgradeType.PRESTIGE_ARCHAEOLOGY:
			cost = [0, 0, 0, 0, 0, 0, 200]
		_:
			cost = [1, 0, 0, 0, 0, 0, 0]
	for i in cost.size():
		cost[i] = cost[i] + (cost[i] * level / 2)
	return cost

func can_afford_upgrade(up: UpgradeType) -> bool:
	var cost : Array[int] = get_upgrade_cost(up)
	for i : int in cost.size():
		var value : int = cost[i]
		if get_resource(i) < value:
			return false
	return true

func hard_reset() -> void:
	day = 0
	money = 0
	prestige_level = 0
	resources = {}
	upgrades = {}
	inventory = {}
	coffee_used = false
	clover_used = false


func debug_mode() -> void:
	add_money(1000000)
	add_resource(ResourceType.ROCK, 1000000)
	add_resource(ResourceType.IRON, 1000000)
	add_resource(ResourceType.COPPER, 1000000)
	add_resource(ResourceType.SILVER, 1000000)
	add_resource(ResourceType.GOLD, 1000000)
	add_resource(ResourceType.PLATINUM, 1000000)
