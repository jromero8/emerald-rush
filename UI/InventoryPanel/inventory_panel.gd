extends PanelContainer

const INVENTORY_ITEM_UI = preload("uid://dx7t3yvmukqjk")
@onready var v_box_container_items: VBoxContainer = $VBoxContainerItems

func _ready() -> void:
	Progress.inventory_updated.connect(_on_inventory_change)
	for si : Progress.InventoryItem in Progress.InventoryItem.values():
		if si != Progress.InventoryItem.WORKER:
			var i = INVENTORY_ITEM_UI.instantiate()
			i.shop_item = si
			v_box_container_items.add_child(i)
	visible = !Progress.is_inventory_empty()

func _on_inventory_change(it : Progress.InventoryItem) -> void:
	if it != Progress.InventoryItem.WORKER:
		visible = !Progress.is_inventory_empty()
	
