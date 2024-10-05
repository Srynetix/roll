@tool
extends EditorPlugin

const IconFontPrelude := preload("res://addons/sxgd-icon-font/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxIconFont", "res://addons/sxgd-icon-font/prelude.gd")
	add_custom_type("SxIconFontButton", "Button", IconFontPrelude.IconButton, null)
	add_custom_type("SxIconFontLabel", "Label", IconFontPrelude.IconLabel, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxIconFont")
	remove_custom_type("SxIconFontButton")
	remove_custom_type("SxIconFontLabel")
