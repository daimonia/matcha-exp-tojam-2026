extends Node2D

class_name World

var layers: Array[WorldLayer]

@onready var soundtrack: AudioStreamPlayer = %Soundtrack

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
            print(layer.name, cell)
            if cell == null or cell.type == WorldLayer.TileCellType.Empty:
                continue
            break

        var current_clip = soundtrack.stream.get_clip_name(soundtrack.get_stream_playback().get_current_clip_index())
        match current_clip:
            "Layer1":
                soundtrack.get_stream_playback().switch_to_clip_by_name("Layer2")
            "Layer2":
                soundtrack.get_stream_playback().switch_to_clip_by_name("Layer3")
            "Layer3":
                soundtrack.get_stream_playback().switch_to_clip_by_name("Layer1")
