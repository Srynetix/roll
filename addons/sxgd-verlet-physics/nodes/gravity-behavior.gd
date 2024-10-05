extends "res://addons/sxgd-verlet-physics/nodes/behavior.gd"

var gravity := Vector2(0, 9.81)

func apply_behavior(point: VerletPoint, delta: float) -> void:
	if !point.touched:
		point.apply_force(gravity * point.gravity_scale)
