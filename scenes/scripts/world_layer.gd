## Represents one layer of the world. Should be instanced into the World scene and given two TileMapLayer children.
## very jank i am sry

extends Node2D

class_name WorldLayer


@export var map_cell_definition_loader: MapCellDefinitionLoader

@export var layer_above: WorldLayer
@export var layer_below: WorldLayer
@export var max_depth: int

@export var depth: int:
    set(value):
        depth = value

        collision_body.collision_layer = 1 << depth   # bit N for depth N
        collision_body.collision_mask = 0

## the TileMapLayer that contains the actual map design
@onready var tile_map_layer_world: TileMapLayer = $TileMapLayer

@onready var cell_positions = tile_map_layer_world.get_used_cells()
@onready var map_size = tile_map_layer_world.get_used_rect()

@onready var collision_body: StaticBody2D = $StaticBody2D

signal map_cell_destroyed(cell: MapCellDefinition.MapCellInstance)

var map_width: int
var map_height: int
var cells: Array = []  # Array[Array[MapCellInstance]]

func _ready() -> void:
    depth = depth

    map_width = map_size.size.x - map_size.position.x
    map_height =  map_size.size.y - map_size.position.y

    cells.resize(map_width)
    for y in map_width:
        cells[y] = []
        cells[y].resize(map_width)

    for coords in cell_positions:
        var tile = tile_map_layer_world.get_cell_tile_data(coords)
        var tile_type = tile.get_custom_data('tile_type')
        var definition = map_cell_definition_loader.get_definition_by_name(tile_type)
        assert(
            definition != null,
            "failed to load MapCellDefinition for tile %s: unknown tile_type %s" % [tile, tile_type]
        )

        if definition.cell_type != MapCellDefinition.CellType.Empty:
            var collision_shape := CollisionShape2D.new()
            collision_shape.shape = RectangleShape2D.new()
            collision_shape.shape.size = tile_map_layer_world.tile_set.tile_size
            collision_shape.position = tile_map_layer_world.map_to_local(coords)
            collision_shape.name = 'cell_%d_%d' % [coords.x, coords.y]
            collision_body.add_child(collision_shape)

        set_cell_at_position(coords, MapCellDefinition.MapCellInstance.from_definition(self, definition))


func _on_cell_destroyed(cell: MapCellDefinition.MapCellInstance) -> void:
    tile_map_layer_world.set_cell(cell.coords)  # clear the cell in the tile map layer
    set_cell_at_position(cell.coords, MapCellDefinition.MapCellInstance.new(self, MapCellDefinition.CellType.Empty))
    cell.disconnect("destroyed", _on_cell_destroyed)

    map_cell_destroyed.emit(cell)

    var shape = collision_body.get_node_or_null("cell_%d_%d" % [cell.coords.x, cell.coords.y])
    if shape: shape.queue_free()

    if layer_above:
        var above_cell = layer_above.get_cell_at_position(cell.coords)
        if above_cell != null and above_cell.is_object():
            above_cell.take_damage(1000)


func set_cell_at_position(pos: Vector2, cell: MapCellDefinition.MapCellInstance) -> void:
    assert(pos.y < cells.size())
    assert(pos.x < cells[pos.y].size())
    cells[pos.y][pos.x] = cell
    cell.coords = pos

    cell.connect("destroyed", _on_cell_destroyed.bind(cell))


func get_cell_at_position(pos: Vector2) -> MapCellDefinition.MapCellInstance:
    assert(pos.y < cells.size(), '%s: out of bounds (x-axis)' % name)
    assert(pos.x < cells[pos.y].size(), "%s: out of bounds (y-axis)" % name)
    return cells[pos.y][pos.x]


func get_cell_at_local_position(pos: Vector2i) -> MapCellDefinition.MapCellInstance:
    var tile_pos = tile_map_layer_world.local_to_map(pos)
    return get_cell_at_position(tile_pos)


func get_cell_at_global_position(pos: Vector2i) -> MapCellDefinition.MapCellInstance:
    return get_cell_at_local_position(to_local(pos))
