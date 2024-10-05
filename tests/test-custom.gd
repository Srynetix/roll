extends Control

@onready var original_texture := %Original as TextureRect
@onready var canvas_texture := %Draw as TextureRect
@onready var color_picker := %ColorPicker as ColorPickerButton
@onready var draw_btn := %DrawIcon as SxIconFont.IconButton
@onready var eraser_btn := %EraserIcon as SxIconFont.IconButton
@onready var save_and_quit_btn := %SaveAndQuit as Button

enum DrawMode {
	Pencil,
	Eraser
}

var _canvas_img: Image
var _canvas_tex: ImageTexture
var _current_color: Color
var _current_mode: DrawMode = DrawMode.Pencil

func _ready() -> void:
	color_picker.color_changed.connect(func(value):
		_current_color = value
	)

	draw_btn.pressed.connect(func():
		_current_mode = DrawMode.Pencil
	)

	eraser_btn.pressed.connect(func():
		_current_mode = DrawMode.Eraser
	)

	save_and_quit_btn.pressed.connect(func():
		# Store texture data in file
		var file := FileAccess.open("user://custom-texture.bin", FileAccess.WRITE)
		var buf := _canvas_img.save_png_to_buffer()
		var buf_len := buf.size()
		file.store_64(buf_len)
		file.store_buffer(_canvas_img.save_png_to_buffer())
	)

	var original_img := original_texture.texture as AtlasTexture
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
		if event.button_mask == MOUSE_BUTTON_LEFT:
			# Determine position based on viewport rect
			var canvas_rect := Rect2(canvas_texture.position, canvas_texture.size)
			var mouse_pos := canvas_texture.get_local_mouse_position()

			if canvas_rect.has_point(mouse_pos):
				var pos := mouse_pos / Vector2(32, 32)
				pos = pos.clamp(Vector2(0, 0), Vector2(32, 32))

				if _current_mode == DrawMode.Pencil:
					_canvas_img.set_pixel(int(pos.x), int(pos.y), _current_color)
				else:
					_canvas_img.set_pixel(int(pos.x), int(pos.y), Color.TRANSPARENT)
				_canvas_tex.update(_canvas_img)
