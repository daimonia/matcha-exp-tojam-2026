extends RigidBody2D

class_name Totum

## the total number of faces that a totum has
const NUM_FACES = 6

## collision mask for totums
const TOTUM_COLLISION_MASK := 1 << 10

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

@onready var hp: int = max_hp:
	set(value):
		hp = value
		current_hp_changed.emit(hp)

@export var max_hp: int = 50:
	set(value):
		max_hp = value
		max_hp_changed.emit(max_hp)

@export var pull_stiffness = 60.0
@export var pull_damping = 5.0
@export var drag = 0.9
@export var shield: bool = true  #add an if statement to the damage function to prevent all damage 1 attack and set this to false
@export var hang_time_duration: float = 0.4

@onready var timer: Timer = $Timer
@onready var totum_sprite: AnimatedTotumSprite = $AnimatedTotum
@onready var toppled_click_hitbox: Area2D = $ToppledClickHitbox
@onready var physics_hitbox: CollisionShape2D = $ActivePhysicsHitbox
@onready var audio_player_spin: AudioStreamPlayer2D = $AudioPlayerSpin
@onready var audio_player_topple: AudioStreamPlayer2D = $AudioPlayerTopple
@onready var audio_player_holstered: AudioStreamPlayer2D = $AudioPlayerHolstered

var rng = RandomNumberGenerator.new()

var facing_glyph: Glyph = null

var already_attacked = false
var snapping_to_mouse = false

var current_layer_depth: int = -1
var hang_time_remaining: float = 0.0
var is_falling := false

signal state_transitioned
signal facing_glyph_updated
signal buff(totum: Totum, buff_type: BaseGlyphAction.BuffType, callback: Callable)
signal current_hp_changed
signal max_hp_changed
signal current_depth_changed

## scuffed way of communicating up the tree that somebody won the game
signal won_game


func _ready() -> void:
	transition_state(State.Holstered)


func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	if snapping_to_mouse:
		physics_state.transform.origin = get_global_mouse_position()
		physics_state.linear_velocity = Vector2.ZERO
		physics_state.angular_velocity = 0
		snapping_to_mouse = false


func _physics_process(delta: float) -> void:
	match state:
		State.Dragging:
			var displacement = get_global_mouse_position() - global_position
			apply_force(displacement * pull_stiffness - linear_velocity * pull_damping)
		State.Spinning:
			update_collision_mask(delta)
			linear_velocity *= drag
		State.Toppled:
			update_collision_mask(delta)
			linear_velocity *= drag
		_:
			linear_velocity *= drag


func transition_state(next_state: State) -> void:
	if next_state == state:
		return

	print("%s: transitioning %s -> %s" % [name, State.find_key(state), State.find_key(next_state)])

	var previous_state = state
	state = next_state

	totum_sprite.visible = state != State.Holstered

	state_transitioned.emit(state)

	match state:
		State.Holstered:
			if previous_state in [State.Attacking, State.Toppled]:
				audio_player_holstered.play()

			facing_glyph_updated.emit(null)
			totum_sprite.show_glyph(null)
			physics_hitbox.disabled = true

			current_layer_depth = -1
		State.Dragging:
			physics_hitbox.disabled = false
			snapping_to_mouse = true

			collision_mask = TOTUM_COLLISION_MASK | 1  # collide with top layer + other totums
			print("%s: collision_mask = %o" % [name, collision_mask])
		State.Dropped:
			transition_state(State.Spinning)
		State.Spinning:
			audio_player_spin.play()
			spin_start()
		State.Toppled:
			audio_player_topple.play()
			$AttackAfterToppleTimer.start()
			topple()
		State.Attacking:
			already_attacked = false
		_:
			print("%s: no state transition logic" % name)


func update_collision_mask(delta: float):
	var current_layer := get_current_layer()

	if current_layer.depth == current_layer_depth:
		return

	if current_layer_depth < 0:
		print("%s: initializing to depth %o" % [name, current_layer.depth])
		set_current_layer_depth(current_layer.depth)
		return

	if current_layer.depth < current_layer_depth:
		# somehow we have gone up
		print("%s: going up (%d -> %d)" % [name, current_layer_depth, current_layer.depth])
		set_current_layer_depth(current_layer.depth)

	if !is_falling:
		print("%s: starting hang" % name)
		is_falling = true
		hang_time_remaining = hang_time_duration

	# hang for a brief period before falling into the next layer
	hang_time_remaining -= delta
	if hang_time_remaining <= 0.0:
		is_falling = false
		print("%s: i fell down" % name)
		set_current_layer_depth(current_layer.depth)


func set_current_layer_depth(depth: int):
	current_layer_depth = depth
	collision_mask = TOTUM_COLLISION_MASK | 1 << (depth - 1)
	hang_time_remaining = 0.0

	current_depth_changed.emit(depth)


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
		attack_node.totum_that_spawned_me = self

		attack_node.attack_ended.connect(transition_state.bind(State.Holstered))

		# if the attack node emits a buff, re-emit that signal so that TotumManager can handle it
		attack_node.buff.connect(
			func(buff_type: BaseGlyphAction.BuffType, cb: Callable):
				print("%s: received buff" % name)
				print("  re-emitting ", buff_type, cb)
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


func _on_audio_stream_player_2d_finished() -> void:
	match state:
		State.Spinning:
			audio_player_spin.play()


func _on_attack_after_topple_timer_timeout() -> void:
	match state:
		State.Toppled:
			attack()
