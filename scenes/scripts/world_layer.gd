extends TileMapLayer

class_name WorldLayer


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
var cells: Array = []  # Array[Array[TileCell]]

func _ready() -> void:
    map_width = map_size.size.x - map_size.position.x
    map_height =  map_size.size.y - map_size.position.y

    cells.resize(map_width)
    for y in map_width:
        cells[y] = []
        cells[y].resize(map_width)

    for coords in cell_positions:
        var tile = self.get_cell_tile_data(coords)
        var type: TileCellType = TileCellType.Empty

        type = TileCellType.get(tile.get_custom_data("tile_type"), TileCellType.Empty)

        set_cell_at_position(coords, TileCell.new(type))


func _on_cell_destroyed(cell: TileCell) -> void:
    print('%s: i died' % cell)
    set_cell(cell.coords)
    set_cell_at_position(cell.coords, TileCell.new(TileCellType.Empty))
    cell.disconnect("destroyed", _on_cell_destroyed)

    if layer_above:
        var above_cell = layer_above.get_cell_at_position(cell.coords)
        if above_cell != null and above_cell.type == TileCellType.ObjectTree:
            above_cell.take_damage(1000)


func set_cell_at_position(pos: Vector2, cell: TileCell) -> void:
    assert(pos.y < cells.size())
    assert(pos.x < cells[pos.y].size())
    cells[pos.y][pos.x] = cell
    cell.coords = pos

    cell.connect("destroyed", _on_cell_destroyed.bind(cell))


func get_cell_at_position(pos: Vector2) -> TileCell:
    assert(pos.y < cells.size())
    assert(pos.x < cells[pos.y].size())
    return cells[pos.y][pos.x]


func get_cell_at_local_position(pos: Vector2i) -> TileCell:
    var tile_pos = local_to_map(pos)
    return get_cell_at_position(tile_pos)


enum TileCellType {Empty, Grass, Clay, Dirt, HardStone, ObjectTree}


class TileCell:
    var type: TileCellType
    var coords: Vector2
    var max_hp = 10
    var current_hp = max_hp

    signal destroyed

    func _init(_type: TileCellType):
        type = _type

    func take_damage(amount: int) -> void:
        current_hp = clamp(current_hp - amount, 0, max_hp)
        if current_hp <= 0:
            destroyed.emit()

    func _to_string() -> String:
        return "<%s [%s] [hp: %d/%d]>" % [TileCellType.find_key(type), coords, current_hp, max_hp]
