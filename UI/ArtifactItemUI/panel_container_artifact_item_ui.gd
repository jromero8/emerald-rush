extends PanelContainer

@export var resource_type : Progress.ResourceType = Progress.ResourceType.ARTIFACT_0
@onready var label_artifact_title: Label = $VBoxContainer/LabelArtifactTitle
@onready var texture_button: TextureButton = $VBoxContainer/TextureButton

func _ready() -> void:
	Progress.resource_updated.connect(_on_resource_updated)
	refresh_ui()

func _on_resource_updated(res : Progress.ResourceType):
	if resource_type == res:
		refresh_ui()
	
func refresh_ui() -> void:
	label_artifact_title.text = "Missing"
	var atlas := texture_button.texture_normal as AtlasTexture
	var region : Rect2 = Rect2(Vector2(0, 208), Vector2(16, 16))
	if Progress.get_resource(resource_type) > 0:
		label_artifact_title.text = Progress.get_resource_title(resource_type)
		var art_index = resource_type - 7
		var art_x : int = art_index
		var art_y : int = 11
		if art_index > 5:
			art_x = art_x - 6
			art_y = 12
		region = Rect2(Vector2(16 * art_x, 16 * art_y), Vector2(16, 16))
	atlas.region = region


func _on_texture_button_pressed() -> void:
	if Progress.get_resource(resource_type) > 0:
		Game.artifact_show.emit(resource_type)
