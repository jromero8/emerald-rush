extends PanelContainer

@export var upgrade_type : Progress.UpgradeType

@onready var label_title: Label = $VBoxContainer/LabelTitle
@onready var label_description: Label = $VBoxContainer/LabelDescription
@onready var label_cost: Label = $VBoxContainer/LabelCost
@onready var button_buy: Button = $VBoxContainer/ButtonBuy


func _ready() -> void:
	update_ui()
	Progress.upgrade_applied.connect(_on_upgrade_applied)
	Progress.resource_updated.connect(_on_resource_updated)


func _on_upgrade_applied(up : Progress.UpgradeType) -> void:
	if up == upgrade_type:
		update_ui()

func _on_resource_updated(res : Progress.ResourceType) -> void:
	update_ui()

func update_ui() -> void:
	label_title.text = Progress.get_upgrade_title(upgrade_type) + " (" + str(Progress.get_upgrade(upgrade_type)) + " / " + str(Progress.get_max_upgrade(upgrade_type)) + ")"
	label_description.text = Progress.get_upgrade_description(upgrade_type)
	label_cost.text = Progress.get_upgrade_cost_description(upgrade_type)
	button_buy.disabled = !Progress.can_afford_upgrade(upgrade_type)
	if Progress.is_max_upgrade(upgrade_type):
		button_buy.disabled = true
		button_buy.mouse_default_cursor_shape = Control.CURSOR_ARROW
		button_buy.modulate = Color.BLACK
		


func _on_button_buy_pressed() -> void:
	Progress.buy_upgrade(upgrade_type)
