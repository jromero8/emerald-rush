extends PanelContainer

@export var up : Progress.UpgradeType

@onready var label_title: Label = $MarginContainer/VBoxContainer/LabelTitle
@onready var label_level: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LabelLevel
@onready var label_cost: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/LabelCost
@onready var label_description: Label = $MarginContainer/VBoxContainer/LabelDescription
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/TextureRect
@onready var button_upgrade: Button = $MarginContainer/VBoxContainer/ButtonUpgrade

func _ready() -> void:
	update_ui()
	Progress.resource_updated.connect(_on_resource_updated)
	

func _on_resource_updated(res : Progress.ResourceType) -> void:
	if res == Progress.ResourceType.EMERALD:
		update_ui()


func update_ui() -> void:
	label_title.text = Progress.get_upgrade_title(up)
	label_level.text = "Level:" + str(Progress.get_upgrade(up)) + "/" + str(Progress.get_max_upgrade(up))
	label_cost.text = "Cost:" + Progress.get_upgrade_cost_description(up)
	label_description.text = Progress.get_upgrade_description(up)
	button_upgrade.disabled = Progress.get_upgrade(up) > Progress.get_max_upgrade(up) or !Progress.can_afford_upgrade(up)
	texture_rect.texture.region = get_upgrade_region()

func get_upgrade_region() -> Rect2:
	var up_id : int = up - 6
	var y = floor(up_id / 3)
	var x : int = (up_id - y * 3)
	var result : Rect2 = Rect2(Vector2(x * 16, y * 16), Vector2(16, 16))
	return result


func _on_button_upgrade_pressed() -> void:
	Progress.buy_upgrade(up)
	update_ui()
