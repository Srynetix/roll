@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-scene-runner/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxSceneRunner", "res://addons/sxgd-scene-runner/prelude.gd")
	add_custom_type("SxSceneRunner", "Control", Prelude.SceneRunner, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxSceneRunner")
	remove_custom_type("SxSceneRunner")
