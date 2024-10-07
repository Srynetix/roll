@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("SxCore", "res://addons/sxgd-core/prelude.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("SxCore")
