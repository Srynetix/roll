@tool
extends ColorRect
## A ready-to-use gaussian blur, compatible with GLES2.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")
const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/gaussian-blur-overlay.gdshader")

## Blur strength.
@export var strength := 1.0 : set = _set_strength

var _step1: ColorRect
var _copy: BackBufferCopy
var _step2: ColorRect

func _set_strength(value: float) -> void:
	strength = value

	if !_step1:
		await self.ready

	SxShader.set_shader_parameter(_step1, "strength", value)
	SxShader.set_shader_parameter(_step2, "strength", value)

func _ready() -> void:
	color = Color.TRANSPARENT
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var material_x := ShaderMaterial.new()
	material_x.shader = _SHADER
	material_x.set_shader_parameter("direction", Vector2(1.0, 0.0))
	var material_y := ShaderMaterial.new()
	material_y.shader = _SHADER
	material_y.set_shader_parameter("direction", Vector2(0.0, 1.0))

	_step1 = ColorRect.new()
	_step1.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_step1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_step1.material = material_x
	add_child(_step1)

	_copy = BackBufferCopy.new()
	_copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(_copy)

	_step2 = ColorRect.new()
	_step2.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_step2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_step2.material = material_y
	add_child(_step2)

	_set_strength(strength)

func _process(delta: float) -> void:
	if is_visible_in_tree():
		SxShader.set_shader_parameter(_step1, "strength", strength)
		SxShader.set_shader_parameter(_step2, "strength", strength)
	else:
		SxShader.set_shader_parameter(_step1, "strength", 0)
		SxShader.set_shader_parameter(_step2, "strength", 0)
