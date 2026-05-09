extends Node

class_name MapCellDefinitionLoader


@export var map_cell_definitions: Array[MapCellDefinition]

func _ready() -> void:
    # TODO log a warning if any MapCellDefinition resource files exist in the project but are not loaded
    pass


func get_definition_by_name(definition_name: String) -> MapCellDefinition:
    for def in map_cell_definitions:
        if def.name == definition_name:
            return def

    return null
