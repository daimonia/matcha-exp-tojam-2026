extends TextureRect

class_name DroppableTotumFace

@export var blank_face_texture: Texture2D

@export var glyph: Glyph:
    set(value):
        glyph = value

        if glyph == null:
            texture = blank_face_texture
            return

        texture = glyph.texture

signal dropped_glyph(glyph: Glyph)

func set_glyph(_glyph: Glyph):
    glyph = _glyph


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    if data is not Glyph:
        return false

    return true


func _drop_data(_at_position: Vector2, data: Variant) -> void:
    set_glyph(data)
    dropped_glyph.emit(data)
