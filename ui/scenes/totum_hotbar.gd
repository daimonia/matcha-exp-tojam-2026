@tool

class_name TotumHotbar

extends Control

@export var current_totum_state: Totum.State

@export var current_totum_hp: int:
    set(value):
        current_totum_hp = value
        update_hp_bar()

@export var current_totum_max_hp: int:
    set(value):
        current_totum_max_hp = max(value, 1)
        update_hp_bar()

@export var is_selected: bool

@onready var totum_sprite: AnimatedTotumSprite = $AnimatedTotumSprite
@onready var hp_bar: ProgressBar = $MarginContainer/HealthBar

signal drag_started
signal drag_dropped
signal drag_canceled


var is_hovering = false
var is_dragging = false


func _ready() -> void:
    assert(current_totum_state != null, "no state no hotbar >:(")
    update_hp_bar()


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    if is_selected:
        $Highlight.show()
    else:
        $Highlight.hide()


func _input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    var is_allowed_to_start_drag = current_totum_state == Totum.State.Holstered

    if event is InputEventMouseButton:
        if event.is_pressed() and is_hovering and is_allowed_to_start_drag:
            is_dragging = true
            drag_started.emit()
        elif event.is_released() and is_dragging:
            is_dragging = false
            if is_hovering:
                # if the mouse is over the hotbar, cancel the drag
                drag_canceled.emit()
            else:
                drag_dropped.emit()



func update_totum_state(state: Totum.State) -> void:
    current_totum_state = state

    match current_totum_state:
        Totum.State.Spinning:
            totum_sprite.play("spin_hotbar")
        Totum.State.Toppled:
            totum_sprite.play("toppled")
        _:
            totum_sprite.play("holstered_hotbar")

func update_totum_hp(hp: int) -> void:
    current_totum_hp = hp

func update_totum_max_hp(max_hp: int) -> void:
    current_totum_max_hp = max_hp

func update_hp_bar() -> void:
    if hp_bar == null:
        return

    hp_bar.max_value = current_totum_max_hp
    hp_bar.value = current_totum_hp

func update_totum_glyph(glyph: Glyph) -> void:
    totum_sprite.show_glyph(glyph)


func _on_mouse_entered() -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    is_hovering = true


func _on_mouse_exited() -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    is_hovering = false
