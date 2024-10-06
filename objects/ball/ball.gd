extends RigidBody2D
class_name GBall

const ProjectSettingsExt := preload("res://utils/project-settings.gd")
const BallGrayscaleMaterial := preload("res://objects/ball/ball-grayscale-material.tres")
const BallOutlineMaterial := preload("res://objects/ball/ball-material.tres")

signal died()
signal saved_creature()
signal level_finished()

var absorbed_balls := 0

var absorbing: bool :
	get:
		return _absorbing
	set(value):
		set_absorbing(value)

@export var player := false
@export var jump_speed := 300.0
@export var movement_speed := 1000.0
@export var size_increase := 0.5
@export var input_enabled := false
@export var can_jump_with_music := false

@onready var sprite := $Sprite2D as AnimatedSprite2D
@onready var _sprite_overlay := $SpriteOverlay as Sprite2D
@onready var shape := $CollisionShape as CollisionShape2D
@onready var _absorb_fx := $AbsorbFX as GPUParticles2D
@onready var _bottom := %Bottom as Area2D
@onready var _bottom_rotation := $BottomRotation as Node2D
@onready var _absorb_sfx := $AbsorbSFX as AudioStreamPlayer
@onready var _absorb_one_sfx := $AbsorbOneSFX as AudioStreamPlayer
@onready var _absorber := $Absorber as Area2D
@onready var _jump_sfx := $JumpSFX as AudioStreamPlayer2D
@onready var _jump_fx := %JumpFX as GPUParticles2D
@onready var _arrow := %Arrow as AnimatedSprite2D
@onready var _nope_sfx := %NopeSFX as AudioStreamPlayer

@onready var _absorber_shape := _absorber.get_node("CollisionShape") as CollisionShape2D
@onready var _absorber_shape_shape := _absorber_shape.shape as CircleShape2D
@onready var _shape_shape := shape.shape as CircleShape2D
@onready var _hitbox := $HitBox as Area2D
@onready var _hitbox_shape := _hitbox.get_node("CollisionShape") as CollisionShape2D
@onready var _hitbox_shape_shape := _hitbox_shape.shape as CircleShape2D

@onready var _initial_shape_size := _shape_shape.radius
@onready var _initial_texture_size := sprite.scale
@onready var _initial_absorber_size := _absorber_shape_shape.radius
@onready var _initial_hitbox_size := _hitbox_shape_shape.radius
@onready var _initial_position := position

var _eject_direction := Vector2.ZERO
var _previous_linear_velocity := Vector2.ZERO

var input_movement := Vector2.ZERO
var input_absorb := false
var input_eject := false

var _saved := false
var _finish := false
var _absorbing := false
var absorbing_node: Node2D = null
var absorbed := false
var balls: Array[GBall] = []

var _jumping := false
var _on_ground := false
var _dying := false

func _ready() -> void:
	# Read custom overlay for player
	if player:
		var overlay_file := FileAccess.open("user://custom-texture.bin", FileAccess.READ)
		if overlay_file:
			var buf_len = overlay_file.get_64()
			var buf = overlay_file.get_buffer(buf_len)
			var base_tex := sprite.sprite_frames.get_frame_texture("default", 0)
			var base_img := base_tex.get_image()
			var img := Image.create_empty(32, 32, false, base_img.get_format())
			img.load_png_from_buffer(buf)
			var tex := ImageTexture.create_from_image(img)
			_sprite_overlay.texture = tex

		sprite.material = BallOutlineMaterial

		# Change physics layer
		var ball_layer := ProjectSettingsExt.get_2d_physics_layer_by_name("ball")
		var player_layer := ProjectSettingsExt.get_2d_physics_layer_by_name("player")

		set_collision_layer_value(player_layer, true)
		set_collision_layer_value(ball_layer, false)
		set_collision_mask_value(ball_layer, false)

	else:
		sprite.material = BallGrayscaleMaterial.duplicate()
		var shader_mat := sprite.material as ShaderMaterial
		shader_mat.set_shader_parameter("ratio", 1.0)
		_absorber_shape.disabled = true
		_arrow.visible = false
		jump_speed /= 1.5

	_absorber.body_entered.connect(func(body):
		if _dying:
			return

		if absorbing and body is GBall and !body.absorbed and body != self:
			_absorb(body)

		if absorbing and body is GCube and !body._changing:
			body.inflated = !body.inflated
	)

	_bottom.body_entered.connect(func(body):
		if body != self && body is TileMapLayer || body is GCube:
			_on_ground = true
	)

	_bottom.body_exited.connect(func(_body):
		for body in _bottom.get_overlapping_bodies():
			if body != self:
				return

		_on_ground = false
	)

	_hitbox.area_entered.connect(func(body):
		if _dying:
			return

		if player:
			# Detect finish
			if !_finish && body is GFinishZone:
				_finish = true
				body.play_success()
				call_deferred("_finish_level", body.position)

		if !absorbed:
			if body is GSpikeZone:
				_hurt(body.global_position)
	)

	if player:
		# Show overlay
		var sprite_material := sprite.material as ShaderMaterial
		sprite_material.set_shader_parameter("line_scale", 1.0)

func set_absorbing(value: bool) -> void:
	_absorbing = value
	if is_inside_tree():
		_absorb_fx.emitting = value
		if _absorb_sfx.playing != _absorbing:
			_absorb_sfx.playing = _absorbing

		if _absorbing:
			# Detect already overlapping bodies
			for body in _absorber.get_overlapping_bodies():
				if body is GBall and body != self and !body.absorbed:
					_absorb(body)

				if body is GCube and !body._changing:
					body.inflated = !body.inflated

func _finish_level(target: Vector2) -> void:
	if absorbed_balls > 0:
		_unpack()

	sleeping = true
	shape.disabled = true
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO

	var tween = create_tween()
	tween.tween_property(self, "self_modulate", SxCore.ColorExt.with_alpha_f(Color.YELLOW, 0.0), 0.5)
	tween.parallel().tween_property(self, "position", target, 0.5)
	tween.parallel().tween_property(sprite, "scale", Vector2(0.01, 0.01), 0.5)
	tween.parallel().tween_property(_sprite_overlay, "scale", Vector2(0.01, 0.01), 0.5)
	await tween.finished

	level_finished.emit()

func _gravitate_towards(node: Node2D):
	shape.set_deferred("disabled", true)
	set_deferred("sleeping", true)
	gravity_scale = 0.0
	absorbed = true
	linear_velocity = Vector2.ZERO
	absorbing_node = node

func _absorb(body: GBall) -> void:
	if !body._saved:
		saved_creature.emit()
		body._save()

	body._gravitate_towards(self)

	absorbed_balls += 1
	_update_ball_size()
	balls.push_back(body)

	_absorb_one_sfx.pitch_scale = 1.0 + (absorbed_balls / 10.0)
	_absorb_one_sfx.playing = true

func _update_ball_size() -> void:
	sprite.scale = _initial_texture_size + Vector2.ONE * (absorbed_balls * size_increase * _initial_texture_size)
	_sprite_overlay.scale = sprite.scale
	_shape_shape.radius = _initial_shape_size + (absorbed_balls * size_increase * _initial_shape_size)
	_absorb_fx.scale = Vector2.ONE + (absorbed_balls * size_increase * Vector2.ONE)
	_bottom.position = Vector2(0, _shape_shape.radius)
	_absorber_shape_shape.radius = _initial_absorber_size + (absorbed_balls * size_increase * _initial_absorber_size)
	_hitbox_shape_shape.radius = _initial_hitbox_size + (absorbed_balls * size_increase * _initial_hitbox_size)

func _physics_process(delta: float) -> void:
	if _dying:
		return

	if _on_ground:
		_jumping = false

	# Handle movements
	if input_enabled:
		input_movement.x = Input.get_axis("move_left", "move_right")
		input_movement.y = Input.get_axis("move_up", "move_down")
		input_absorb = Input.is_action_pressed("absorb")
		input_eject = Input.is_action_just_pressed("eject")

	if input_movement.x < 0 || input_movement.x > 0:
		linear_velocity += Vector2(movement_speed * delta * input_movement.x, 0)

	if input_movement.y < 0 && _on_ground && !_jumping:
		_jump()

	absorbing = input_absorb
	if input_eject:
		_unpack()

	if !player:
		if !absorbed && _on_ground && can_jump_with_music && _saved:
			# Jump, jump!
			linear_velocity.x += randf_range(-movement_speed * delta, movement_speed * delta)
			_jump()

		if absorbed:
			if is_instance_valid(absorbing_node):
				var diff = (absorbing_node.position - position)
				var direction = diff.normalized()
				var distance_sqr = diff.length()
				linear_velocity = (direction * distance_sqr) * 10.0
			else:
				absorbing_node = null
				linear_velocity = Vector2.ZERO

	_eject_direction.y = input_movement.y
	_eject_direction.x = lerp(_eject_direction.x, input_movement.x, 0.1)

	_previous_linear_velocity = linear_velocity

func _jump() -> void:
	_jumping = true
	linear_velocity.y = -jump_speed
	_jump_sfx.pitch_scale = randf_range(0.95, 1.05)
	_jump_sfx.volume_db = linear_to_db(randf_range(0.7, 0.9))
	if !_jump_sfx.playing:
		_jump_sfx.playing = true

	_jump_fx.restart()
	_jump_fx.emitting = true

func _hurt(target: Vector2) -> void:
	if absorbed_balls > 0:
		call_deferred("_unpack")
		return

	if player:
		_nope_sfx.play()

	_dying = true
	apply_central_impulse((global_position - target) * 10.0)
	gravity_scale = 0.0
	var tween := create_tween()
	tween.tween_property(sprite, "self_modulate", SxCore.ColorExt.with_alpha_f(Color.RED, 0.0), 0.5).from(Color.RED)
	tween.tween_callback(func():
		_reset()
	)
	await tween.finished

	died.emit()

func _reset() -> void:
	sprite.self_modulate = Color.WHITE

	_dying = false
	position = _initial_position
	gravity_scale = 1.0
	linear_velocity = Vector2.ZERO

func _save() -> void:
	_saved = true

	var shader_mat := sprite.material as ShaderMaterial
	shader_mat.set_shader_parameter("ratio", 0.0)

func _process(_delta: float) -> void:
	_absorb_fx.rotation = -rotation
	_bottom_rotation.rotation = -rotation

	if player:
		_arrow.position = (Vector2.RIGHT * _shape_shape.radius * 2).rotated(_eject_direction.angle() - rotation)
		_arrow.rotation = _eject_direction.angle() - rotation

func _unpack() -> void:
	input_eject = false
	if absorbed_balls == 0:
		return

	var initial_rotation := PI + PI / 4
	var offset := (PI / 2) / absorbed_balls
	var cursor := 0

	if absorbed_balls == 1:
		initial_rotation = PI + PI / 2

	for ball in balls:
		ball.linear_velocity = (Vector2.RIGHT * 10).rotated(initial_rotation + offset * cursor) * Vector2(1, -1)
		ball.gravity_scale = 1.0
		ball.shape.disabled = false
		ball.sleeping = false
		ball.absorbed = false
		ball.absorbing_node = null
		ball.add_collision_exception_with(self)
		cursor += 1

	balls.clear()

	# Throw in current movement direction
	var direction = input_movement.normalized()
	linear_velocity = direction * jump_speed * absorbed_balls * 1.25
	absorbed_balls = 0

	_absorb_one_sfx.pitch_scale = 0.5
	_absorb_one_sfx.playing = true

	_update_ball_size()
