@tool

extends Control

@export var glyphs: Array[Glyph] = []

@onready var totum_sprite = %TotumSprite
@onready var world_totum: Node2D = $Totum


enum State {InHotbar, Hovering, Dragging, Dropped}

var state = State.InHotbar:
    set(value):
        print('transitioning to %s' % [State.find_key(value)])
        state = value


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
            world_totum.position = get_local_mouse_position()
        State.Dropped:
            world_totum.spin_start()
            state = State.InHotbar


func _input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    if event is InputEventMouseButton:
        if event.is_pressed() and state == State.Hovering:
            state = State.Dragging
            world_totum.visible = true
        elif event.is_released() and state == State.Dragging:
            state = State.Dropped


func _on_mouse_entered() -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    print('%s - entered' % [self])

    match state:
        State.InHotbar:
            state = State.Hovering


func _on_mouse_exited() -> void:
    if Engine.is_editor_hint():
        # running as a tool script, so don't do anything wild
        return

    match state:
        State.Hovering:
            state = State.InHotbar
