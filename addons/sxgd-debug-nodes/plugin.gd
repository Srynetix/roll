@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-debug-nodes/prelude.gd")

func _enable_plugin() -> void:
	add_autoload_singleton("SxDebugNodes", "res://addons/sxgd-debug-nodes/prelude.gd")
	add_custom_type("SxDebugConsole", "MarginContainer", Prelude.DebugConsole, null)
	add_custom_type("SxDebugTools", "CanvasLayer", Prelude.DebugTools, null)

func _disable_plugin() -> void:
	remove_autoload_singleton("SxDebugNodes")
	remove_custom_type("SxDebugConsole")
	remove_custom_type("SxDebugTools")
