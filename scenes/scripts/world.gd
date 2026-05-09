extends Node2D

class_name World

var layers: Array[WorldLayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for child in get_children():
        if child is WorldLayer:
            layers.append(child)

    layers.reverse()

    for i in layers.size():
        var layer = layers[i]
        layer.depth = i
        layer.max_depth = layers.size() - 1

        if i > 0:
            layer.layer_above = layers[i-1]

        if i < layers.size() - 1:
            layer.layer_below = layers[i+1]

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        var pos = get_local_mouse_position()
        for layer in layers:
            var cell = layer.get_cell_at_local_position(pos)
            if cell == null or cell.cell_type == MapCellDefinition.CellType.Empty:
                continue
            cell.take_damage(10)
            print(layer.name, cell)
            break
