extends PanelContainer

var artifact_type : Progress.ResourceType

@onready var label_artifact_name: Label = $PanelContainer/MarginContainer/VBoxContainer/LabelArtifactName
@onready var texture_rect_artifact: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/TextureRectArtifact
@onready var label_artifact_description: Label = $PanelContainer/MarginContainer/VBoxContainer/LabelArtifactDescription
@onready var label_new_artifact_found: Label = $PanelContainer/MarginContainer/VBoxContainer/LabelNewArtifactFound
@onready var button_show_artifacts: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ButtonShowArtifacts


func _ready() -> void:
	visible = false
	Game.artifact_found.connect(_on_artifact_found)
	Game.artifact_show.connect(_on_artifact_show)

func _on_artifact_show(res : Progress.ResourceType) -> void:
	label_new_artifact_found.visible = false
	button_show_artifacts.visible = false
	update_ui(res)

func _on_artifact_found(res : Progress.ResourceType) -> void:
	label_new_artifact_found.visible = true
	button_show_artifacts.visible = true
	update_ui(res)

func update_ui(res) -> void:
	artifact_type = res
	label_artifact_name.text = Progress.get_resource_title(res)
	var atlas_pos : Vector2 = Progress.get_artifact_atlas_coords(res, true) * 16
	texture_rect_artifact.texture.region = Rect2(atlas_pos, Vector2(16, 16))
	label_artifact_description.text = Progress.get_resource_description(res)
	visible = true

func _on_button_close_pressed() -> void:
	visible = false


func _on_button_show_artifacts_pressed() -> void:
	_on_button_close_pressed()
	Game.show_artifact_panel.emit(artifact_type)
