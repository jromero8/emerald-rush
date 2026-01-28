extends Node

signal workers_tired
signal show_hint(hint_text : String)
signal hide_hint
signal show_prestige_upgrades
signal prestige_requested
signal artifact_found(res : Progress.ResourceType)
signal artifact_show(res : Progress.ResourceType)
signal show_artifact_panel(res : Progress.ResourceType)

enum GameState {
	MAIN_MENU,
	STARTED
}

const map_limit_left = -14
const map_limit_right = 15

var game_state : GameState = GameState.MAIN_MENU
var day_started := false
var day_ended := false
var game_over = false

func _ready() -> void:
	Audio.play_music("boardwalk", -20)
	load_config()

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
	game_state = GameState.STARTED
	day_started = false
	game_over = false
	Progress.hard_reset()
	get_tree().reload_current_scene()

func Prestige() -> void:
	Progress.prestige()
	load_next_day()

func load_config() -> void:
	var config : Dictionary = SaveGame.load_data("config")
	if config != null:
		for opt_id : StringName in config:
			match opt_id:
				"music_volume":
					Audio.set_music_volume(config.get(opt_id))
				"sound_volume":
					Audio.set_sound_volume(config.get(opt_id))


func save_config() -> void:
	var options : Dictionary[String, Variant]= {
		"music_volume" = Audio.get_music_volume(),
		"sound_volume" = Audio.get_sound_volume(),
	}
	SaveGame.save_data("config", options)
	
