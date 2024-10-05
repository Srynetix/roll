extends SceneTree

const JSON_DATA_INPUT := "res://addons/sxgd-icon-font/assets/metadata/icons.json"
const JSON_DATA_OUTPUT := "res://addons/sxgd-icon-font/nodes/json-data.gd"

func _init() -> void:
	pass

func _initialize() -> void:
	# Load data from input
	var input_fd := FileAccess.open(JSON_DATA_INPUT, FileAccess.READ)
	var content := input_fd.get_as_text()
	var json_content := JSON.parse_string(content)

	# Put data in output gdscript file
	var output_fd := FileAccess.open(JSON_DATA_OUTPUT, FileAccess.WRITE)
	var template := "extends RefCounted\n\nconst DATA = %s" % JSON.stringify(json_content, "\t")
	output_fd.store_string(template)

	print("JSON data written to %s" % JSON_DATA_OUTPUT)
	quit(0)
