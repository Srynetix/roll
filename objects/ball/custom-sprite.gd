extends Sprite2D
class_name GCustomSprite

@export var size := Vector2i(32, 32)
@export var format := Image.FORMAT_RGBA8
@export var autoload := true

func _ready() -> void:
	if autoload:
		load_custom_texture()

func load_custom_texture() -> void:
	var overlay_file := FileAccess.open("user://custom-texture.bin", FileAccess.READ)
	if overlay_file:
		var buf_len = overlay_file.get_64()
		var buf = overlay_file.get_buffer(buf_len)
		var img := Image.create_empty(size.x, size.y, false, format)
		img.load_png_from_buffer(buf)
		var tex := ImageTexture.create_from_image(img)
		texture = tex
