extends Node2D

const BallScene := preload("res://objects/ball/ball.tscn")
const CubeScene := preload("res://objects/cube/cube.tscn")
const SpikeZoneScene := preload("res://objects/terrain/spike-zone.tscn")
const FinishZoneScene := preload("res://objects/terrain/finish-zone.tscn")

const Level1 := preload("res://levels/level-1.tscn")
const Level1_1 := preload("res://levels/level-1-1.tscn")
const Level2 := preload("res://levels/level-2.tscn")
const Level3 := preload("res://levels/level-3.tscn")
const Level4 := preload("res://levels/level-4.tscn")

var levels := {
	1: Level1,
	2: Level1_1,
	3: Level2,
	4: Level3,
	5: Level4,
}

@onready var camera := $Camera as GTrackingCamera
@onready var player_root := %PlayerRoot as Node2D
@onready var creatures_root := %CreaturesRoot as Node2D
@onready var blur_fx := %BlurFX as SxFxNodes.GaussianBlurOverlay
@onready var level_end_label := %LevelEndLabel as RichTextLabel
@onready var saved_creatures_label := %SavedCreaturesLabel as Label
@onready var time_label := %TimeLabel as Label
@onready var _saved_creatures_tpl := saved_creatures_label.text
@onready var _time_label_tpl := time_label.text

var terrain: GTerrain = null
var _started_at := 0
var _player: GBall = null
var _creatures_count := 0
var _creatures_saved := 0
var _finished := false

func spawn_ball(target: Vector2) -> void:
	var ball := BallScene.instantiate()
	ball.position = target
	creatures_root.add_child(ball)

	_creatures_count += 1

func spawn_player(target: Vector2) -> void:
	var ball := BallScene.instantiate()
	ball.position = target
	ball.player = true
	ball.input_enabled = true
	player_root.add_child(ball)

	_player = ball
	_player.level_finished.connect(func():
		_game_end()
	)
	_player.saved_creature.connect(func():
		_creatures_saved += 1
		_update_creatures_count()
	)
	_player.died.connect(func():
		get_tree().reload_current_scene()
	)
	camera.target = _player

func spawn_spikes(target: Vector2, angle: float) -> void:
	var spikes := SpikeZoneScene.instantiate()
	spikes.position = target
	spikes.rotation = angle
	creatures_root.add_child(spikes)

func spawn_finish(target: Vector2, angle: float) -> void:
	var finish := FinishZoneScene.instantiate()
	finish.position = target
	finish.rotation = angle
	creatures_root.add_child(finish)

func spawn_cube(target: Vector2) -> void:
	var cube := CubeScene.instantiate()
	cube.position = target
	creatures_root.add_child(cube)

func _game_end() -> void:
	GameData.fade_out()

	var ended_at := Time.get_ticks_msec()
	_finished = true

	# Gravitate balls
	var creature_tween := create_tween()
	for creature in creatures_root.get_children():
		if creature is GBall:
			if creature._saved:
				creature._gravitate_towards(_player)
				creature_tween.parallel().tween_property(creature.sprite, "scale", Vector2.ONE * 0.01, 0.5)

	# Compute msg
	var time := ended_at - _started_at
	var time_msg := "%2.2f" % (time / 1000.0)

	var new_text := level_end_label.text
	new_text = new_text.replace("{{ time }}", time_msg)
	new_text = new_text.replace("{{ creatures }}", str(_creatures_saved))
	level_end_label.text = new_text

	var tween := create_tween()
	tween.tween_property(blur_fx, "strength", 2.0, 0.5)
	tween.parallel().tween_property(level_end_label, "modulate", Color.WHITE, 0.5)
	await tween.finished

	_player.queue_free()
	await get_tree().create_timer(1.0).timeout

	if !levels.has(GameData.current_level + 1):
		SceneTransitioner.fade_to_scene(GameData.EndGameScreen)
	else:
		GameData.current_level += 1
		SceneTransitioner.fade_to_scene(GameData.GameScreen)

func _ready() -> void:
	terrain = levels[GameData.current_level].instantiate()
	add_child(terrain)
	move_child(terrain, 0)

	GameData.play_music()

	terrain.build_ball.connect(func(target):
		spawn_ball(target)
	)
	terrain.build_player.connect(func(target):
		spawn_player(target)
	)
	terrain.build_spikes.connect(func(target, angle):
		spawn_spikes(target, angle)
	)
	terrain.build_cube.connect(func(target):
		spawn_cube(target)
	)
	terrain.build_finish.connect(func(target, angle):
		spawn_finish(target, angle)
	)
	terrain.setup()

	var vp_size := get_viewport_rect().size
	var terrain_size := (terrain.get_used_rect().position + terrain.get_used_rect().size) * terrain.get_tile_size()
	var camera_lock_size := Vector2(max(terrain_size.x, vp_size.x), max(terrain_size.y, vp_size.y))
	camera.lock_inside_area(
		terrain.position,
		camera_lock_size
	)

	level_end_label.modulate = Color.TRANSPARENT

	_started_at = Time.get_ticks_msec()
	_update_creatures_count()

func _update_creatures_count() -> void:
	saved_creatures_label.text = _saved_creatures_tpl.replace("{{ saved }}", str(_creatures_saved)).replace("{{ total }}", str(_creatures_count))

func _process(_delta: float) -> void:
	# Update time
	if !_finished:
		var elapsed := Time.get_ticks_msec() - _started_at
		time_label.text = _time_label_tpl.replace("{{ time }}", "%2.2f" % (elapsed / 1000.0))

	# Send music updates to balls
	var vu_value := terrain.music_bg.get_vu_value(1)
	var can_jump = vu_value >= 0.5
	for creature in creatures_root.get_children():
		if creature is GBall:
			creature.can_jump_with_music = can_jump
		elif creature is GCube:
			creature.can_jump_with_music = can_jump

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.physical_keycode == KEY_ENTER:
			get_tree().reload_current_scene()
