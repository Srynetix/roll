extends Node2D

const VerletPoint := preload("res://addons/sxgd-verlet-physics/nodes/verlet-point.gd")
const VerletLink := preload("res://addons/sxgd-verlet-physics/nodes/verlet-link.gd")
const VerletChain := preload("res://addons/sxgd-verlet-physics/nodes/verlet-chain.gd")
const VerletCloth := preload("res://addons/sxgd-verlet-physics/nodes/verlet-cloth.gd")
const Behavior := preload("res://addons/sxgd-verlet-physics/nodes/behavior.gd")

var constraint_accuracy := 2

var _behaviors: Array[Behavior] = []
var _points: Array[VerletPoint] = []
var _links_to_remove: Array[VerletLink] = []

func create_point(initial_position: Vector2) -> VerletPoint:
	var point := VerletPoint.new()
	_points.push_back(point)
	add_child(point)

	point.move_to_position(initial_position)
	return point

func create_link(point_a: VerletPoint, point_b: VerletPoint) -> VerletLink:
	var link := VerletLink.new()
	link.point_a = point_a
	link.point_b = point_b
	link.world = self
	point_a.add_link(link)
	add_child(link)

	return link

func create_chain(pin_first: bool = true, pin_last: bool = false, draw_intermediate_points: bool = true) -> VerletChain:
	return VerletChain.new(self, pin_first, pin_last, draw_intermediate_points)

func create_cloth(
	top_left_position: Vector2,
	point_count: Vector2,
	separation: float,
	pin_mode: VerletCloth.PinMode,
	point_configurator: Callable = Callable(),
	link_configurator: Callable = Callable()
) -> VerletCloth:
	return VerletCloth.new(
		self,
		top_left_position,
		point_count,
		separation,
		pin_mode,
		point_configurator,
		link_configurator,
	)

func queue_link_removal(link: VerletLink) -> void:
	if !_links_to_remove.has(link):
		_links_to_remove.push_back(link)

func remove_link(link: VerletLink) -> void:
	for point in _points:
		point.remove_link(link)

	remove_child(link)

func add_behavior(behavior: Behavior) -> void:
	_behaviors.push_back(behavior)

func remove_behavior(behavior: Behavior) -> void:
	_behaviors.erase(behavior)

func process_points(delta: float) -> void:
	var size := get_viewport().get_visible_rect().size

	# Constraints
	for i in range(constraint_accuracy):
		for point in _points:
			point.constraint(size)

	# Behaviors
	for behavior in _behaviors:
		for point in _points:
			behavior.apply_behavior(point, delta)

	# Positions
	for point in _points:
		point.update_movement(delta)

func _physics_process(delta: float) -> void:
	process_points(delta)

	for link in _links_to_remove:
		remove_link(link)
	_links_to_remove.clear()
