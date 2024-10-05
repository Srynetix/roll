extends Camera2D
class_name GTrackingCamera

@export var target: Node2D

func lock_inside_area(area_position: Vector2i, area_size: Vector2i) -> void:
	limit_left = area_position.x
	limit_right = area_position.x + area_size.x
	limit_top = area_position.y
	limit_bottom = area_position.y + area_size.y

func _process(_delta: float) -> void:
	if target:
		if !is_instance_valid(target):
			target = null
		else:
			global_position = target.global_position
