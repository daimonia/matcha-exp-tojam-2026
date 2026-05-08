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
    for x in map_width:
        cells[x] = []
        cells[x].resize(map_height)

    for coords in cell_positions:
        var tile = self.get_cell_tile_data(coords)
        var type: TileCellType = TileCellType.Empty

        type = TileCellType.get(tile.get_custom_data("tile_type"), TileCellType.Empty)

        set_cell_at_position(coords, TileCell.new(type))

    var repr = ""
    for x in map_width:
        for y in map_height:
            var cell = get_cell_at_position(Vector2(x, y))
            if cell == null:
                repr += "[__, __]"
            else:
                repr += "[%2d, %2d]" % [cell.position.x, cell.position.y]
        repr += "\n"
    print(self.name)
    print(repr)


func set_cell_at_position(pos: Vector2, cell: TileCell) -> void:
    # assert(index < cells.size())
    cells[pos.x][pos.y] = cell
    cell.position = pos


func get_cell_at_position(pos: Vector2) -> TileCell:
    # assert(index < cells.size())
    return cells[pos.x][pos.y]


func get_cell_at_local_position(pos: Vector2i) -> TileCell:
    var tile_pos = local_to_map(pos)
    return get_cell_at_position(tile_pos)


enum TileCellType {Empty, Grass, Clay, Dirt, HardStone}


class TileCell:
    var type: TileCellType
    var position: Vector2
    var hp = 0

    func _init(_type: TileCellType):
        type = _type

    func _to_string() -> String:
        return "<%s [%s] [hp: %d]>" % [TileCellType.find_key(type), position, hp]
