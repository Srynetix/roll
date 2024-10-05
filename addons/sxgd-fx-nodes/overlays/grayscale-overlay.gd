@tool
extends ColorRect
## A ready-to-use grayscale effect.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")

const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/grayscale-overlay.gdshader")

## Effect ratio.
@export var ratio := 1.0 : set = _set_ratio

func _set_ratio(value: float) -> void:
	ratio = clamp(value, 0, 1)

	SxShader.set_shader_parameter(self, "ratio", value)

func _ready() -> void:
	color = Color.TRANSPARENT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_material := ShaderMaterial.new()
	shader_material.shader = _SHADER
	material = shader_material

	_set_ratio(ratio)
