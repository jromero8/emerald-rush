extends HBoxContainer

@export var shop_item : Progress.InventoryItem
@export var hint_text : String
@onready var texture_rect: TextureRect = $TextureRect
@onready var label_text: Label = $LabelText
@onready var label_hint: Label = $LabelHint
@onready var label_cost: Label = $LabelCost
@onready var button_buy: Button = $ButtonBuy

func _ready() -> void:
	Progress.money_updated.connect(_on_money_change)
	Progress.inventory_updated.connect(_on_inventory_change)
	label_text.text = Progress.get_shop_item_title(shop_item)
	#label_hint.tooltip_text = Progress.get_shop_item_tooltip(shop_item)
	var atlas := texture_rect.texture as AtlasTexture
	
	atlas.region = Rect2(get_shop_item_region(), Vector2(16, 16))
	if shop_item == Progress.InventoryItem.WORKER:
		button_buy.text = "Hire"
	update_panel()

func get_shop_item_region() -> Vector2:
	match shop_item:
		Progress.InventoryItem.COFFEE:
			return Vector2(16, 0)
		Progress.InventoryItem.CLOVER:
			return Vector2(32, 0)
	return Vector2(0, 0)

func _on_money_change() -> void:
	update_panel()

func _on_inventory_change(it : Progress.InventoryItem) -> void:
	if it == shop_item:
		update_panel()

func update_panel() -> void:
	if Progress.is_max_inventory(shop_item):
		label_cost.text = "(MAX)"
	else:
		label_cost.text = "($" + str(Progress.get_item_cost(shop_item)) + ")"
	button_buy.disabled = !Progress.can_afford(shop_item) or Progress.is_max_inventory(shop_item)

func _on_button_buy_pressed() -> void:
	Progress.buy_inventory(shop_item)


func _on_label_hint_mouse_entered() -> void:
	Game.show_hint.emit(Progress.get_shop_item_tooltip(shop_item), global_position)


func _on_label_hint_mouse_exited() -> void:
	Game.hide_hint.emit()
