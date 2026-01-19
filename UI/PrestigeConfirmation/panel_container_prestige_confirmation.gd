extends PanelContainer

func _ready() -> void:
	visible = false
	Game.prestige_requested.connect(_on_prestige_requested)

func _on_prestige_requested() -> void:
	visible = true

func _on_button_cancel_pressed() -> void:
	visible = false


func _on_button_prestige_pressed() -> void:
	Game.Prestige()
