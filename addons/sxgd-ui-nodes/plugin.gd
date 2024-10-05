@tool
extends EditorPlugin

const Prelude := preload("res://addons/sxgd-ui-nodes/prelude.gd")

func _enter_tree() -> void:
	add_autoload_singleton("SxUiNodes", "res://addons/sxgd-ui-nodes/prelude.gd")
	add_custom_type("SxUiAutocompleteLineEdit", "LineEdit", Prelude.AutocompleteLineEdit, null)
	add_custom_type("SxUiDoubleTap", "Node", Prelude.DoubleTap, null)
	add_custom_type("SxUiFullScreenDialog", "Panel", Prelude.FullScreenDialog, null)
	add_custom_type("SxUiFullScreenAcceptDialog", "Panel", Prelude.FullScreenAcceptDialog, null)
	add_custom_type("SxUiFullScreenConfirmationDialog", "Panel", Prelude.FullScreenConfirmationDialog, null)
	add_custom_type("SxUiFullScreenFileDialog", "Panel", Prelude.FullScreenFileDialog, null)
	add_custom_type("SxUiItemList", "ItemList", Prelude.TouchableItemList, null)
	add_custom_type("SxUiFadingRichTextLabel", "RichTextLabel", Prelude.FadingRichTextLabel, null)

func _exit_tree() -> void:
	remove_autoload_singleton("SxUiNodes")
	remove_custom_type("SxUiAutocompleteLineEdit")
	remove_custom_type("SxUiDoubleTap")
	remove_custom_type("SxUiFullScreenDialog")
	remove_custom_type("SxUiFullScreenAcceptDialog")
	remove_custom_type("SxUiFullScreenConfirmationDialog")
	remove_custom_type("SxUiFullScreenFileDialog")
	remove_custom_type("SxUiItemList")
	remove_custom_type("SxUiFadingRichTextLabel")
