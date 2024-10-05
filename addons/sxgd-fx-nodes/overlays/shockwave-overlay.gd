@tool
extends ColorRect
## An animated shockwave effect.

const SxShader := preload("res://addons/sxgd-core/extensions/shader.gd")
const _SHADER := preload("res://addons/sxgd-fx-nodes/overlays/shockwave-overlay.gdshader")

## Wave size.
@export var wave_size := 0.1 : set = _set_wave_size
## Wave center.
@export var wave_center := Vector2(0.5, 0.5) : set = _set_wave_center
## Wave force.
@export var force := 0.1 : set = _set_force
## Wave thickness.
@export var thickness := -0.01 : set = _set_thickness
## Wave on startup.
@export var wave_on_startup := false

## Used to build a wave.
class WaveBuilder:
	extends Object

	## Wave position.
	var position := Vector2(0.5, 0.5)
	## Wave speed.
	var speed := 2.0
	## Wave initial force.
	var initial_force := 0.0
	## Wave target force.
	var target_force := 0.25
	## Wave initial thickness.
	var initial_thickness := 0.0
	## Wave target thickness.
	var target_thickness := 0.2
	## Wave initial size.
	var initial_wave_size := 0.1
	## Wave target size.
	var target_wave_size := 1.25

var _tween: Tween

## Start a wave.
func start_wave(unit_position: Vector2, speed: float = 2, max_force = 0.25, max_thickness = 0.2) -> void:
	_set_wave_center(unit_position)

	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()

	_tween.parallel().tween_property(self, "wave_size", 1.25, speed).from(0.1)
	_tween.parallel().tween_property(self, "force", max_force, speed).from(0.0)
	_tween.parallel().tween_property(self, "thickness", max_thickness, speed).from(0.0)

	await _tween.finished

	force = 0.0
	thickness = 0.0

## Show an animated wave.
func show_animated_wave(parameters: WaveBuilder) -> void:
	var game_size := get_viewport_rect().size
	var unit_position := parameters.position / game_size
	wave_center = unit_position

	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()

	_tween.parallel().tween_property(self, "wave_size", parameters.target_wave_size, parameters.speed).from(parameters.initial_wave_size)
	_tween.parallel().tween_property(self, "force", parameters.target_force, parameters.speed).from(parameters.initial_force)
	_tween.parallel().tween_property(self, "thickness", parameters.target_thickness, parameters.speed).from(parameters.initial_thickness)

	await _tween.finished

	wave_size = 0.0
	force = 0.0
	thickness = 0.0

## Check if a wave is running.
func wave_is_running() -> bool:
	return _tween && _tween.is_running()

func _set_wave_size(value: float) -> void:
	wave_size = value

	SxShader.set_shader_parameter(self, "size", value)

func _set_wave_center(value: Vector2) -> void:
	wave_center = value

	SxShader.set_shader_parameter(self, "center", value)

func _set_force(value: float) -> void:
	force = value

	SxShader.set_shader_parameter(self, "force", value)

func _set_thickness(value: float) -> void:
	thickness = value

	SxShader.set_shader_parameter(self, "thickness", value)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.TRANSPARENT

	var shader_material := ShaderMaterial.new()
	shader_material.shader = _SHADER
	material = shader_material

	_set_wave_size(wave_size)
	_set_thickness(thickness)
	_set_force(force)
	_set_wave_center(wave_center)

	if wave_on_startup:
		start_wave(Vector2(0.5, 0.5))

func _exit_tree():
	if !Engine.is_editor_hint():
		if _tween:
			_tween.kill()
