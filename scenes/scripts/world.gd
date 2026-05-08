extends Node2D

class_name World

var layers: Array[WorldLayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for child in get_children():
        if child is WorldLayer:
            layers.append(child)

    layers.reverse()


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.double_click:
        var pos = get_local_mouse_position()
        for layer in layers:
            var cell = layer.get_cell_at_local_position(pos)
            if cell == null or cell.type == WorldLayer.TileCellType.Empty:
                continue
            print(layer.name, cell)
            break
