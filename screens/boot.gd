extends Control

@onready var _shader_name := %ShaderName as Label

func _ready() -> void:
	MaterialPreloader.material_started.connect(func(material_name):
		_shader_name.text = "Loading " + material_name + "..."
	)

	MaterialPreloader.material_all_finished.connect(func():
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://tests/test-ball.tscn")
	)

	MaterialPreloader.run_preloader()
