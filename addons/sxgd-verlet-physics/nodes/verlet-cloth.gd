extends RefCounted

const VerletWorld := preload("res://addons/sxgd-verlet-physics/nodes/verlet-world.gd")
const VerletPoint := preload("res://addons/sxgd-verlet-physics/nodes/verlet-point.gd")

enum PinMode {
	None,
	TopCorners,
	Top,
	AllCorners
}

var _points: Array[VerletPoint] = []

func _init(
	world: VerletWorld,
	top_left_position: Vector2,
	point_count: Vector2,
	separation: float,
	pin_mode: PinMode = PinMode.TopCorners,
	point_configurator: Callable = Callable(),
	link_configurator: Callable = Callable()
) -> void:
	for j in range(point_count.y):
		for i in range(point_count.x):
			var position := top_left_position + Vector2(separation * i, separation * j)
			var point := world.create_point(position)
			if !point_configurator.is_null():
				point_configurator.call(point)

			if pin_mode == PinMode.AllCorners:
				if (j == 0 || j == point_count.y - 1) && (i == 0 || i == point_count.x - 1):
					point.pin_to_current_position()

			elif pin_mode == PinMode.TopCorners:
				if j == 0 && (i == 0 || i == point_count.x - 1):
					point.pin_to_current_position()

			elif pin_mode == PinMode.Top:
				if j == 0:
					point.pin_to_current_position()

			_points.push_back(point)

	if len(_points) == 0:
		push_error("Bad points length for cloth. Needs to be > 0")
		return

	for j in range(point_count.y):
		for i in range(point_count.x):
			if i > 0:
				# Right to left
				var a_idx := i - 1 + (j * int(point_count.x))
				var b_idx := i + (j * int(point_count.x))
				var link := world.create_link(_points[a_idx], _points[b_idx])
				if !link_configurator.is_null():
					link_configurator.call(link)

			if j > 0:
				# Bottom to top
				var a_idx := i + ((j - 1) * int(point_count.x))
				var b_idx := i + (j * int(point_count.x))

				var link := world.create_link(_points[a_idx], _points[b_idx])
				if !link_configurator.is_null():
					link_configurator.call(link)
