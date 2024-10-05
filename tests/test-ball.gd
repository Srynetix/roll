extends Node2D

const BallScene := preload("res://objects/ball/ball.tscn")
const SpikeZoneScene := preload("res://objects/terrain/spike-zone.tscn")

@onready var camera := $Camera as GTrackingCamera
@onready var terrain := $Terrain as GTerrain

var _player: GBall = null

func spawn_ball(target: Vector2) -> void:
	var ball := BallScene.instantiate()
	ball.position = target
	add_child(ball)

func spawn_player(target: Vector2) -> void:
	var ball := BallScene.instantiate()
	ball.position = target
	ball.player = true
	add_child(ball)

	_player = ball
	camera.target = _player

func spawn_spikes(target: Vector2) -> void:
	var spikes := SpikeZoneScene.instantiate()
	spikes.position = target
	add_child(spikes)

func _ready() -> void:
	terrain.build_ball.connect(func(target):
		spawn_ball(target)
	)
	terrain.build_player.connect(func(target):
		spawn_player(target)
	)
	terrain.build_spikes.connect(func(target):
		spawn_spikes(target)
	)
	terrain.setup()

	camera.lock_inside_area(
		terrain.position,
		terrain.get_used_rect().size * terrain.get_tile_size()
	)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.physical_keycode == KEY_ENTER:
			get_tree().reload_current_scene()
