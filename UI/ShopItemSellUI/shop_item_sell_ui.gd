extends HBoxContainer

@export var resource : Progress.ResourceType

@onready var label_title: Label = $LabelTitle
@onready var label_amount: Label = $LabelAmount
@onready var label_price: Label = $LabelPrice
@onready var buttonx_1: Button = $Buttonx1
@onready var buttonx_10: Button = $Buttonx10
@onready var button_all: Button = $ButtonAll

func _ready() -> void:
	Progress.resource_updated.connect(_on_resource_updated)

func _on_resource_updated(res : Progress.ResourceType) -> void:
	if res == resource:
		update_ui()

func update_ui() -> void:
	if label_title != null:
		label_title.text = Progress.get_resource_title(resource)
		label_price.text = "($" + str(Progress.get_resource_value(resource)) + ")"
		label_amount.text = str(Progress.get_resource(resource))
		buttonx_1.disabled = Progress.get_resource(resource) == 0
		buttonx_10.disabled = Progress.get_resource(resource) < 10
		button_all.disabled = Progress.get_resource(resource) == 0
	

func _on_buttonx_1_pressed() -> void:
	Progress.sell_resource(resource, 1)


func _on_buttonx_10_pressed() -> void:
	Progress.sell_resource(resource, 10)


func _on_button_all_pressed() -> void:
	Progress.sell_resource(resource, 999999999999999)


func _on_visibility_changed() -> void:
	if visible:
		update_ui()
