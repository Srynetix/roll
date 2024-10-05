@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-network-nodes/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxNetworkNodes", "res://addons/sxgd-network-nodes/prelude.gd")
	add_custom_type("SxNetworkClientPeer", "Node", Prelude.ClientPeer, null)
	add_custom_type("SxNetworkServerPeer", "Node", Prelude.ServerPeer, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxNetworkNodes")
	remove_custom_type("SxNetworkClientPeer")
	remove_custom_type("SxNetworkServerPeer")
