extends PanelContainer

@onready var h_slider_music: HSlider = $MarginContainer/VBoxContainer/HBoxContainerMusic/HSliderMusic
@onready var h_slider_sound: HSlider = $MarginContainer/VBoxContainer/HBoxContainerSound/HSliderSound

func _ready() -> void:
	visible = false
	h_slider_music.set_value_no_signal(db_to_linear(Audio.get_music_volume()))
	h_slider_sound.set_value_no_signal(db_to_linear(Audio.get_sound_volume()))

func _on_h_slider_sound_value_changed(value: float) -> void:
	Audio.set_sound_volume(linear_to_db(value))
	Game.save_config()

func _on_h_slider_music_value_changed(value: float) -> void:
	Audio.set_music_volume(linear_to_db(value))
	Game.save_config()


func _on_button_close_pressed() -> void:
	visible = false
	
