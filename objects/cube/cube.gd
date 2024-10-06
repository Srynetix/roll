extends RigidBody2D
class_name GCube

@export var inflation_factor := 4.0
@export var can_jump_with_music := false

@onready var _sprite := $Sprite2D as AnimatedSprite2D
@onready var _shape := $CollisionShape as CollisionShape2D
@onready var _shape_shape := _shape.shape as RectangleShape2D
@onready var _bottom := $Bottom as Area2D

@onready var _initial_shape_size := _shape_shape.size

var inflated: bool :
	get:
		return _inflated
	set(value):
		set_inflated(value)

var _changing := false
var _inflated := false
var _on_ground := false
var _jumping := false

func set_inflated(value: bool) -> void:
	_inflated = value
	_changing = true

	if !is_inside_tree():
		return

	var factor := 1.0
	if _inflated:
		factor = inflation_factor

	var tween := create_tween()
	tween.tween_property(_shape_shape, "size", _initial_shape_size * factor, 0.25)
	tween.parallel().tween_property(_sprite, "scale", Vector2(factor, factor), 0.25)
	await tween.finished

	_bottom.position.y = (_initial_shape_size.y * factor) / 2.0
	_changing = false

func _ready() -> void:
	inflated = true

	_bottom.body_entered.connect(func(body):
		if body != self && body is TileMapLayer:
			_on_ground = true
	)

	_bottom.body_exited.connect(func(_body):
		# Check overlapping bodies
		for body in _bottom.get_overlapping_bodies():
			if body != self:
				return

		_on_ground = false
	)

func _physics_process(delta: float) -> void:
	if _on_ground:
		_jumping = false

	if _on_ground && !_jumping && can_jump_with_music:
		linear_velocity.x += randf_range(-100 * delta, 100 * delta)
		_jump()

func _jump() -> void:
	_jumping = true
	linear_velocity.y = -100
