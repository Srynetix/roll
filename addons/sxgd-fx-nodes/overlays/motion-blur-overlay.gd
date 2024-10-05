@tool
extends ColorRect
## A ready-to-use motion blur effect.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")
const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/gaussian-blur-overlay.gdshader")

## Rotation angle in degrees.
@export var angle_degrees := 0.0 : set = _set_angle_degrees
## Effect strength.
@export var strength := 2.0 : set = _set_strength

func _set_strength(value: float) -> void:
	strength = value

	SxShader.set_shader_parameter(self, "strength", value)

func _set_angle_degrees(value: float) -> void:
	angle_degrees = value

	var angle_to_vector := Vector2.from_angle(deg_to_rad(value))
	SxShader.set_shader_parameter(self, "direction", angle_to_vector)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_material := ShaderMaterial.new()
	shader_material.shader = _SHADER
	material = shader_material

	_set_strength(strength)
	_set_angle_degrees(angle_degrees)
