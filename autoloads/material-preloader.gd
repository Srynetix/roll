extends SxCoreNodes.MaterialPreloader

func _init() -> void:
	add_particle_process_material(preload("res://objects/ball/jump-fx.tres"))
	add_particle_process_material(preload("res://objects/ball/absorb-fx.tres"))
	add_canvas_item_shader_material(preload("res://objects/ball/ball-material.tres"))
