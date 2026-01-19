extends PanelContainer

func _ready() -> void:
	#visible = false
	Game.show_prestige_upgrades.connect(_on_show_prestige_upgrades)

func _on_show_prestige_upgrades() -> void:
	visible = true

func _on_button_close_pressed() -> void:
	visible = false
