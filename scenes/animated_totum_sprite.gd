extends AnimatedSprite2D

class_name AnimatedTotumSprite

func show_glyph(glyph: Glyph) -> void:
    if glyph == null:
        $ToppledGlyphSprite.hide()
        return

    $ToppledGlyphSprite.texture = glyph.texture
    $ToppledGlyphSprite.show()
