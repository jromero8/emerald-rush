extends PanelContainer

@onready var label_game_over: Label = $MarginContainer/VBoxContainer/LabelGameOver
@onready var label_thanks: Label = $MarginContainer/VBoxContainer/LabelThanks
@onready var button_play_again: Button = $MarginContainer/VBoxContainer/ButtonPlayAgain
@onready var timer_thanks: Timer = $TimerThanks
@onready var timer_play_again: Timer = $TimerPlayAgain

func _ready() -> void:
	label_thanks.visible = false
	button_play_again.visible = false

func _on_visibility_changed() -> void:
	if visible and Game.game_over:
		if Game.progress != null:
			label_game_over.text = "Congratulations! you found the emerald cave in " + str(Game.progress.day) + " days!"
		timer_thanks.start()
		timer_play_again.start()


func _on_timer_thanks_timeout() -> void:
	label_thanks.visible = true


func _on_timer_play_again_timeout() -> void:
	button_play_again.visible = true


func _on_button_play_again_pressed() -> void:
	visible = false
	Game.game_started = false
	Game.restart_game()
