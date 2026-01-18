extends PanelContainer

@onready var label_game_over: Label = $MarginContainer/VBoxContainer/LabelGameOver
@onready var label_thanks: Label = $MarginContainer/VBoxContainer/LabelThanks
@onready var timer_thanks: Timer = $TimerThanks
@onready var timer_play_again: Timer = $TimerPlayAgain
@onready var button_main_menu: Button = $MarginContainer/VBoxContainer/HBoxContainer/ButtonMainMenu

func _ready() -> void:
	label_thanks.visible = false
	button_main_menu.visible = false

func _on_visibility_changed() -> void:
	if visible and Game.game_over:
		label_game_over.text = "Congratulations! you found the emerald cave in " + str(Progress.day) + " days!"
		timer_thanks.start()
		timer_play_again.start()


func _on_timer_thanks_timeout() -> void:
	label_thanks.visible = true


func _on_timer_play_again_timeout() -> void:
	button_main_menu.visible = true


func _on_button_play_again_pressed() -> void:
	visible = false
	Game.game_state = Game.GameState.MAIN_MENU
	Game.new_game()


func _on_button_prestige_pressed() -> void:
	Game.Prestige()
