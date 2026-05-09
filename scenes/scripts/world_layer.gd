extends TileMapLayer

class_name WorldLayer


@export var map_cell_definition_loader: MapCellDefinitionLoader

@export var layer_above: WorldLayer
@export var layer_below: WorldLayer

@export var max_depth: int:
    set(value):
        max_depth = value
        # var mod = float(depth) / float(max_depth)
        # modulate = Color(255 - mod * 50, 255 - mod * 50, 255 - mod * 50, 1)
        # print('%s modulating: %d / %d, %f, %s' % [self.name, depth, max_depth, mod, modulate])

@export var depth: int:
    set(value):
        depth = value
        # self.modulate = Color(0, 0, 0, float(value) / max_depth)

@onready var cell_positions = self.get_used_cells()
@onready var map_size = self.get_used_rect()

var map_width: int
var map_height: int
var cells: Array = []  # Array[Array[MapCellInstance]]

func _ready() -> void:
    map_width = map_size.size.x - map_size.position.x
    map_height =  map_size.size.y - map_size.position.y

    cells.resize(map_width)
    for y in map_width:
        cells[y] = []
        cells[y].resize(map_width)

    for coords in cell_positions:
        var tile = self.get_cell_tile_data(coords)
        var tile_type = tile.get_custom_data('tile_type')
        var definition = map_cell_definition_loader.get_definition_by_name(tile_type)
        assert(
            definition != null,
            "failed to load MapCellDefinition for tile %s: unknown tile_type %s" % [tile, tile_type]
        )

        set_cell_at_position(coords, MapCellDefinition.MapCellInstance.from_definition(definition))


func _on_cell_destroyed(cell: MapCellDefinition.MapCellInstance) -> void:
    print('%s: i died' % cell)
    set_cell(cell.coords)
    set_cell_at_position(cell.coords, MapCellDefinition.MapCellInstance.new(MapCellDefinition.CellType.Empty))
    cell.disconnect("destroyed", _on_cell_destroyed)

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
    assert(pos.y < cells.size())
    assert(pos.x < cells[pos.y].size())
    return cells[pos.y][pos.x]


func get_cell_at_local_position(pos: Vector2i) -> MapCellDefinition.MapCellInstance:
    var tile_pos = local_to_map(pos)
    return get_cell_at_position(tile_pos)


func get_cell_at_global_position(pos: Vector2i) -> MapCellDefinition.MapCellInstance:
    return get_cell_at_local_position(to_local(pos))
