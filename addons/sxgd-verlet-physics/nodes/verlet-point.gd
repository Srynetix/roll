extends Node2D

const VerletLink := preload("res://addons/sxgd-verlet-physics/nodes/verlet-link.gd")

var mass: float = 1.0
var bounce: float = 0.9
var friction: float = 0.99
var gravity_scale: float = 1.0
var acceleration := Vector2.ZERO
var radius: float = 15.0

var touched: bool :
	get:
		return _touched

var _mouseDetectionRadiusThreshold: float = 10.0
var _pinned := false
var _touched := false
var _pin_position := Vector2.ZERO
var _previous_position := Vector2.ZERO
var _links := [] as Array[VerletLink]
var _touch_index := -1


func move_to_position(target: Vector2) -> void:
	position = target
	_previous_position = position

func apply_force(force: Vector2) -> void:
	acceleration += force / mass

func add_link(link: VerletLink) -> void:
	_links.push_back(link)

func remove_link(link: VerletLink) -> void:
	_links.erase(link)

func update_movement(delta: float) -> void:
	var velocity := compute_velocity() * friction
	var next_position := position + velocity + (acceleration * delta)

	_previous_position = position
	position = next_position

	acceleration = Vector2.ZERO

func constraint(world_size: Vector2) -> void:
	for link in _links:
		link.constraint()

	constraint_position_in_size(world_size)
	constraint_pinning()

func pin_to_current_position() -> void:
	pin_to_position(position)

func pin_to_position(target: Vector2) -> void:
	_pinned = true
	_pin_position = target

func unpin() -> void:
	_pinned = false

func compute_velocity() -> Vector2:
	return position - _previous_position

func constraint_pinning() -> void:
	if _pinned:
		position = _pin_position

func constraint_position_in_size(world_size: Vector2) -> void:
	var velocity := compute_velocity() * bounce
	var body_size := Vector2(radius / 2.0, radius / 2.0)

	if position.y < body_size.y / 2.0:
		position.y = body_size.y / 2.0
		velocity.x *= -1
		fix_velocity(velocity)

	elif position.y > world_size.y - body_size.y / 2.0:
		position.y = world_size.y - body_size.y / 2.0
		velocity.x *= -1
		fix_velocity(velocity)

	if position.x < body_size.x / 2.0:
		position.x = body_size.x / 2.0
		velocity.y *= -1
		fix_velocity(velocity)

	elif position.x > world_size.x - body_size.x / 2.0:
		position.x = world_size.x - body_size.x / 2.0
		velocity.y *= -1
		fix_velocity(velocity)

func fix_velocity(velocity: Vector2) -> void:
	_previous_position = position + velocity

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.LIGHT_BLUE)

func _process(delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed && _touch_index == -1:
			if global_position.distance_squared_to(event.position) < pow(radius + _mouseDetectionRadiusThreshold, 2):
				_touch_index = event.index
				_touched = true

		elif !event.pressed && event.index == _touch_index:
			_touch_index = -1
			_touched = false

	elif event is InputEventScreenDrag:
		if _touched && event.index == _touch_index:
			_previous_position = position - event.relative
