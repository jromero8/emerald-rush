extends Node2D

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var from_time : float = 4
@export var to_time : float = 10

func _ready() -> void:
	start_next_timer()


func start_next_timer() -> void:
	timer.start(rng.randf_range(from_time, to_time))


func _on_timer_timeout() -> void:
	play_spark()
	start_next_timer()

func play_spark() -> void:
	if rng.randi_range(0, 1) == 0:
		animation_player.play("spark")
	else:
		animation_player.play("spark_2")
