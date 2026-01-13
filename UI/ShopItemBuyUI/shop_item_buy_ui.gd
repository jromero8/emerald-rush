extends HBoxContainer

@export var shop_item : Game.ShopItem

@onready var texture_rect: TextureRect = $TextureRect
@onready var label_text: Label = $LabelText
@onready var label_hint: Label = $LabelHint
@onready var label_cost: Label = $LabelCost
@onready var button_buy: Button = $ButtonBuy

func _ready() -> void:
	Game.money_updated.connect(_on_money_change)
	Game.inventory_updated.connect(_on_inventory_change)
	label_text.text = Game.get_shop_item_title(shop_item)
	label_hint.tooltip_text = Game.get_shop_item_tooltip(shop_item)
	var atlas := texture_rect.texture as AtlasTexture
	
	atlas.region = Rect2(get_shop_item_region(), Vector2(16, 16))
	if shop_item == Game.ShopItem.WORKER:
		button_buy.text = "Hire"
	update_panel()

func get_shop_item_region() -> Vector2:
	match shop_item:
		Game.ShopItem.COFFEE:
			return Vector2(16, 0)
		Game.ShopItem.CLOVER:
			return Vector2(32, 0)
	return Vector2(0, 0)

func _on_money_change() -> void:
	update_panel()

func _on_inventory_change(it : Game.ShopItem) -> void:
	if it == shop_item:
		update_panel()

func update_panel() -> void:
	if Game.progress.is_max_inventory(shop_item):
		label_cost.text = "(MAX)"
	else:
		label_cost.text = "($" + str(Game.get_item_cost(shop_item)) + ")"
	button_buy.disabled = !Game.progress.can_afford(shop_item) or Game.progress.is_max_inventory(shop_item)

func _on_button_buy_pressed() -> void:
	Game.progress.buy_inventory(shop_item)
