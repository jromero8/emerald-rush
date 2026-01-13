extends Node

signal resource_updated(res : ResourceType)
signal money_updated
signal upgrade_applied(up : UpgradeType)
signal inventory_updated(it : ShopItem)
signal workers_tired


enum ResourceType {
	ROCK,
	IRON,
	COPPER,
	SILVER,
	GOLD,
	CRYSTAL,
}

enum UpgradeType {
	SPEED,
	ENERGY,
	STRENGTH,
	LUCK,
	SPAWN,
	PROFIT,
}

enum ShopItem {
	WORKER,
	COFFEE,
	CLOVER,
}

const map_limit_left = -14
const map_limit_right = 15

const amount_per_resource = [
	3,
	6,
	8,
	12,
	15,
	20
]

const money_per_resource = [
	1,
	5,
	20,
	100,
	500,
	1000
]

const item_base_cost = [
	20,
	100,
	200,
]

var progress : Progress = null
var game_started := false
var day_started := false
var day_ended := false
var clover_active := 0
var coffee_used := false
var game_over = false

func _ready() -> void:
	reset_progress()
	Audio.play_music("boardwalk", -40)

func reset_progress() -> void:
	progress = Progress.new()
	Game.clover_active = 0
	Game.coffee_used = false

func load_next_day():
	Game.progress.day += 1
	Game.clover_active = 0
	Game.coffee_used = false
	Game.day_started = false
	Game.day_ended = false
	Game.game_over = false
	get_tree().reload_current_scene()

func add_resource(res : ResourceType, amount : int) -> void:
	progress.add_resource(res, amount)

func get_amount_per_resource(res : ResourceType) -> int:
	return amount_per_resource[res]

func get_resource_value(res) -> int:
	return money_per_resource[res]

func get_resource_title(rs : ResourceType) -> String:
	if rs == ResourceType.CRYSTAL:
		return "Platinum"
	else:
		var res_name : String = ResourceType.keys()[rs]
		return res_name.capitalize()

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
			return "---------"

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
		_:
			return "---------"

func get_resource_chance() -> int:
	return 10 + Game.progress.get_upgrade(Game.UpgradeType.SPAWN) * 4

func get_shop_item_title(it : ShopItem) -> String:
	match it:
		ShopItem.WORKER:
			return "Worker"
		ShopItem.COFFEE:
			return "Coffee"
		ShopItem.CLOVER:
			return "Clover"
		_:
			return "---------"

func get_shop_item_tooltip(it : ShopItem) -> String:
	match it:
		ShopItem.WORKER:
			return "Hire a new worker"
		ShopItem.COFFEE:
			return "Refills the energy of 
			workers in the lower levels.
			-Available when all workers are tired
			-Once per day"
		ShopItem.CLOVER:
			return "Significantly increases the chance 
			of getting more resources per hit.
			-Once per day"
		_:
			return "---------"

func get_item_cost(it : ShopItem) -> int:
	match it:
		ShopItem.WORKER:
			var current_workers : int = Game.progress.get_inventory(ShopItem.WORKER)
			var new_value := floori(item_base_cost[it] + current_workers * item_base_cost[it] * (current_workers + 1))
			if current_workers > 10:
				new_value = new_value * current_workers -8
			return new_value
		ShopItem.COFFEE:
			return item_base_cost[it]
		ShopItem.CLOVER:
			return item_base_cost[it]
		_:
			var current_inventory : int = Game.progress.get_inventory(it)
			var new_value := floori(item_base_cost[it] + current_inventory * item_base_cost[it] * (current_inventory + 1))
			return new_value
	return item_base_cost[it]

func get_upgrade_cost(up: UpgradeType) -> Array[int]:
	var cost : Array[int] = [100, 0, 0, 0, 0, 0]
	var level = progress.get_upgrade(up)
	match up:
		UpgradeType.SPEED:
			cost = [100, 20, 0, 0, 0, 0]
		UpgradeType.ENERGY:
			cost = [50, 10, 0, 0, 0, 0]
		UpgradeType.STRENGTH:
			cost = [150, 0, 10, 0, 0, 0]
		UpgradeType.LUCK:
			cost = [0, 50, 20, 0, 0, 0]
		UpgradeType.SPAWN:
			cost = [0, 0, 0, 100, 10, 0]
		UpgradeType.PROFIT:
			cost = [0, 0, 0, 0, 50, 10]
		_:
			cost = [10, 0, 0, 0, 0, 0]
	for i in cost.size():
		cost[i] = cost[i] + (cost[i] * level / 2)
	return cost

func can_afford_upgrade(up: UpgradeType) -> bool:
	var cost : Array[int] = get_upgrade_cost(up)
	for i : int in cost.size():
		var value : int = cost[i]
		if Game.progress.get_resource(i) < value:
			return false
	return true

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
	
func end_day() -> void:
	day_ended = true

func is_crystal_cave_floor(cell : Vector2i) -> bool:
	return cell == Vector2i(0, 6)

func start_game_over() -> void:
	if !game_over:
		game_over = true

func restart_game() -> void:
	game_started = false
	day_started = false
	game_over = false
	reset_progress()
	get_tree().reload_current_scene()
