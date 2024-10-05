extends Node2D
class_name GTerrain

signal build_player(position)
signal build_ball(position)
signal build_spikes(position)

@onready var _background := $Background as TileMapLayer
@onready var _middleground := $Middleground as TileMapLayer
@onready var _foreground := $Foreground as TileMapLayer

func get_used_rect() -> Rect2i:
	return _background.get_used_rect()

func get_tile_size() -> Vector2i:
	return _background.tile_set.tile_size

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
	for cell_position in _foreground.get_used_cells():
		var tile_data := _foreground.get_cell_tile_data(cell_position)
		if tile_data:
			var item_kind := tile_data.get_custom_data("item-kind") as String
			if item_kind == "ball":
				build_ball.emit(cell_position * _foreground.tile_set.tile_size)

			elif item_kind == "player":
				build_player.emit(cell_position * _foreground.tile_set.tile_size)
				_foreground.set_cell(cell_position)

	# Iterate on items in middleground layer
	for cell_position in _middleground.get_used_cells():
		var tile_data := _middleground.get_cell_tile_data(cell_position)
		if tile_data:
			var item_kind := tile_data.get_custom_data("item-kind") as String
			if item_kind == "spike":
				build_spikes.emit(cell_position * _middleground.tile_set.tile_size + (_middleground.tile_set.tile_size / 2.0 as Vector2i))

