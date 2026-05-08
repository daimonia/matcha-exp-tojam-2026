@tool

extends Node2D

@export var glyphs: Array[Glyph] = []

@onready var starting_position = position


enum State {InHotbar, Dragging, Dropped}

var state = State.InHotbar


func _ready() -> void:
    _update_glyph()


func _update_glyph():
    for glyph in glyphs:
        var sprite = Sprite2D.new()
        sprite.texture = glyph.texture
        add_child(sprite)


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    match state:
        State.Dragging:
            position = get_local_mouse_position()
        State.Dropped:
            position = starting_position
            state = State.InHotbar


func _input(event: InputEvent) -> void:
    if event is InputEventMouse:
        if event.is_pressed:
            state = State.Dragging
        else:
            state = State.Dropped
