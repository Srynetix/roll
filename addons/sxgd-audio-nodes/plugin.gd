@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-audio-nodes/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxAudioNodes", "res://addons/sxgd-audio-nodes/prelude.gd")
	add_custom_type("SxAudioStreamPlayer", "AudioStreamPlayer", Prelude.SxAudioStreamPlayer, null)
	add_custom_type("SxAudioStreamPlayer3D", "AudioStreamPlayer3D", Prelude.SxAudioStreamPlayer3D, null)
	add_custom_type("SxAudioMultiStreamPlayer", "Node", Prelude.MultiStreamPlayer, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxAudioNodes")
	remove_custom_type("SxAudioStreamPlayer")
	remove_custom_type("SxAudioStreamPlayer3D")
	remove_custom_type("SxAudioMultiStreamPlayer")
