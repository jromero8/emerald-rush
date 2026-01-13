extends Node2D

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_timer_timeout() -> void:
	play_spark()
	timer.start(rng.randf_range(4, 10))

func play_spark() -> void:
	if rng.randi_range(0, 1) == 0:
		animation_player.play("spark")
	else:
		animation_player.play("spark_2")
