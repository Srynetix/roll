extends RefCounted

const VerletWorld := preload("res://addons/sxgd-verlet-physics/nodes/verlet-world.gd")
const VerletPoint := preload("res://addons/sxgd-verlet-physics/nodes/verlet-point.gd")

var _pin_first: bool
var _pin_last: bool
var _draw_intermediate_points: bool
var _world: VerletWorld
var _points: Array[VerletPoint] = []

func _init(world: VerletWorld, pin_first: bool = true, pin_last: bool = false, draw_intermediate_points: bool = true) -> void:
	_world = world
	_pin_first = pin_first
	_pin_last = pin_last
	_draw_intermediate_points = draw_intermediate_points

func add_point_at_position(target: Vector2, configurator: Callable = Callable()):
	var point := _world.create_point(target)
	if len(_points) == 0 && _pin_first:
		point.pin_to_current_position()
	elif !_draw_intermediate_points:
		point.visible = false

	if !configurator.is_null():
		configurator.call(point)
	_points.push_back(point)
	return self

func add_point_with_offset(offset: Vector2, configurator: Callable = Callable()):
	var previous_position := Vector2.ZERO
	if len(_points) > 0:
		previous_position = _points[-1].position

	var target := previous_position + offset
	return add_point_at_position(target, configurator)

func add_point_chain_with_same_offset(point_count: int, offset: Vector2, configurator: Callable = Callable()):
	var builder := self
	for i in range(point_count):
		builder = builder.add_point_with_offset(offset, configurator)
	return self

func build(configurator: Callable = Callable()) -> void:
	if len(_points) < 2:
		push_error("Bad points length for chain. Needs to be >=2")
		return

	var last_point := _points[-1]
	if _pin_last:
		last_point.pin_to_current_position()

	last_point.visible = true

	var previous_point := _points[0]
	for i in range(1, len(_points)):
		var curr_point := _points[i]
		var link := _world.create_link(previous_point, curr_point)
		if !configurator.is_null():
			configurator.call(link)

		previous_point = curr_point
