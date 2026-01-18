extends PanelContainer

@export var resource_type : Progress.ResourceType
@onready var label_title: Label = $HBoxContainer/LabelTitle
@onready var label_value: Label = $HBoxContainer/LabelValue
@onready var button_prestige: Button = $HBoxContainer/ButtonPrestige

func _ready() -> void:
	Progress.resource_updated.connect(_on_resource_updated)
	label_title.text = Progress.get_resource_title(resource_type) + ":"
	update_ui()

func _on_resource_updated(res : Progress.ResourceType) -> void:
	if res == resource_type:
		update_ui()

func update_ui():
	var value : int = Progress.get_resource(resource_type)
	if value > 0:
		visible = true
		label_value.text = str(value)
	else:
		visible = false
	button_prestige.visible = resource_type == Progress.ResourceType.EMERALD


func _on_button_prestige_pressed() -> void:
	Game.show_prestige_upgrades.emit()
