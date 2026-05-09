extends Node2D

class_name Totum

enum State {
    Holstered,  #can be clicked in the holster; doesn't appear in world
    Dragging,   #has been clicked; follows mouse; top view
    Dropped,    #start spinning; (set timer length) start timer; NO CLICKY
    Spinning,   #check for when it's done spinning and generate a face
    Toppled,     #can click in BOTH places (run back to dragging or glyph script)
    Attacking,     #will go back to Holstered once attack ends
}

@export var world: World

@export var state = State.Holstered:
    set(value):
        state = value

@export var glyphs: Array[Glyph] = []
@export var glyph_visible: bool

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var toppled_click_hitbox: Area2D = $ToppledClickHitbox

var facing_glyph_index: int = 0

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

    state = next_state

    animated_sprite_2d.visible = state != State.Holstered

    state_transitioned.emit(state)

    match state:
        State.Dropped:
            transition_state(State.Spinning)
        State.Spinning:
            spin_start()
        State.Toppled:
            topple()
        _:
            print('%s: no state transition logic' % name)


func spin_start():
    #start the timer and run the spinning animation
    timer.start()
    animated_sprite_2d.play("spin")


func topple():
    animation_player.play("toppled")


func attack():
    var facing_glyph = glyphs[facing_glyph_index]

    if facing_glyph.action_node:
        var attack_node: BaseGlyphAction = facing_glyph.action_node.instantiate()
        assert(attack_node is BaseGlyphAction, "action node must inherit BaseGlyphAction")
        attack_node.current_layer = get_current_layer()

        add_child(attack_node)
        attack_node.connect("attack_ended", transition_state.bind(State.Holstered))
        transition_state(State.Attacking)
    else:
        transition_state(State.Holstered)


func get_current_layer() -> WorldLayer:
    for layer in world.layers:
        var cell = layer.get_cell_at_global_position(global_position)
        if cell != null and cell.cell_type != MapCellDefinition.CellType.Empty:
            return layer #.layer_above  testing with just returning as is

    assert(false, "failed to locate layer at global position %v" % global_position)
    return null


func _process(_delta: float) -> void:
    match state:
        State.Dragging:
            global_position = get_global_mouse_position()


func _on_timer_timeout() -> void:
    #when the timer stops, also stop the spinning animation
    transition_state(State.Toppled)


func _on_toppled_click_hitbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    # TODO controller lol
    if event is InputEventMouseButton and event.is_pressed():
        attack()
