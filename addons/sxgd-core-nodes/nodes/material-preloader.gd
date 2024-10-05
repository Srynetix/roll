extends Node2D

signal material_started(name)
signal material_all_finished()

var _particle_process_materials := []
var _canvas_item_shader_materials := []
var _logger := SxCore.LoggerExt.get_logger("SxMaterialPreloader")

func add_particle_process_material(data: ParticleProcessMaterial) -> void:
	_particle_process_materials.push_back(data)

func add_canvas_item_shader_material(data: ShaderMaterial) -> void:
	_canvas_item_shader_materials.push_back(data)

func run_preloader() -> void:
	for material in _particle_process_materials:
		_logger.info("Will spawn particle material: %s", [material.resource_path])
		material_started.emit(material.resource_path)

		var fx := GPUParticles2D.new()
		fx.position = get_viewport_rect().size / 2
		fx.process_material = material
		add_child(fx)
		fx.emitting = true

		await get_tree().process_frame
		await get_tree().process_frame

		fx.queue_free()
		_logger.info("Particle material preloaded: %s", [material.resource_path])

	for material in _canvas_item_shader_materials:
		_logger.info("Will spawn canvas item shader material: %s", [material.resource_path])
		material_started.emit(material.resource_path)

		var node := Node2D.new()
		node.position = get_viewport_rect().size / 2
		node.material = material
		add_child(node)

		await get_tree().process_frame
		await get_tree().process_frame

		node.queue_free()
		_logger.info("Canvas item shader material preloaded: %s", [material.resource_path])

	_logger.info("All materials preloaded.")
	material_all_finished.emit()
