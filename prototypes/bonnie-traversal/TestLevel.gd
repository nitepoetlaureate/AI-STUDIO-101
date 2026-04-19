extends Node2D

## Session 013: TileMapLayer floor (solid) + optional semisolid row; custom_data `surface` + `terrain`.
## Parallax assigned in scene. Ground StaticBody2D removed earlier.

const GROUND_TOP_Y := 500.0
const GROUND_CELLS_X := 250
const GROUND_CELLS_Y := 3

@onready var _terrain: TileMapLayer = $TerrainTiles


func _ready() -> void:
	_terrain.tile_set = _build_floor_tileset()
	_terrain.collision_enabled = true
	for x in range(GROUND_CELLS_X):
		for y in range(GROUND_CELLS_Y):
			_terrain.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	# Demo semisolid strip (physics layer `semisolid` / bit 2) above the main floor.
	for x in range(15, 26):
		_terrain.set_cell(Vector2i(x, -1), 1, Vector2i(0, 0))
	_terrain.position = Vector2(0.0, GROUND_TOP_Y)


func _build_floor_tileset() -> TileSet:
	var tex_floor: Texture2D = load(
		"res://prototypes/bonnie-traversal/art/export/env/env-tile-ground-01.png"
	) as Texture2D
	var tex_plat: Texture2D = load(
		"res://prototypes/bonnie-traversal/art/export/env/env-tile-platform-top-01.png"
	) as Texture2D
	var ts := TileSet.new()

	ts.add_custom_data_layer()
	ts.set_custom_data_layer_name(0, "surface")
	ts.set_custom_data_layer_type(0, TYPE_STRING)
	ts.add_custom_data_layer()
	ts.set_custom_data_layer_name(1, "terrain")
	ts.set_custom_data_layer_type(1, TYPE_STRING)

	ts.add_physics_layer()
	var phys_solid := 0
	ts.set_physics_layer_collision_layer(phys_solid, 1)
	ts.set_physics_layer_collision_mask(phys_solid, 0)

	ts.add_physics_layer()
	var phys_semi := 1
	ts.set_physics_layer_collision_layer(phys_semi, 2)
	ts.set_physics_layer_collision_mask(phys_semi, 0)

	# --- Source 0: solid floor ---
	var src0 := TileSetAtlasSource.new()
	src0.texture = tex_floor
	src0.texture_region_size = Vector2i(16, 16)
	var ac0 := Vector2i(0, 0)
	src0.create_tile(ac0)
	var sid0 := ts.add_source(src0)
	assert(sid0 == 0)
	var td0: TileData = src0.get_tile_data(ac0, 0)
	td0.set_custom_data("surface", "floor")
	td0.set_custom_data("terrain", "solid")
	td0.add_collision_polygon(phys_solid)
	td0.set_collision_polygon_points(
		phys_solid,
		0,
		PackedVector2Array([Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)])
	)

	# --- Source 1: one-way platform top (semisolid) ---
	var src1 := TileSetAtlasSource.new()
	src1.texture = tex_plat
	src1.texture_region_size = Vector2i(16, 16)
	var ac1 := Vector2i(0, 0)
	src1.create_tile(ac1)
	var sid1 := ts.add_source(src1)
	assert(sid1 == 1)
	var td1: TileData = src1.get_tile_data(ac1, 0)
	td1.set_custom_data("surface", "platform")
	td1.set_custom_data("terrain", "semisolid")
	td1.add_collision_polygon(phys_semi)
	td1.set_collision_polygon_points(
		phys_semi,
		0,
		PackedVector2Array([Vector2(0, 0), Vector2(16, 0), Vector2(16, 16), Vector2(0, 16)])
	)
	td1.set_collision_polygon_one_way(phys_semi, 0, true)

	return ts
