extends CanvasLayer

@onready var h_box_container_day: HBoxContainer = $HBoxContainerDay
@onready var v_box_container_header: VBoxContainer = $VBoxContainerHeader
@onready var panel_container_tired: PanelContainer = $PanelContainerTired
@onready var panel_container_upgrades: PanelContainer = $PanelContainerUpgrades
@onready var panel_container_shop: PanelContainer = $PanelContainerShop
@onready var v_box_container_resources: VBoxContainer = $VBoxContainerHeader/HBoxContainerHEader/VBoxContainerResources
@onready var label_end_day: Label = $PanelContainerTired/MarginContainer/VBoxContainer/LabelEndDay
@onready var button_start_day: Button = $HBoxContainerDay/ButtonStartDay
@onready var button_end_day: Button = $HBoxContainerDay/ButtonEndDay
@onready var label_day: Label = $HBoxContainerDay/LabelDay
@onready var panel_container_game_over: PanelContainer = $PanelContainerGameOver
@onready var panel_container_maintitle: PanelContainer = $PanelContainerMaintitle
@onready var v_box_container_stats: VBoxContainer = $VBoxContainerRight/VBoxContainerStats
@onready var label_money_value: Label = $VBoxContainerRight/VBoxContainerStats/PanelContainerMoney/HBoxContainerMoney/LabelMoneyValue
@onready var label_workers: Label = $VBoxContainerRight/VBoxContainerStats/PanelContainer/HBoxContainer/LabelWorkers
@onready var label_depth: Label = $VBoxContainerRight/VBoxContainerStats/PanelContainerDepth/HBoxContainer/LabelDepth
@onready var button_continue: Button = $PanelContainerMaintitle/MarginContainer/VBoxContainer/ButtonContinue
@onready var panel_container_config: PanelContainer = $PanelContainerConfig
@onready var texture_button_config: TextureButton = $VBoxContainerRight/HBoxContainer/TextureButtonConfig

func _ready() -> void:
	Progress.money_updated.connect(_on_money_updated)
	Progress.inventory_updated.connect(_on_inventory_updated)
	button_continue.visible = Progress.day > 0
	hide_all_panels()
	if Game.game_state == Game.GameState.STARTED:
		panel_container_maintitle.visible = false
		v_box_container_header.visible = true
		h_box_container_day.visible = true
	else:
		panel_container_maintitle.visible = true
		v_box_container_header.visible = false
		h_box_container_day.visible = false
	refresh_money()
	refresh_workers()
	button_end_day.visible = false
	label_day.text = "Day " + str(Progress.day)
	if Game.game_state == Game.GameState.STARTED:
		button_start_day.visible = false
		await get_tree().create_timer(.1).timeout
		_on_button_start_day_pressed()
	texture_button_config.visible = Game.game_state == Game.GameState.STARTED

func _process(_delta: float) -> void:
	if Game.game_over:
		hide_all_panels()
		panel_container_game_over.visible = true
		v_box_container_stats.visible = false
	if Game.day_started:
		v_box_container_stats.visible = true
	label_depth.text = str(World.get_instance().get_depth())

func hide_all_panels() -> void:
	panel_container_tired.visible = false
	h_box_container_day.visible = false
	v_box_container_header.visible = false
	panel_container_shop.visible = false

func show_tired_panel() -> void:
	button_end_day.disabled = false
	if Game.day_ended:
		label_end_day.text = "Day Ended."
	panel_container_tired.visible = true


func _on_inventory_updated(it : Progress.InventoryItem) -> void:
	if it == Progress.InventoryItem.WORKER:
		refresh_workers()

func refresh_workers() -> void:
	label_workers.text = str(Progress.get_inventory(Progress.InventoryItem.WORKER) + 1)


func _on_money_updated() -> void:
	refresh_money()

func refresh_money() -> void:
	label_money_value.text = str(Progress.money)


func _on_button_restart_day_pressed() -> void:
	Game.load_next_day()


func _on_button_upgrades_pressed() -> void:
	panel_container_shop.visible = false
	panel_container_upgrades.visible = true

func _on_button_shop_pressed() -> void:
	panel_container_shop.visible = true
	panel_container_upgrades.visible = false

func _on_button_close_upgrades_pressed() -> void:
	panel_container_upgrades.visible = false


func _on_button_start_day_pressed() -> void:
	button_start_day.visible = false
	Game.day_started = true
	button_end_day.visible = true

func hide_all_windows() -> void:
	panel_container_tired.visible = false
	panel_container_upgrades.visible = false
	panel_container_shop.visible = false


func _on_button_end_day_pressed() -> void:
	Game.end_day()


func _on_button_continue_pressed() -> void:
	visible = false
	Game.game_state = Game.GameState.STARTED
	Game.load_next_day()

func _on_button_new_game_pressed() -> void:
	visible = false
	Game.game_state = Game.GameState.STARTED
	Progress.hard_reset()
	Game.load_next_day()


func _on_texture_button_pressed() -> void:
	panel_container_config.visible = !panel_container_config.visible


func _on_button_config_pressed() -> void:
	panel_container_config.visible = true
