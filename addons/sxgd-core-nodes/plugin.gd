@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-core-nodes/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxCoreNodes", "res://addons/sxgd-core-nodes/prelude.gd")
	add_custom_type("SxSceneTransitioner", "CanvasLayer", Prelude.SceneTransitioner, null)
	add_custom_type("SxLoadCache", "Node", Prelude.LoadCache, null)
	add_custom_type("SxGameData", "Node", Prelude.LoadCache, null)
	add_custom_type("SxCommandLineParser", "Node", Prelude.CommandLineParser, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxCoreNodes")
	remove_custom_type("SxSceneTransitioner")
	remove_custom_type("SxLoadCache")
	remove_custom_type("SxGameData")
	remove_custom_type("SxCommandLineParser")
