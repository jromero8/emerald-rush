extends PanelContainer

@onready var label_game_over: Label = $MarginContainer/VBoxContainer/LabelGameOver
@onready var label_thanks: Label = $MarginContainer/VBoxContainer/LabelThanks
@onready var button_next_day: Button = $MarginContainer/VBoxContainer/HBoxContainer/ButtonNextDay
@onready var button_prestige: Button = $MarginContainer/VBoxContainer/HBoxContainer/ButtonPrestige
@onready var timer_buttons: Timer = $TimerButtons

func _ready() -> void:
	label_thanks.visible = false
	button_next_day.visible = false
	button_prestige.visible = false

func _on_visibility_changed() -> void:
	if visible and Game.game_over:
		label_game_over.text = "Congratulations! you found the emerald cave 
		in " + str(Progress.day) + " days!"
		timer_buttons.start()


func _on_button_play_again_pressed() -> void:
	Game.load_next_day()


func _on_button_prestige_pressed() -> void:
	Game.prestige_requested.emit()


func _on_timer_buttons_timeout() -> void:
	button_next_day.visible = true
	button_prestige.visible = true
