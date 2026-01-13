extends PanelContainer

@export var resource_type : Game.ResourceType
@onready var label_title: Label = $HBoxContainer/LabelTitle
@onready var label_value: Label = $HBoxContainer/LabelValue

func _ready() -> void:
	Game.resource_updated.connect(_on_resource_updated)
	label_title.text = Game.get_resource_title(resource_type) + ":"
	update_ui()

func _on_resource_updated(res : Game.ResourceType) -> void:
	if res == resource_type:
		update_ui()

func update_ui():
	var value : int = Game.progress.get_resource(resource_type)
	if value > 0:
		visible = true
		label_value.text = str(value)
	else:
		visible = false
