extends Control
## Scene runner, can be used as a test suite.
##
## Inherit the scene, define a "scene_folder", then you can navigate scenes.

## When a scene is loaded.
signal scene_loaded(name: String)
## When quitting the runner.
signal go_back()

## Show the "back" button.
@export var show_back_button := true
## Folder containing scenes to load.
@export_dir var scene_folder: String

const SCENE_KEY_RESET := KEY_I
const SCENE_KEY_PREV := KEY_O
const SCENE_KEY_NEXT := KEY_P

var _current: Control
var _backbutton: Button
var _previous_btn: Button
var _reset_btn: Button
var _next_btn: Button
var _scene_dropdown: OptionButton

var _known_scenes := []
var _current_scene := 0

func _build_ui() -> void:
		var color_rect := ColorRect.new()
		color_rect.name = "ColorRect"
		color_rect.color = Color.BLACK
		color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(color_rect)

		_current = Control.new()
		_current.name = "Current"
		_current.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_current.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_current)

		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "CanvasLayer"
		add_child(canvas_layer)

		var margin := MarginContainer.new()
		margin.name = "Margin"
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_top", 20)
		margin.add_theme_constant_override("margin_bottom", 20)
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		canvas_layer.add_child(margin)

		_backbutton = Button.new()
		_backbutton.name = "BackButton"
		_backbutton.size_flags_horizontal = Control.SIZE_SHRINK_END
		_backbutton.size_flags_vertical = 0
		_backbutton.add_theme_font_size_override("font_size", 20)
		_backbutton.text = "Back"
		margin.add_child(_backbutton)

		var vbox := VBoxContainer.new()
		vbox.name = "VBox"
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.size_flags_vertical = Control.SIZE_SHRINK_END
		margin.add_child(vbox)

		_scene_dropdown = OptionButton.new()
		_scene_dropdown.name = "SceneDropdown"
		_scene_dropdown.size_flags_horizontal = Control.SIZE_SHRINK_END
		_scene_dropdown.size_flags_vertical = Control.SIZE_SHRINK_END
		_scene_dropdown.text = "[NO SCENE FOUND]"
		margin.add_child(_scene_dropdown)

		_scene_dropdown.item_selected.connect(func(idx):
			# Get scene from idx
			_current_scene = idx
			_load_current_scene()
		)

		var inner_margin := MarginContainer.new()
		inner_margin.name = "Margin"
		inner_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner_margin.add_theme_constant_override("margin_right", 10)
		inner_margin.add_theme_constant_override("margin_top", 20)
		inner_margin.add_theme_constant_override("margin_left", 10)
		inner_margin.add_theme_constant_override("margin_bottom", 0)
		vbox.add_child(inner_margin)

		var buttons := HBoxContainer.new()
		buttons.name = "Buttons"
		buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
		buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		buttons.add_theme_constant_override("separation", 32)
		inner_margin.add_child(buttons)

		_previous_btn = Button.new()
		_previous_btn.name = "Previous"
		_previous_btn.add_theme_font_size_override("font_size", 20)
		_previous_btn.text = "< Prev."
		buttons.add_child(_previous_btn)

		_reset_btn = Button.new()
		_reset_btn.name = "Reset"
		_reset_btn.add_theme_font_size_override("font_size", 20)
		_reset_btn.text = "Reset"
		buttons.add_child(_reset_btn)

		_next_btn = Button.new()
		_next_btn.name = "Next"
		_next_btn.add_theme_font_size_override("font_size", 20)
		_next_btn.text = "Next >"
		buttons.add_child(_next_btn)

		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
		_build_ui()

		if !show_back_button:
				_backbutton.hide()

		_known_scenes = _discover_scenes()
		_load_first_scene()

		_previous_btn.pressed.connect(_load_prev_scene)
		_reset_btn.pressed.connect(_load_current_scene)
		_next_btn.pressed.connect(_load_next_scene)
		_backbutton.pressed.connect(_go_back)

func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey:
				var key_event := event as InputEventKey
				if key_event.pressed:
						if key_event.keycode == SCENE_KEY_NEXT:
								_load_next_scene()
						elif key_event.keycode == SCENE_KEY_PREV:
								_load_prev_scene()
						elif key_event.keycode == SCENE_KEY_RESET:
								_load_current_scene()
						elif key_event.keycode == KEY_ESCAPE:
								_go_back()

func _notification(what: int) -> void:
		if what == NOTIFICATION_WM_GO_BACK_REQUEST:
				_go_back()

func _load_first_scene() -> void:
		if len(_known_scenes) == 0:
				return

		_load_current_scene()

func _discover_scenes() -> Array:
		var scenes := []
		var idx := 1

		# Stop on empty scene folder
		if scene_folder == "":
				return scenes

		var dir := DirAccess.open(scene_folder)
		dir.list_dir_begin()

		while true:
				var file := dir.get_next()
				if file == "":
						break

				var remapped_file = file.trim_suffix(".remap")
				if remapped_file.ends_with(".tscn"):
						var scene_name := remapped_file.trim_suffix(".tscn")
						scenes.append([idx, scene_name, load(scene_folder + "/" + remapped_file)])
						_scene_dropdown.add_item(str(idx) + " - " + scene_name, idx)
						idx += 1

		dir.list_dir_end()
		return scenes

func _load_current_scene() -> void:
		var entry := _known_scenes[_current_scene] as Array
		var entry_idx := entry[0] as int
		var entry_name := entry[1] as String
		var entry_model := entry[2] as PackedScene

		# Clear previous
		for child in _current.get_children():
				child.queue_free()

		# Load instance
		var instance := entry_model.instantiate()
		_scene_dropdown.select(entry_idx - 1)
		_current.add_child(instance)
		emit_signal(scene_loaded.get_name(), entry_name)

func _load_next_scene() -> void:
		if _current_scene == len(_known_scenes) - 1:
				_current_scene = 0
		else:
				_current_scene += 1
		_load_current_scene()

func _load_prev_scene() -> void:
		if _current_scene == 0:
				_current_scene = len(_known_scenes) - 1
		else:
				_current_scene -= 1
		_load_current_scene()

func _go_back() -> void:
		_backbutton.mouse_filter = MOUSE_FILTER_IGNORE
		emit_signal(go_back.get_name())
