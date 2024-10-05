extends RigidBody2D
class_name GBall

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

var _absorbing := false
var absorbing_ball: GBall = null
var absorbed := false
var balls: Array[GBall] = []
var _tracer: SxDebugNodes.NodeTracer

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

	_tracer = SxDebugNodes.NodeTracer.new()
	add_child(_tracer)

	_absorber.body_entered.connect(func(body):
		if _dying:
			return

		if absorbing and body is GBall and !body.absorbed and body != self:
			_absorb(body)
	)

	_bottom.body_entered.connect(func(body):
		if body != self:
			_on_ground = true
	)

	_bottom.body_exited.connect(func(body):
		if body != self:
			_on_ground = false
	)

	_hitbox.area_entered.connect(func(body):
		if !absorbed && !_dying:
			if body is GSpikeZone:
				_hurt(body.global_position)
	)

	if player:
		# Show overlay
		var sprite_material := sprite.material as ShaderMaterial
		sprite_material.set_shader_parameter("line_scale", 1.0)
		sprite.self_modulate = Color.from_string("#d100ff", Color.WHITE)

func set_absorbing(value: bool) -> void:
	_absorbing = value
	if is_inside_tree():
		_absorb_fx.emitting = value
		if _absorb_sfx.playing != _absorbing:
			_absorb_sfx.playing = _absorbing

func _absorb(body: GBall) -> void:
	body.shape.set_deferred("disabled", true)
	body.set_deferred("sleeping", true)
	body.gravity_scale = 0.0
	body.absorbed = true
	body.absorbing_ball = self

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

	# Move
	if player:
		if Input.is_action_pressed("move_left"):
			linear_velocity += Vector2(-movement_speed * delta, 0)

		elif Input.is_action_pressed("move_right"):
			linear_velocity += Vector2(movement_speed * delta, 0)

		if Input.is_action_just_pressed("jump") && _on_ground && !_jumping:
			_jump()

		if Input.is_action_pressed("absorb"):
			absorbing = true
		else:
			absorbing = false

		if Input.is_action_just_pressed("eject"):
			_unpack()

	else:
		if !absorbed && _on_ground && randi_range(0, 10) == 10:
			# Jump, jump!
			linear_velocity.x += randf_range(-movement_speed * delta, movement_speed * delta)
			_jump()

		if absorbed:
			linear_velocity = (absorbing_ball.position - position) * 10.0
			if (absorbing_ball.position - position).length_squared() < 1:
				visible = false

	_tracer.trace_parameter("on_ground", _on_ground)

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

	_dying = true
	apply_central_impulse((global_position - target) * 10.0)
	gravity_scale = 0.0
	var tween := create_tween()
	tween.tween_property(sprite, "self_modulate", SxCore.ColorExt.with_alpha_f(Color.RED, 0.0), 0.5).from(Color.RED)
	tween.tween_callback(func():
		_reset()
	)
	await tween.finished

func _reset() -> void:
	if player:
		sprite.self_modulate = Color.from_string("#d100ff", Color.WHITE)
	else:
		sprite.self_modulate = Color.WHITE

	_dying = false
	position = _initial_position
	gravity_scale = 1.0
	linear_velocity = Vector2.ZERO

func _process(_delta: float) -> void:
	_absorb_fx.rotation = -rotation
	_bottom_rotation.rotation = -rotation

func _unpack() -> void:
	if absorbed_balls == 0:
		return

	var initial_rotation := PI + PI / 4
	var offset := (PI / 2) / absorbed_balls
	var cursor := 0

	if absorbed_balls == 1:
		initial_rotation = PI + PI / 2

	for ball in balls:
		ball.linear_velocity = (Vector2.RIGHT * 200).rotated(initial_rotation + offset * cursor) * Vector2(1, -1)
		ball.gravity_scale = 1.0
		ball.shape.disabled = false
		ball.sleeping = false
		ball.absorbed = false
		ball.absorbing_ball = null
		ball.visible = true
		cursor += 1

	balls.clear()
	linear_velocity.y = -jump_speed * absorbed_balls * 1.25
	absorbed_balls = 0

	_absorb_one_sfx.pitch_scale = 0.5
	_absorb_one_sfx.playing = true

	_update_ball_size()
