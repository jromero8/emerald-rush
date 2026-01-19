extends Node2D
class_name World

const WORKER = preload("uid://dfyu6vjpychsf")
const SPARK = preload("uid://deadn3cptb4is")

static var _instance : World

static func get_instance() -> World:
	return _instance

var resources = {}
var rng : RandomNumberGenerator
var occlusion_neighbors_8 := [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.DOWN + Vector2i.RIGHT
]
var ground_level = -1
var crystal_cave_pos : int = 1
	
@onready var main_ui: CanvasLayer = $MainUi
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var tile_map_layer_occlusion: TileMapLayer = $TileMapLayerOcclusion
@onready var camera_2d: Camera2D = $Camera2D
@onready var tile_map_layer_crystal_background: TileMapLayer = $TileMapLayerCrystalBackground

func _ready() -> void:
	_instance = self
	rng = RandomNumberGenerator.new()
	generate_map()
	create_workers()

func create_workers() -> void:
	var workers = 1 + Progress.get_inventory(Progress.InventoryItem.WORKER) + Progress.get_upgrade(Progress.UpgradeType.PRESTIGE_STARTING_WORKERS)
	for i : int in range(0, workers):
		var _sign = -1
		var offset = 0
		var pos = ceil(float(i) / 2) * 2
		if i % 2 == 0:
			_sign = 1
		if i > 10:
			offset = 0
			pos = pos - 11
		var x = offset + pos * _sign
		new_worker(Vector2i(x, ground_level), i)

func _process(_delta: float) -> void:
	update_camera_pos()

func new_worker(pos : Vector2i, index : int) -> void:
	var m : Worker = WORKER.instantiate()
	m.global_position = tile_map_layer.to_global(tile_map_layer.map_to_local(pos))
	m.ground = tile_map_layer
	add_child(m)

func is_chance_for_double() -> bool:
	var clover_mult = 1 if Progress.clover_used else 0
	var chance_for_double : int = clover_mult * 50 + Progress.get_upgrade(Progress.UpgradeType.LUCK) * 5
	chance_for_double = clampi(chance_for_double, 0, 100)
	return rng.randi_range(1, 100) <= chance_for_double


func mine(pos : Vector2i) -> bool:
	var is_double = false
	var resource_type = get_cell_resource_id(pos)
	if !resources.has(pos):
		resources[pos] = Progress.get_amount_per_resource(resource_type)
	var strength = Progress.get_upgrade(Progress.UpgradeType.STRENGTH) + 1
	strength += Progress.get_upgrade(Progress.UpgradeType.PRESTIGE_PICKAXE)
	var amount = resources[pos]
	var amount_to_mine = strength
	if amount < amount_to_mine:
		amount_to_mine = amount
	var double_mine_factor : int = 1
	if is_chance_for_double():
		double_mine_factor = 2
		is_double = true
	
	var amount_mined = amount_to_mine
	if amount - amount_to_mine <= 0:
		amount_mined = amount
		amount = 0
	else:
		amount -= amount_to_mine
	resources[pos] = amount
	Progress.add_resource(resource_type, amount_mined * double_mine_factor)
	if resource_type == Progress.ResourceType.ROCK:
		Audio.play_sound("mine")
	else:
		Audio.play_sound("mine_res")
	if amount == 0:
		tile_map_layer.set_cell(pos)
		occlude_neighbors(pos)
	return is_double

func generate_map() -> void:
	tile_map_layer.clear()
	crystal_cave_pos = 300 + 30 * Progress.get_prestige_level()
	for i in range(0, crystal_cave_pos):
		for j in range(-25, 25):
			var res_coords : Vector2i = get_resource_cell_id(Progress.ResourceType.ROCK, i)
			if rng.randi_range(1, 100) <= Progress.get_resource_chance():
				if i > 0:
					res_coords = get_resource_cell_id(Progress.ResourceType.IRON, i)
				if i > 20:
					if rng.randi_range(1, 100) < 20:
						res_coords = get_resource_cell_id(Progress.ResourceType.IRON, i)
					else:
						res_coords = get_resource_cell_id(Progress.ResourceType.COPPER, i)
				if i > 50:
					if rng.randi_range(1, 100) < 20:
						res_coords = get_resource_cell_id(Progress.ResourceType.COPPER, i)
					else:
						res_coords = get_resource_cell_id(Progress.ResourceType.SILVER, i)
				if i > 80:
					if rng.randi_range(1, 100) < 20:
						res_coords = get_resource_cell_id(Progress.ResourceType.SILVER, i)
					else:
						res_coords = get_resource_cell_id(Progress.ResourceType.GOLD, i)
				if i > 120:
					if rng.randi_range(1, 100) < 5:
						res_coords = get_resource_cell_id(Progress.ResourceType.COPPER, i)
					elif rng.randi_range(1, 100) < 20:
						res_coords = get_resource_cell_id(Progress.ResourceType.GOLD, i)
					else:
						res_coords = get_resource_cell_id(Progress.ResourceType.PLATINUM, i)
				if i > 100:
					if rng.randi_range(1, 100) <= Progress.get_upgrade(Progress.UpgradeType.PRESTIGE_EMERALDS):
						res_coords = get_resource_cell_id(Progress.ResourceType.EMERALD, i)
			tile_map_layer.set_cell(Vector2i(j, i), 0, res_coords)
	occlude_map()
	create_crystal_cave(crystal_cave_pos)

func occlude_map() -> void:
	for cell : Vector2i in tile_map_layer.get_used_cells():
		var atl = tile_map_layer.get_cell_atlas_coords(cell)
		var res_coords = get_resource_cell_id(Progress.ResourceType.EMERALD, 0)
		if res_coords != atl:
			occlude_cell(cell)

func occlude_neighbors(cell : Vector2i) -> void:
	for offset : Vector2i in occlusion_neighbors_8:
		var n := cell + offset
		occlude_cell(n)

func occlude_cell(cell : Vector2i) -> void:
		var hidden_cell = true
		for offset : Vector2i in occlusion_neighbors_8:
			var n := cell + offset
			if tile_map_layer.get_cell_source_id(n) == -1:
				hidden_cell = false
				break
		if hidden_cell:
			tile_map_layer_occlusion.set_cell(cell, 0, Vector2i(0, 3))
		else:
			tile_map_layer_occlusion.set_cell(cell)

func create_crystal_cave(crystal_cave_pos : int) -> void:
	var height = 15
	for i in range(crystal_cave_pos, crystal_cave_pos + height):
		if i == crystal_cave_pos + height - 1:
			tile_map_layer.set_cell(Vector2i(Game.map_limit_left - 3, i), 0, Vector2i(3, 6))
			for j in range(Game.map_limit_left -2, Game.map_limit_right + 2):
				tile_map_layer.set_cell(Vector2i(j, i), 0, Vector2i(0, 6))
			tile_map_layer.set_cell(Vector2i(Game.map_limit_right + 2, i), 0, Vector2i(4, 6))
		else:
			tile_map_layer.set_cell(Vector2i(Game.map_limit_left - 3, i), 0, Vector2i(1, 6))
			tile_map_layer.set_cell(Vector2i(Game.map_limit_right + 2, i), 0, Vector2i(2, 6))
			for j in range(Game.map_limit_left - 2, Game.map_limit_right + 2):
				if i == crystal_cave_pos + height - 2:
					tile_map_layer_crystal_background.set_cell(Vector2i(j, i), 0, Vector2i(rng.randi_range(0, 6), 8))
				else:
					if rng.randi_range(1, 10) <= 4:
						tile_map_layer_crystal_background.set_cell(Vector2i(j, i), 0, Vector2i(rng.randi_range(0, 6), 7))
					
	create_sparks()
	

func create_sparks() -> void:
	for c : Vector2i in tile_map_layer_crystal_background.get_used_cells():
		if rng.randi_range(0, 4) < 3:
			var s : Node2D = SPARK.instantiate()
			s.global_position = tile_map_layer_crystal_background.map_to_local(c)
			add_child(s)
			
	
func get_resource_cell_id(res : Progress.ResourceType, depth : int) -> Vector2i:
	match res:
		Progress.ResourceType.IRON:
			return Vector2i(0, 1)
		Progress.ResourceType.COPPER:
			return Vector2i(1, 1)
		Progress.ResourceType.SILVER:
			return Vector2i(2, 1)
		Progress.ResourceType.GOLD:
			return Vector2i(3, 1)
		Progress.ResourceType.PLATINUM:
			return Vector2i(4, 1)
		Progress.ResourceType.EMERALD:
			return Vector2i(5, 1)
		_:
			var x = min(depth / 5 + 1, 3)
			if depth == 0:
				x = 0
			return Vector2i(x, 0)

func update_camera_pos() -> void:
	var max_depth = camera_2d.global_position.y
	for c : Node in get_children():
		if c is Worker:
			if max_depth < c.global_position.y - 100:
				max_depth = c.global_position.y - 100
	camera_2d.global_position.y = max_depth


func is_resource(pos : Vector2i) -> bool:
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(pos)
	var resources_coords := [
		get_resource_cell_id(Progress.ResourceType.IRON, 0),
		get_resource_cell_id(Progress.ResourceType.COPPER, 0),
		get_resource_cell_id(Progress.ResourceType.SILVER, 0),
		get_resource_cell_id(Progress.ResourceType.GOLD, 0),
		get_resource_cell_id(Progress.ResourceType.PLATINUM, 0),
		get_resource_cell_id(Progress.ResourceType.EMERALD, 0),
	]
	return resources_coords.has(atlas_coords)


func get_cell_resource_id(pos : Vector2i) -> Progress.ResourceType:
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(pos)
	match atlas_coords:
		Vector2i(0, 1):
			return Progress.ResourceType.IRON
		Vector2i(1, 1):
			return Progress.ResourceType.COPPER
		Vector2i(2, 1):
			return Progress.ResourceType.SILVER
		Vector2i(3, 1):
			return Progress.ResourceType.GOLD
		Vector2i(4, 1):
			return Progress.ResourceType.PLATINUM
		Vector2i(5, 1):
			return Progress.ResourceType.EMERALD
		_:
			return Progress.ResourceType.ROCK

func are_all_workers_tired() -> bool:
	for c : Node in get_children():
		if c is Worker:
			if !c.is_tired():
				return false
	return true


func _on_timer_tired_timeout() -> void:
	if are_all_workers_tired() or Game.day_ended:
		main_ui.show_tired_panel()
		Game.workers_tired.emit()

func use_coffee() -> void:
	main_ui.hide_all_windows()
	var coffee_cups : int = Progress.get_inventory(Progress.InventoryItem.COFFEE)
	if coffee_cups > 0:
		for i : int in range(0, coffee_cups):
			var bottom_worker : Worker = null
			for w : Worker in get_tree().get_nodes_in_group("worker"):
				if w.is_tired():
					if bottom_worker == null:
						bottom_worker = w
					else:
						if w.global_position.y > bottom_worker.global_position.y:
							bottom_worker = w
			if bottom_worker != null:
				bottom_worker.refill_energy()
				Progress.add_inventory(Progress.InventoryItem.COFFEE, -1)
		Progress.coffee_used = true

func get_depth() -> int:
	var depth = 0
	for w : Worker in get_tree().get_nodes_in_group("worker"):
		var w_depth = ceili((w.global_position.y + 8) / 16)
		if w_depth > depth:
			depth = ceili(w_depth)
	return depth

func get_cave_pos() -> int:
	return crystal_cave_pos
