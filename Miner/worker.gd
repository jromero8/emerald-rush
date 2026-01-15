extends Node2D
class_name Worker

enum WorkerState {
	IDLE,
	WALKING,
	MINING,
	FALLING,
	TIRED,
	WAITING,
}

var ground : TileMapLayer
var target : Vector2i = Vector2i.DOWN
var state : WorkerState  = WorkerState.IDLE
var fall_speed : float = 60
var walk_speed : float = 20
var walking_direction : Vector2i = Vector2i.ZERO

var mine_cooldown : int = 500
var last_mine : int = 0
var base_energy : int = 20
var initial_energy : int = 0
var energy : int = 0
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d_progress: Sprite2D = $Sprite2DProgress
@onready var animation_playerx_2: AnimationPlayer = $AnimationPlayerx2

func _ready() -> void:
	energy = base_energy + Game.progress.get_upgrade(Game.UpgradeType.ENERGY) * 15
	initial_energy = energy
	fall_speed = fall_speed + Game.progress.get_upgrade(Game.UpgradeType.SPEED) * 6
	walk_speed = walk_speed + Game.progress.get_upgrade(Game.UpgradeType.SPEED) * 10
	mine_cooldown = 500 - Game.progress.get_upgrade(Game.UpgradeType.SPEED) * 40
	sprite_2d.flip_h = rng.randi_range(0, 1) == 0

func _physics_process(delta: float) -> void:
	if energy <= 0 or Game.day_ended:
		state = WorkerState.TIRED

	if ground.get_cell_source_id(get_current_tile() + Vector2i.DOWN) < 0 and state != WorkerState.WALKING:
		state = WorkerState.FALLING
	else:
		if (global_position - ground.map_to_local(get_current_tile())).length() > 0.1 and state != WorkerState.WALKING:
			state = WorkerState.FALLING
	
	if (!Game.day_started or is_far_ahead()) and state != WorkerState.FALLING:
		state = WorkerState.WAITING
	
	if Game.is_crystal_cave_floor(ground.get_cell_atlas_coords(get_current_tile() + Vector2i.DOWN)) and state != WorkerState.FALLING:
		state = WorkerState.WAITING
		Game.start_game_over()

	match state:
		WorkerState.TIRED:
			play_animation("tired")
		WorkerState.IDLE:
			if !walk_sideways():
				search_next_target()
			play_animation("idle")
		WorkerState.MINING:
			if ground.get_cell_source_id(get_current_tile() + target) < 0:
				state = WorkerState.IDLE
			else:
				if Time.get_ticks_msec() > mine_cooldown + last_mine:
					last_mine = Time.get_ticks_msec()
					if target == Vector2i.LEFT:
						play_animation("mine_left")
					elif target == Vector2i.RIGHT:
						play_animation("mine_right")
					else:
						play_animation("mine")
		WorkerState.FALLING:
			play_animation("fall")
			if ground.get_cell_source_id(get_current_tile() + Vector2i.DOWN) < 0:
				global_position = global_position.move_toward(ground.map_to_local(get_current_tile() + Vector2i.DOWN), fall_speed * delta)
			else:
				global_position = global_position.move_toward(ground.map_to_local(get_current_tile()), fall_speed * delta)
				if (global_position - ground.map_to_local(get_current_tile())).length() < 0.1:
					global_position - ground.map_to_local(get_current_tile())
					state = WorkerState.IDLE
		WorkerState.WALKING:
			if target == Vector2i.LEFT:
				play_animation("walk_left")
			else:
				play_animation("walk_right")
			if ground.get_cell_source_id(get_current_tile() + target) < 0:
				global_position = global_position.move_toward(ground.map_to_local(get_current_tile() + target), walk_speed * delta)
			else:
				global_position = global_position.move_toward(ground.map_to_local(get_current_tile()), walk_speed * delta)
			if (global_position - ground.map_to_local(get_current_tile())).length() < 0.1:
				global_position - ground.map_to_local(get_current_tile())
				state = WorkerState.IDLE
				target = Vector2i.ZERO
		WorkerState.WAITING:
			play_animation("tired")
			state = WorkerState.IDLE


func mine() -> void:
	if World.get_instance().mine(get_current_tile() + target):
		animation_playerx_2.play("x2")
	energy -= 1
	update_energy_bar()

func update_energy_bar() -> void:
	var perc : float = (float(energy) / float(initial_energy)) * 10
	perc = ceili(clamp(perc, 0, 10))
	sprite_2d_progress.frame = perc


func get_current_tile() -> Vector2i:
	return ground.local_to_map(global_position)


func search_next_target() -> void:
	if ground.get_cell_source_id(get_current_tile() + Vector2i.DOWN) >= 0:
		target = Vector2i.DOWN
		if first_check_left():
			if World.get_instance().is_resource(get_current_tile() + Vector2i.LEFT):
				target = Vector2i.LEFT
			if World.get_instance().is_resource(get_current_tile() + Vector2i.RIGHT):
				target = Vector2i.RIGHT
		else:
			if World.get_instance().is_resource(get_current_tile() + Vector2i.RIGHT):
				target = Vector2i.RIGHT
			if World.get_instance().is_resource(get_current_tile() + Vector2i.LEFT):
				target = Vector2i.LEFT
		state = WorkerState.MINING

func first_check_left() -> bool:
	return rng.randi_range(0, 1) == 0

func walk_sideways() -> bool:
	if get_current_tile().x < Game.map_limit_left or get_current_tile().x > Game.map_limit_right:
		return false
	if rng.randi_range(0, 1) == 1:
		return false
	if get_current_tile().y > 2:
		if ground.get_cell_source_id(get_current_tile() + Vector2i.DOWN) >= 0:
			if state == WorkerState.IDLE:
				if target != Vector2i.ZERO:
					if first_check_left():
						if ground.get_cell_source_id(get_current_tile() + Vector2i.LEFT) < 0:
							target = Vector2i.LEFT
							state = WorkerState.WALKING
							return true
						elif ground.get_cell_source_id(get_current_tile() + Vector2i.RIGHT) < 0:
							target = Vector2i.RIGHT
							state = WorkerState.WALKING
							return true
					else:
						if ground.get_cell_source_id(get_current_tile() + Vector2i.RIGHT) < 0:
							target = Vector2i.RIGHT
							state = WorkerState.WALKING
							return true
						elif ground.get_cell_source_id(get_current_tile() + Vector2i.LEFT) < 0:
							target = Vector2i.LEFT
							state = WorkerState.WALKING
							return true
	return false
	

func play_animation(animation_name : String) -> void:
	var a = animation_name
	if a == "mine" or a == "mine_left" or a == "mine_right" or a == "walk_left" or a == "walk_right":
		animation_player.speed_scale = 1 + Game.progress.get_upgrade(Game.UpgradeType.SPEED) * 0.2
	else:
		animation_player.speed_scale = 1
	animation_player.play(animation_name)
	

func is_tired() -> bool:
	return energy <= 0
	#return state == WorkerState.TIRED

func refill_energy() -> void:
	energy = initial_energy
	state = WorkerState.IDLE

func is_far_ahead() -> bool:
	for w : Worker in get_tree().get_nodes_in_group("worker"):
		if !w.is_tired():
			if global_position.y > w.global_position.y and global_position.y - w.global_position.y > 200:
				return true
	return false
