extends PanelContainer

const INVENTORY_ITEM_UI = preload("uid://dx7t3yvmukqjk")
@onready var v_box_container_items: VBoxContainer = $VBoxContainerItems

func _ready() -> void:
	Game.inventory_updated.connect(_on_inventory_change)
	for si : Game.ShopItem in Game.ShopItem.values():
		if si != Game.ShopItem.WORKER:
			var i = INVENTORY_ITEM_UI.instantiate()
			i.shop_item = si
			v_box_container_items.add_child(i)
	visible = !Game.progress.is_inventory_empty()

func _on_inventory_change(it : Game.ShopItem) -> void:
	if it != Game.ShopItem.WORKER:
		visible = !Game.progress.is_inventory_empty()
	
