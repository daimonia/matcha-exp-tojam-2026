extends Node2D

class_name Totum

enum State {
    Holstered,  #can be clicked in the holster; doesn't appear in world
    Dragging,   #has been clicked; follows mouse; top view
    Dropped,    #start spinning; (set timer length) start timer; NO CLICKY
    Spinning,   #check for when it's done spinning and generate a face
    Toppled     #can click in BOTH places (run back to dragging or glyph script)
}

@export var state = State.Holstered:
    set(value):
        state = value

@export var glyphs: Array[Glyph] = []
@export var glyph_visible: bool

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

signal state_transitioned

func _ready() -> void:
    _update_glyph()
    transition_state(State.Holstered)


func _update_glyph():
    for glyph in glyphs:
        if (glyph_visible == true):
            var sprite = Sprite2D.new()
            sprite.texture = glyph.texture
            add_child(sprite)


func transition_state(next_state: State) -> void:
    if next_state == state:
        return

    print('%s: transitioning %s -> %s' % [name, State.find_key(state), State.find_key(next_state)])

    var previous_state = state
    state = next_state

    animated_sprite_2d.visible = state != State.Holstered

    state_transitioned.emit(state)

    match [previous_state, state]:
        [_, State.Dropped]:
            transition_state(State.Spinning)
        [_, State.Spinning]:
            spin_start()
        [_, State.Toppled]:
            topple()
        _:
            print('%s: no state transition logic' % name)


func spin_start():
    #start the timer and run the spinning animation
    timer.start()
    animated_sprite_2d.play("spin")


func topple():
    animation_player.play("toppled")


func _process(_delta: float) -> void:
    match state:
        State.Dragging:
            global_position = get_global_mouse_position()


func _on_timer_timeout() -> void:
    #when the timer stops, also stop the spinning animation
    transition_state(State.Toppled)
