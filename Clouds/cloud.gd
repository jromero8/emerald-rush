extends Node2D

enum CloudType {
	CLOUD_LARGE,
	CLOUD_SMALL_1,
	CLOUD_SMALL_2,
}

@export var speed : float = 10
@export var cloud_type : CloudType

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	cloud_type = rng.randi_range(0, 2) as CloudType
	
	match cloud_type:
		CloudType.CLOUD_LARGE:
			sprite_2d.hframes = 1 
			sprite_2d.vframes = 2
			sprite_2d.frame = 0
		CloudType.CLOUD_SMALL_1:
			sprite_2d.hframes = 2
			sprite_2d.vframes = 2
			sprite_2d.frame = 2
		CloudType.CLOUD_SMALL_2:
			sprite_2d.hframes = 2
			sprite_2d.vframes = 2
			sprite_2d.frame = 3
			
func _process(delta: float) -> void:
	global_position += Vector2.LEFT * speed * delta
	if global_position.x < -400:
		global_position.x = 400
