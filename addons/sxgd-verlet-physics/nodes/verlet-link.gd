extends Node2D

const VerletWorld := preload("res://addons/sxgd-verlet-physics/nodes/verlet-world.gd")
const VerletPoint := preload("res://addons/sxgd-verlet-physics/nodes/verlet-point.gd")

var resting_distance: float = 0.0
var minimal_distance: float = -1.0
var maximal_distance: float = -1.0
var stiffness: float = 1.0
var tear_sensitivity: float = -1.0

var point_a: VerletPoint = null
var point_b: VerletPoint = null
var world: VerletWorld = null

func _ready() -> void:
	assert(point_a != null)
	assert(point_b != null)
	assert(world != null)

	if resting_distance == 0.0:
		resting_distance = (point_b.position - point_a.position).length()

func constraint() -> void:
	var diff := point_a.position - point_b.position
	var d := diff.length()
	var difference := (resting_distance - d) / d

	# Check for tearing
	if tear_sensitivity > 0.0 && d > tear_sensitivity:
		world.queue_link_removal(self)

	# Check for min value
	if minimal_distance > 0.0 && d >= minimal_distance:
		return

	var im_a := 1 / point_a.mass
	var im_b := 1 / point_b.mass
	var scalar_a := (im_a / (im_a + im_b)) * stiffness
	var scalar_b := stiffness - scalar_a

	var _compute_movement := func(scalar: float) -> Vector2:
		var movement := diff * difference * scalar
		if maximal_distance > 0.0:
			return movement.limit_length(maximal_distance)
		else:
			return movement

	point_a.position += _compute_movement.call(scalar_a)
	point_b.position -= _compute_movement.call(scalar_b)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(point_a.global_position, point_b.global_position, Color.LIGHT_BLUE)
