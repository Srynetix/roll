extends Control
class_name GHowToPlayDemo

signal finished()

const BallScene := preload("res://objects/ball/ball.tscn")

@onready var _player := %Player as GBall
@onready var _help := %Help as RichTextLabel
@onready var _keys := %Keys as HBoxContainer


class ActionBtn:
	extends SxIconFont.IconLabel

	signal pressed()
	signal released()

	func _ready() -> void:
		icon_size = 28

	func press() -> void:
		icon_color = Color.GREEN
		pressed.emit()

	func release() -> void:
		icon_color = Color.WHITE
		released.emit()


func _ready() -> void:
	# First screen
	_help.text = "[center][b]Absorb creatures to save them[/b][/center]"

	# ArrowRight + Z
	var arrow_right := _new_arrow_right_key()
	var z := _new_z_key()
	_keys.add_child(arrow_right)
	_keys.add_child(_new_plus())
	_keys.add_child(z)
	await _wait(1.0)

	z.press()
	await get_tree().create_timer(0.5).timeout
	arrow_right.press()
	await get_tree().create_timer(1.0).timeout
	z.release()

	await _wait(2.0)
	arrow_right.release()

	# Next screen
	_clear_keys()
	_help.text = "[center][b]Eject creatures to launch yourself.[/b]\n[font_size=12](No worries for the poor things, creatures will follow you when saved at least once.)[/font_size][/center]"

	var arrow_top := _new_arrow_top_key()
	var arrow_left := _new_arrow_left_key()
	var x := _new_x_key()
	_keys.add_child(arrow_left)
	_keys.add_child(_new_plus())
	_keys.add_child(arrow_top)
	_keys.add_child(_new_plus())
	_keys.add_child(x)
	await _wait(2.0)

	arrow_left.press()
	arrow_top.press()
	await _wait(0.25)
	x.press()

	await _wait(0.25)
	x.release()

	arrow_top.release()
	await _wait(1.0)
	arrow_left.release()

	# Next screen
	_clear_keys()

	arrow_right = _new_arrow_right_key()
	arrow_top = _new_arrow_top_key()
	_keys.add_child(arrow_right)
	_keys.add_child(_new_plus())
	_keys.add_child(arrow_top)
	await _wait(2.0)

	arrow_right.press()
	arrow_top.press()
	await _wait(1.0)

	arrow_top.release()

	await _wait(2.0)

	# Next screen
	_clear_keys()
	_help.text = "[center][b]Try to absorb the cubes to make them shrink.[/b][/center]"
	arrow_left = _new_arrow_left_key()
	z = _new_z_key()
	_keys.add_child(arrow_left)
	_keys.add_child(_new_plus())
	_keys.add_child(z)
	await _wait(2.0)

	z.press()
	arrow_left.press()
	await _wait(1.0)

	z.release()
	arrow_left.release()

	# Next screen
	_clear_keys()
	_help.text = "[center][b]Try again to make them grow again.[/b][/center]"
	arrow_left = _new_arrow_left_key()
	z = _new_z_key()
	_keys.add_child(arrow_left)
	_keys.add_child(_new_plus())
	_keys.add_child(z)
	await _wait(2.0)

	z.press()
	arrow_left.press()
	await _wait(0.2)
	z.release()
	arrow_left.release()

	await _wait(0.8)

	z.press()
	arrow_left.press()
	await _wait(0.2)
	z.release()
	arrow_left.release()

	# Next screen
	_clear_keys()
	_help.text = "[center][b]If you are blocked in the middle of a level, press ENTER to retry.[/b][/center]"
	await _wait(3.0)

	# Next screen
	_help.text = "[center][b]Go through the exit to finish the level.[/b]\n[font_size=12](Make sure to save everyone and you will be their hero!)[/font_size][/center]"
	arrow_left = _new_arrow_left_key()
	arrow_top = _new_arrow_top_key()
	_keys.add_child(arrow_left)
	_keys.add_child(_new_plus())
	_keys.add_child(arrow_top)
	await _wait(1.0)

	arrow_left.press()
	arrow_top.press()
	await _wait(2.0)
	arrow_top.release()

	await _wait(2.0)
	finished.emit()

func _clear_keys() -> void:
	for child in _keys.get_children():
		child.free()

func _new_plus() -> SxIconFont.IconLabel:
	var plus := SxIconFont.IconLabel.new()
	plus.icon_name = "plus"
	plus.icon_size = 14
	return plus

func _new_arrow_right_key() -> ActionBtn:
	var arrow_right := ActionBtn.new()
	arrow_right.icon_name = "arrow-right"
	arrow_right.pressed.connect(func():
		_player.input_movement.x = 1.0
	)
	arrow_right.released.connect(func():
		_player.input_movement.x = 0.0
	)
	return arrow_right

func _new_z_key() -> ActionBtn:
	var z := ActionBtn.new()
	z.icon_name = "z"
	z.pressed.connect(func():
		_player.input_absorb = true
	)
	z.released.connect(func():
		_player.input_absorb = false
	)
	return z

func _new_arrow_left_key() -> ActionBtn:
	var arrow_left := ActionBtn.new()
	arrow_left.icon_name = "arrow-left"
	arrow_left.pressed.connect(func():
		_player.input_movement.x = -1.0
	)
	arrow_left.released.connect(func():
		_player.input_movement.x = 0.0
	)
	return arrow_left

func _new_arrow_top_key() -> ActionBtn:
	var key := ActionBtn.new()
	key.icon_name = "arrow-up"
	key.pressed.connect(func():
		_player.input_movement.y = -1
	)
	key.released.connect(func():
		_player.input_movement.y = 0
	)
	return key

func _new_x_key() -> ActionBtn:
	var x := ActionBtn.new()
	x.icon_name = "x"
	x.pressed.connect(func():
		_player.input_eject = true
	)
	x.released.connect(func():
		_player.input_eject = false
	)
	return x

func _wait(secs: float) -> void:
	await get_tree().create_timer(secs).timeout
