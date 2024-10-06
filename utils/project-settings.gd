extends RefCounted

static var _computed := false
static var _layer_cache: Dictionary = {}

static func get_2d_physics_layer_by_name(name: String) -> int:
	assert(name != "", "layer name cannot be empty")

	if !_computed:
		for x in range(1, 33):
			var layer_name := ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(x)) as String
			if layer_name == "":
				# Ignore layers without names
				continue

			_layer_cache[layer_name] = x

	assert(name in _layer_cache, "unkown layer name")
	return _layer_cache[name]
