@tool
extends ColorRect
## A ready-to-use dissolution effect.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")
const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/dissolve-overlay.gdshader")

## Noise frequency.
@export var noise_frequency := 0.25 : set = _set_noise_frequency
## Replacement color.
@export var replacement_color := Color(0, 0, 0, 1) : set = _set_replacement_color
## Ratio.
@export var ratio := 0.5 : set = _set_ratio

func _set_ratio(value: float) -> void:
	ratio = clamp(value, 0, 1)

	SxShader.set_shader_parameter(self, "dissolution_level", ratio)


func _set_replacement_color(value: Color) -> void:
	replacement_color = value

	SxShader.set_shader_parameter(self, "replacement_color", value)

func _set_noise_frequency(value: float) -> void:
	noise_frequency = value

	var noise_tex := SxShader.get_shader_parameter(self, "noise") as NoiseTexture2D
	noise_tex.noise.frequency = noise_frequency
	SxShader.set_shader_parameter(self, "noise", noise_tex)

func _ready() -> void:
	color = Color.TRANSPARENT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var noise := FastNoiseLite.new()
	var noise_texture := NoiseTexture2D.new()
	noise_texture.noise = noise

	var shader_material := ShaderMaterial.new()
	shader_material.shader = _SHADER
	shader_material.set_shader_parameter("noise", noise_texture)
	shader_material.set_shader_parameter("edge_width", 0.0)
	shader_material.set_shader_parameter("edge_color1", Color.BLACK)
	shader_material.set_shader_parameter("edge_color2", Color.BLACK)
	material = shader_material

	_set_ratio(ratio)
	_set_replacement_color(replacement_color)
	_set_noise_frequency(noise_frequency)
