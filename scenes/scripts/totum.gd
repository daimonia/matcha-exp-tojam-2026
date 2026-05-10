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
@export var hp: int = 50

@onready var timer: Timer = $Timer
@onready var totum_sprite: AnimatedTotumSprite = $AnimatedTotum
@onready var toppled_click_hitbox: Area2D = $ToppledClickHitbox

var rng = RandomNumberGenerator.new()

var facing_glyph: Glyph = null

var already_attacked = false

signal state_transitioned
signal facing_glyph_updated
signal heal

func _ready() -> void:
    transition_state(State.Holstered)


func transition_state(next_state: State) -> void:
    if next_state == state:
        return

    print('%s: transitioning %s -> %s' % [name, State.find_key(state), State.find_key(next_state)])

    state = next_state

    totum_sprite.visible = state != State.Holstered

    state_transitioned.emit(state)

    match state:
        State.Holstered:
            facing_glyph_updated.emit(null)
            totum_sprite.show_glyph(null)
        State.Dropped:
            transition_state(State.Spinning)
        State.Spinning:
            spin_start()
        State.Toppled:
            topple()
        State.Attacking:
            already_attacked = false
        _:
            print('%s: no state transition logic' % name)


func spin_start():
    #start the timer and run the spinning animation
    timer.start()
    totum_sprite.play("spin")


func topple():
    totum_sprite.play("toppled")

    # pick which glyph we landed on
    var facing_glyph_index = rng.randi_range(0, 5)

    if facing_glyph_index > glyphs.size() - 1:
        # landed on a blank face
        return

    facing_glyph = glyphs[facing_glyph_index]
    totum_sprite.show_glyph(facing_glyph)

    facing_glyph_updated.emit(facing_glyph)


func attack():
    if state != State.Toppled or already_attacked:
        return

    if facing_glyph and facing_glyph.action_node:
        already_attacked = true
        var attack_node: BaseGlyphAction = facing_glyph.action_node.instantiate()
        assert(attack_node is BaseGlyphAction, "action node must inherit BaseGlyphAction")
        attack_node.current_layer = get_current_layer()

        add_child(attack_node)
        attack_node.connect("attack_ended", transition_state.bind(State.Holstered))
        transition_state(State.Attacking)
        if facing_glyph.name == "Heal":
            heal.emit()
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
