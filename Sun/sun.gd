extends Node2D

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var last_change : int = 0
@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(delta: float) -> void:
	if Time.get_ticks_msec() > last_change + 300:
		last_change = Time.get_ticks_msec()
		var new_id = rng.randi_range(0, 3)
		while sprite_2d.frame == new_id:
			new_id = rng.randi_range(0, 3)
		sprite_2d.frame = new_id
