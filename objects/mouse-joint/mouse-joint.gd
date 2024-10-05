extends Marker2D
class_name GMouseJoint

@export var speed := 100.0
@export var radius := 10.0
@export var enabled := true

var active := false

@onready var _parent: Node2D = get_parent()

var _last_touch_idx := -1

func _physics_process(_delta: float) -> void:
	if active:
		var camera := get_viewport().get_camera_2d()
		var zoom := Vector2.ONE
		if camera:
			zoom = camera.zoom

		var vp_size := get_viewport_rect().size * zoom
		var vp_size_len := vp_size.length()
		var mouse_position := get_global_mouse_position()
		var rel := mouse_position - _parent.position
		var dist := rel.length()
		var ratio := dist / vp_size_len
		var vel := rel.normalized() * speed * ratio

		_parent.linear_velocity += vel

	queue_redraw()

func _input(event: InputEvent) -> void:
	if !enabled:
		return

	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if _last_touch_idx == -1 && touch_event.pressed:
			_last_touch_idx = touch_event.index

		if _last_touch_idx == touch_event.index:
			if !touch_event.pressed:
				_last_touch_idx = -1
				active = false

			else:
				if radius > 0:
					var world_position: Vector2 = touch_event.position * get_canvas_transform()
					var dist := world_position.distance_squared_to(_parent.position)
					if dist < radius * radius:
						active = true

func _draw() -> void:
	if active:
		draw_line(Vector2.ZERO, (get_global_mouse_position() - _parent.global_position).rotated(-_parent.global_rotation), Color.GRAY, 2)
