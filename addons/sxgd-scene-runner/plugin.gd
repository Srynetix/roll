@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-scene-runner/prelude.gd")

func _enable_plugin() -> void:
	add_autoload_singleton("SxSceneRunner", "res://addons/sxgd-scene-runner/prelude.gd")
	add_custom_type("SxSceneRunner", "Control", Prelude.SceneRunner, null)

func _disable_plugin() -> void:
	remove_autoload_singleton("SxSceneRunner")
	remove_custom_type("SxSceneRunner")
