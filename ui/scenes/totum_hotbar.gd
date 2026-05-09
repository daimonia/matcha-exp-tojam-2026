@tool

class_name TotumHotbar

extends Control

@export var current_totum_state: Totum.State

@onready var totum_sprite = %TotumSprite

signal drag_started
signal drag_dropped


var is_hovering = false
var is_dragging = false


func _ready() -> void:
    assert(current_totum_state != null, "no state no hotbar >:(")


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return


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
            drag_dropped.emit()


func update_totum_state(state: Totum.State) -> void:
    current_totum_state = state


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
