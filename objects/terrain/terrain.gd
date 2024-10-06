extends Node2D
class_name GTerrain

signal build_player(position)
signal build_ball(position)
signal build_cube(position)
signal build_spikes(position, angle)
signal build_finish(position, angle)

@export var music_bg: GMusicBG
@export var middleground: TileMapLayer
@export var foreground: TileMapLayer

func get_used_rect() -> Rect2i:
	return middleground.get_used_rect()

func get_tile_size() -> Vector2i:
	return middleground.tile_set.tile_size

func _get_tile_id_from_name(tile_set: TileSet, tile_name: String) -> Vector2i:
	var source_id := tile_set.get_source_id(0)
	var source := tile_set.get_source(source_id) as TileSetAtlasSource
	for tile_idx in range(source.get_tiles_count()):
		var tile_coords := source.get_tile_id(tile_idx)
		var tile_data := source.get_tile_data(tile_coords, 0)
		var this_tile_name := tile_data.get_custom_data("item-kind") as String
		if this_tile_name == tile_name:
			return tile_coords

	push_error("Could not fetch tile coords from name: %s" % tile_name)
	return Vector2i()

func setup() -> void:
	# Iterate on items in foreground layer
	for cell_position in foreground.get_used_cells():
		var tile_data := foreground.get_cell_tile_data(cell_position)
		if tile_data:
			var item_kind := tile_data.get_custom_data("item-kind") as String
			if item_kind == "ball":
				build_ball.emit(cell_position * foreground.tile_set.tile_size)

			elif item_kind == "player":
				build_player.emit(cell_position * foreground.tile_set.tile_size)
				foreground.set_cell(cell_position)

			elif item_kind == "finish":
				var tile_rotation := _get_tile_angle(foreground, cell_position)
				build_finish.emit(cell_position * foreground.tile_set.tile_size + (foreground.tile_set.tile_size / 2.0 as Vector2i), tile_rotation)
				foreground.set_cell(cell_position)

			elif item_kind == "cube":
				build_cube.emit(cell_position * foreground.tile_set.tile_size)
				foreground.set_cell(cell_position)

	# Iterate on items in middleground layer
	for cell_position in middleground.get_used_cells():
		var tile_data := middleground.get_cell_tile_data(cell_position)
		if tile_data:
			var item_kind := tile_data.get_custom_data("item-kind") as String
			if item_kind == "spike":
				var tile_rotation := _get_tile_angle(middleground, cell_position)
				build_spikes.emit(cell_position * middleground.tile_set.tile_size + (middleground.tile_set.tile_size / 2.0 as Vector2i), tile_rotation)

func _get_tile_angle(layer: TileMapLayer, coords: Vector2i) -> float:
	var alt := layer.get_cell_alternative_tile(coords)
	var is_transpose := alt & TileSetAtlasSource.TRANSFORM_TRANSPOSE
	var is_flip_h := alt & TileSetAtlasSource.TRANSFORM_FLIP_H
	var is_flip_v := alt & TileSetAtlasSource.TRANSFORM_FLIP_V

	if is_transpose && is_flip_h:
		return PI / 2
	elif (!is_transpose && (is_flip_h || is_flip_v)):
		return PI
	elif is_transpose && is_flip_v:
		return PI + PI / 2
	return 0.0
