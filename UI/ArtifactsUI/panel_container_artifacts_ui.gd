extends PanelContainer

@onready var grid_container: GridContainer = $PanelContainerArt/MarginContainer/VBoxContainer/GridContainer

func _ready() -> void:
	visible = false
	Game.show_artifact_panel.connect(_on_show_artifact_panel)

func _on_show_artifact_panel(res : Progress.ResourceType) -> void:
	if res >= Progress.ResourceType.ARTIFACT_0:
		visible = true


func _on_button_close_pressed() -> void:
	visible = false
