extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed():
            $Totum.transition_state(Totum.State.Dragging)
        elif event.is_released():
            $Totum.transition_state(Totum.State.Holstered)
