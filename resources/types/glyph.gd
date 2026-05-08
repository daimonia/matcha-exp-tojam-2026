extends Resource

class_name Glyph

@export var name: String
@export var texture: Texture2D

@export var action_node: PackedScene

func spawn_action():
    assert(action_node != null)

    action_node.instantiate()
