@tool
extends ColorRect
## A ready-to-use chromatic aberration effect.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")
const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/chromatic-aberration-overlay.gdshader")

## Enable the effect.
@export var enabled := true : set = _set_enabled
## Effect amount.
@export var amount := 1.0 : set = _set_amount

func _ready() -> void:
	color = Color.TRANSPARENT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_material := ShaderMaterial.new()
	shader_material.shader = _SHADER
	material = shader_material

	_set_enabled(enabled)
	_set_amount(amount)

func _set_enabled(value: bool) -> void:
	enabled = value

	SxShader.set_shader_parameter(self, "apply", value)

func _set_amount(value: float) -> void:
	amount = value

	SxShader.set_shader_parameter(self, "amount", value)
