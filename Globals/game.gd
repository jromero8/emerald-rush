extends Node

signal workers_tired

const map_limit_left = -14
const map_limit_right = 15

var game_started := false
var day_started := false
var day_ended := false
var game_over = false

func _ready() -> void:
	Audio.play_music("boardwalk", -40)


func load_next_day():
	Progress.next_day()
	Game.day_started = false
	Game.day_ended = false
	Game.game_over = false
	get_tree().reload_current_scene()

func end_day() -> void:
	day_ended = true

func is_crystal_cave_floor(cell : Vector2i) -> bool:
	return cell == Vector2i(0, 6)

func start_game_over() -> void:
	if !game_over:
		game_over = true

func new_game() -> void:
	game_started = false
	day_started = false
	game_over = false
	Progress.hard_reset()
	get_tree().reload_current_scene()

func Prestige() -> void:
	Progress.prestige()
	load_next_day()
