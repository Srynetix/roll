@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-verlet-physics/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxVerletPhysics", "res://addons/sxgd-verlet-physics/prelude.gd")
	add_custom_type("SxVerletWorld", "Node2D", Prelude.VerletWorld, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxVerletPhysics")
	remove_custom_type("SxVerletWorld")
