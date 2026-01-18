extends PanelContainer

@onready var label_hint: Label = $LabelHint

func _ready() -> void:
	visible = false
	Game.show_hint.connect(_on_show_hint)
	Game.hide_hint.connect(_on_hide_hint)

func _process(delta: float) -> void:
	if visible:
		print("aa")
		global_position = get_global_mouse_position() - Vector2(size.x, 0)

func _on_show_hint(hint_text : String, gp : Vector2) -> void:
	label_hint.text = ""
	custom_minimum_size = Vector2.ZERO
	size = Vector2.ZERO
	label_hint.custom_minimum_size = Vector2.ZERO
	label_hint.text = hint_text
	global_position = get_global_mouse_position() - Vector2(size.x, 0)
	visible = true

func _on_hide_hint() -> void:
	visible = false

func _on_mouse_exited() -> void:
	visible = false
