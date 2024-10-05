@tool
extends ColorRect
## A ready-to-use vignette effect.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")

const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/vignette-overlay.gdshader")

## Vignette size.
@export var vignette_size := 10.0 : set = _set_vignette_size
## Vignette ratio.
@export var vignette_ratio := 0.25 : set = _set_vignette_ratio

var _tween: Tween

## Show a fade effect.
func fade(duration: float = 1) -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()

	_tween.tween_property(self, "vignette_ratio", 1.0, duration).from(vignette_ratio)
	await _tween.finished

func _set_vignette_ratio(value: float) -> void:
	vignette_ratio = value

	SxShader.set_shader_parameter(self, "ratio", value)

func _set_vignette_size(value: float) -> void:
	vignette_size = value

	SxShader.set_shader_parameter(self, "size", value)

func _ready() -> void:
	color = Color.TRANSPARENT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_material := ShaderMaterial.new()
	shader_material.shader = _SHADER
	material = shader_material

	_set_vignette_ratio(vignette_ratio)
	_set_vignette_size(vignette_size)

func _exit_tree():
	if _tween:
		_tween.kill()
