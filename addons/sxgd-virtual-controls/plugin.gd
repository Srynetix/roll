@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-virtual-controls/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxVirtualControls", "res://addons/sxgd-virtual-controls/prelude.gd")
	add_custom_type("SxVirtualButton", "TextureRect", Prelude.VirtualButton, null)
	add_custom_type("SxVirtualJoystick", "TextureRect", Prelude.VirtualJoystick, null)
	add_custom_type("SxVirtualControlSurface", "Control", Prelude.VirtualSurface, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxVirtualControls")
	remove_custom_type("SxVirtualButton")
	remove_custom_type("SxVirtualJoystick")
	remove_custom_type("SxVirtualControlSurface")
