extends Resource

class_name MapCellDefinition

enum CellType {
    Empty,
    Grass,
    Clay,
    Dirt,
    HardStone,
    Bedrock,

    ObjectTree,
}

@export var name: String
@export var hp: int
@export var dmg: int
@export var cell_type: CellType
@export var rewards: Array[Glyph] = []


## State container for a cell that exists in the game world.
class MapCellInstance:
    var cell_type: CellType
    var max_hp: int

    ## this cell's (x, y) coordinates in the WorldLayer
    var coords: Vector2

    var current_hp: int

    signal destroyed

    func _init(_cell_type: CellType, _max_hp: int = 10):
        cell_type = _cell_type
        max_hp = _max_hp
        current_hp = max_hp

    func take_damage(amount: int) -> void:
        current_hp = clamp(current_hp - amount, 0, max_hp)
        if current_hp <= 0:
            destroyed.emit()

    ## whether this cell instance is an "object" (e.g. a tree) rather than a Minecraft block
    func is_object() -> bool:
        return self.cell_type == CellType.ObjectTree

    func _to_string() -> String:
        return "<%s [%s] [hp: %d/%d]>" % [
            CellType.find_key(cell_type), coords, current_hp, max_hp
        ]

    static func from_definition(definition: MapCellDefinition) -> MapCellInstance:
        return MapCellInstance.new(definition.cell_type, definition.hp)
