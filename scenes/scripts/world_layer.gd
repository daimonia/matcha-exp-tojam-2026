extends TileMapLayer

class_name WorldLayer


@onready var cell_positions = self.get_used_cells()
@onready var map_size = self.get_used_rect()

var map_width: int
var map_height: int
var cells: Array = []  # Array[Array[TileCell]]

# Called when the node enters the scene tree for the first time.
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

    var repr = ""
    for y in map_width:
        for x in map_height:
            var cell = get_cell_at_position(Vector2(x, y))
            if cell == null:
                repr += "[__, __]"
            else:
                repr += "[%2d, %2d]" % [cell.position.x, cell.position.y]
        repr += "\n"
    print(self.name)
    print(repr)


func _on_cell_destroyed(cell: TileCell) -> void:
    print('%s: i died' % cell)
    set_cell(cell.position)
    set_cell_at_position(cell.position, TileCell.new(TileCellType.Empty))
    cell.disconnect("destroyed", _on_cell_destroyed)


func set_cell_at_position(pos: Vector2, cell: TileCell) -> void:
    assert(pos.y < cells.size())
    assert(pos.x < cells[pos.y].size())
    cells[pos.y][pos.x] = cell
    cell.position = pos

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
    var position: Vector2
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
        return "<%s [%s] [hp: %d/%d]>" % [TileCellType.find_key(type), position, current_hp, max_hp]
