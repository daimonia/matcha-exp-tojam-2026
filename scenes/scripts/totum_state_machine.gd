extends Node

class_name TotumStateMachine

@export var glyphs: Array[Glyph] = [null, null, null, null, null, null]

var highlighted = false

enum State {
    Holstered,
    Dragging,
    Dropped,
    Spinning,
    Toppled
}

var state = State.Holstered:
    set(value):
        print('transitioning to %s' % [State.find_key(value)])
        state = value


func _process(_delta: float) -> void:
    match state:
        State.Holstered:
            pass
        State.Dragging:
            pass
        State.Dropped:
            pass
