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
    ObjectBuilding,
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
    var rewards: Array[Glyph] = []
    var dmg: int

    var world_layer: WorldLayer

    ## this cell's (x, y) coordinates in the WorldLayer
    var coords: Vector2

    var current_hp: int

    signal destroyed

    func _init(
        layer: WorldLayer,
        _cell_type: CellType,
        _max_hp: int = 10,
        _rewards: Array[Glyph] = [],
        _dmg: int = 0
    ):
        world_layer = layer
        cell_type = _cell_type

        max_hp = _max_hp
        current_hp = max_hp

        rewards = _rewards
        dmg = _dmg

    ## apply damage to this map cell; return the amount of damage that this cell should do to the totum
    func take_damage(amount: int) -> int:
        var damage_to_take = amount
        print("%s: take %d damage" % [self, amount])

        if world_layer and world_layer.layer_above:
            var cell_above = world_layer.layer_above.get_cell_at_position(coords)
            if cell_above and not cell_above.is_object() and not cell_above.is_empty():
                # if there's a cell above us, pass half of our damage upwards
                var passed_up = floor(amount / 2.0)
                cell_above.take_damage(passed_up)

                damage_to_take = amount - passed_up

                if cell_above.current_hp >= 0:
                    # if the cell above us was destroyed, we'll take the remaining damage
                    # otherwise, we remain strong 😤
                    return 0

        current_hp = clamp(current_hp - damage_to_take, 0, max_hp)

        if current_hp <= 0:
            destroyed.emit()

        return dmg

    ## whether this cell instance is an "object" (e.g. a tree) rather than a Minecraft block
    func is_object() -> bool:
        return self.cell_type in [CellType.ObjectTree, CellType.ObjectBuilding]

    ## whether this cell instance is empty
    func is_empty() -> bool:
        return self.cell_type in [CellType.Empty]

    func _to_string() -> String:
        return "<%s [%s] [hp: %d/%d]>" % [CellType.find_key(cell_type), coords, current_hp, max_hp]

    static func from_definition(
        layer: WorldLayer, definition: MapCellDefinition
    ) -> MapCellInstance:
        return MapCellInstance.new(
            layer, definition.cell_type, definition.hp, definition.rewards, definition.dmg
        )
