extends Control

@onready var original_texture := %Original as AnimatedSprite2D
@onready var canvas_texture := %Draw as Sprite2D
@onready var color_picker := %ColorPicker as ColorPickerButton
@onready var draw_btn := %DrawIcon as SxIconFont.IconButton
@onready var picker_btn := %PickerIcon as SxIconFont.IconButton
@onready var eraser_btn := %EraserIcon as SxIconFont.IconButton
@onready var save_and_quit_btn := %SaveAndQuit as Button

enum DrawMode {
	Pencil,
	Eraser,
	Picker
}

var _canvas_img: Image
var _canvas_tex: ImageTexture
var _current_color: Color
var _current_mode: DrawMode = DrawMode.Pencil

func _ready() -> void:
	GameData.set_volume(0.3)

	draw_btn.icon_color = Color.PURPLE

	color_picker.color_changed.connect(func(value):
		_current_color = value
	)

	draw_btn.pressed.connect(func():
		_current_mode = DrawMode.Pencil
		draw_btn.icon_color = Color.PURPLE
		eraser_btn.icon_color = Color.WHITE
		picker_btn.icon_color = Color.WHITE
	)

	eraser_btn.pressed.connect(func():
		_current_mode = DrawMode.Eraser
		draw_btn.icon_color = Color.WHITE
		eraser_btn.icon_color = Color.PURPLE
		picker_btn.icon_color = Color.WHITE
	)

	picker_btn.pressed.connect(func():
		_current_mode = DrawMode.Picker
		draw_btn.icon_color = Color.WHITE
		eraser_btn.icon_color = Color.WHITE
		picker_btn.icon_color = Color.PURPLE
	)

	save_and_quit_btn.pressed.connect(func():
		# Store texture data in file
		var file := FileAccess.open("user://custom-texture.bin", FileAccess.WRITE)
		var buf := _canvas_img.save_png_to_buffer()
		var buf_len := buf.size()
		file.store_64(buf_len)
		file.store_buffer(_canvas_img.save_png_to_buffer())

		get_tree().change_scene_to_packed(GameData.TitleScreen)
	)

	# Center images
	var vp_size := get_viewport_rect().size
	original_texture.position = vp_size / 2
	canvas_texture.position = vp_size / 2

	var original_img := original_texture.sprite_frames.get_frame_texture("default", 0) as AtlasTexture
	_canvas_img = Image.create_empty(int(original_img.region.size.x), int(original_img.region.size.y), false, original_img.atlas.get_image().get_format())

	# Load from buffer
	var file := FileAccess.open("user://custom-texture.bin", FileAccess.READ)
	if file:
		var buf_len := file.get_64()
		var buf := file.get_buffer(buf_len)
		_canvas_img.load_png_from_buffer(buf)

	_canvas_tex = ImageTexture.create_from_image(_canvas_img)
	canvas_texture.texture = _canvas_tex

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask == MOUSE_BUTTON_LEFT || event.button_mask == MOUSE_BUTTON_RIGHT:
			# Determine position based on viewport rect
			var vp_size := get_viewport_rect().size
			var pos := event.position as Vector2

			var canvas_top_left := vp_size / 2 - (16 * canvas_texture.scale)
			var canvas_bottom_right := vp_size / 2 + (16 * canvas_texture.scale)
			if pos.x < canvas_top_left.x || pos.x > canvas_bottom_right.x:
				return
			if pos.y < canvas_top_left.y || pos.y > canvas_bottom_right.y:
				return

			var inner_pos = Vector2(pos.x - canvas_top_left.x, pos.y - canvas_top_left.y) / canvas_texture.scale
			if event.button_mask == MOUSE_BUTTON_LEFT && _current_mode == DrawMode.Pencil:
				_canvas_img.set_pixel(int(inner_pos.x), int(inner_pos.y), _current_color)
			elif event.button_mask == MOUSE_BUTTON_LEFT && _current_mode == DrawMode.Picker:
				_current_color = _canvas_img.get_pixel(int(inner_pos.x), int(inner_pos.y))
				color_picker.color = _current_color
				_current_mode = DrawMode.Pencil
				draw_btn.icon_color = Color.PURPLE
				eraser_btn.icon_color = Color.WHITE
				picker_btn.icon_color = Color.WHITE
			elif _current_mode == DrawMode.Eraser || event.button_mask == MOUSE_BUTTON_RIGHT:
				_canvas_img.set_pixel(int(inner_pos.x), int(inner_pos.y), Color.TRANSPARENT)
			_canvas_tex.update(_canvas_img)
