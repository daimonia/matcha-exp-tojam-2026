@tool

extends Node2D

@export var glyphs: Array[Glyph] = []


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
