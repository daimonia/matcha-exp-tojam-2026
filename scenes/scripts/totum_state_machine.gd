extends Node

class_name TotumStateMachine

@export var glyphs: Array[Glyph] = [null, null, null, null, null, null]

var highlighted = false

enum State {
    Holstered,  #can be clicked in the holster; doesn't appear in world
    Dragging,   #has been clicked; follows mouse; top view
    Dropped,    #start spinning; (set timer length) start timer; NO CLICKY
    Spinning,   #check for when it's done spinning and generate a face
    Toppled     #can click in BOTH places (run back to dragging or glyph script)
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
