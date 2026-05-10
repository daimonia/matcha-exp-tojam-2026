extends RigidBody2D

class_name Totum

enum State {
    Holstered,  #can be clicked in the holster; doesn't appear in world
    Dragging,  #has been clicked; follows mouse; top view
    Dropped,  #start spinning; (set timer length) start timer; NO CLICKY
    Spinning,  #check for when it's done spinning and generate a face
    Toppled,  #can click in BOTH places (run back to dragging or glyph script)
    Attacking,  #will go back to Holstered once attack ends
}

@export var world: World

@export var state = State.Holstered:
    set(value):
        state = value

@export var glyphs: Array[Glyph] = []
@export var glyph_visible: bool
@export var hp: int = 50
@export var pull_stiffness = 60.0
@export var pull_damping = 5.0
@export var drag = 0.9

@onready var timer: Timer = $Timer
@onready var totum_sprite: AnimatedTotumSprite = $AnimatedTotum
@onready var toppled_click_hitbox: Area2D = $ToppledClickHitbox
@onready var physics_hitbox: CollisionShape2D = $ActivePhysicsHitbox

var rng = RandomNumberGenerator.new()

var facing_glyph: Glyph = null

var already_attacked = false
var snapping_to_mouse = false

signal state_transitioned
signal facing_glyph_updated
signal buff(totum: Totum, buff_type: BaseGlyphAction.BuffType, callback: Callable)


func _ready() -> void:
    transition_state(State.Holstered)


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
    if snapping_to_mouse:
        physics_state.transform.origin = get_global_mouse_position()
        physics_state.linear_velocity = Vector2.ZERO
        physics_state.angular_velocity = 0
        snapping_to_mouse = false


func _physics_process(_delta: float) -> void:
    match state:
        State.Dragging:
            var displacement = get_global_mouse_position() - global_position
            apply_force(displacement * pull_stiffness - linear_velocity * pull_damping)
        _:
            linear_velocity *= drag


func transition_state(next_state: State) -> void:
    if next_state == state:
        return

    print("%s: transitioning %s -> %s" % [name, State.find_key(state), State.find_key(next_state)])

    state = next_state

    totum_sprite.visible = state != State.Holstered

    state_transitioned.emit(state)

    match state:
        State.Holstered:
            facing_glyph_updated.emit(null)
            totum_sprite.show_glyph(null)
            physics_hitbox.disabled = true
        State.Dragging:
            physics_hitbox.disabled = false
            snapping_to_mouse = true
        State.Dropped:
            transition_state(State.Spinning)
        State.Spinning:
            spin_start()
        State.Toppled:
            topple()
        State.Attacking:
            already_attacked = false
        _:
            print("%s: no state transition logic" % name)


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

        attack_node.attack_ended.connect(transition_state.bind(State.Holstered))

        # if the attack node emits a buff, re-emit that signal so that TotumManager can handle it
        attack_node.buff.connect(
            func(buff_type: BaseGlyphAction.BuffType, cb: Callable):
                print('%s: received buff' % name)
                print('  re-emitting ', buff_type, cb)
                buff.emit(self, buff_type, cb)
        )

        add_child(attack_node)
        transition_state(State.Attacking)
    else:
        transition_state(State.Holstered)


func get_current_layer() -> WorldLayer:
    for layer in world.layers:
        var cell = layer.get_cell_at_global_position(global_position)
        if cell != null and cell.cell_type != MapCellDefinition.CellType.Empty:
            return layer  #.layer_above  testing with just returning as is

    assert(false, "failed to locate layer at global position %v" % global_position)
    return null


func _on_timer_timeout() -> void:
    #when the timer stops, also stop the spinning animation
    transition_state(State.Toppled)


func _on_toppled_click_hitbox_input_event(
    _viewport: Node, event: InputEvent, _shape_idx: int
) -> void:
    # TODO controller lol
    if event is InputEventMouseButton and event.is_pressed():
        attack()
