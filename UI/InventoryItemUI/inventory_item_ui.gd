extends HBoxContainer

var shop_item : Progress.ShopItem = Progress.ShopItem.COFFEE

@onready var label_title: Label = $LabelTitle
@onready var label_value: Label = $LabelValue
@onready var button_use: Button = $ButtonUse

func _ready() -> void:
	Game.workers_tired.connect(_on_workers_tired)
	Progress.inventory_updated.connect(_on_inventory_change)
	update_ui()

func update_ui() -> void:
	var item_amount : int = Progress.get_inventory(shop_item)
	if item_amount > 0:
		visible = true
		label_title.text = Progress.get_shop_item_title(shop_item) + ":"
		label_title.tooltip_text = Progress.get_shop_item_tooltip(shop_item)
		label_value.text = str(item_amount)
		label_value.tooltip_text = Progress.get_shop_item_tooltip(shop_item)
	else:
		visible = false
	match shop_item:
		Progress.ShopItem.COFFEE:
			if !Game.day_started:
				button_use.disabled = true
			else:
				if Progress.coffee_used:
					button_use.disabled = true
				else:
					button_use.disabled = !World.get_instance().are_all_workers_tired()
		Progress.ShopItem.CLOVER:
			if Progress.clover_used:
				button_use.disabled = true
			else:
				if World.get_instance() != null:
					button_use.disabled = World.get_instance().are_all_workers_tired()

func _on_inventory_change(it : Progress.ShopItem) -> void:
	if it == shop_item:
		update_ui()

func _on_workers_tired() -> void:
		update_ui()

func _on_button_use_pressed() -> void:
	Progress.use_inventory_item(shop_item)
