extends HBoxContainer

class_name SelectedTotumPanel


@export var blank_face_texture: Texture2D
@export var totum: Totum

func _ready():
    set_totum(totum)

func set_totum(_totum: Totum) -> void:
    totum = _totum

    if totum == null:
        hide()
        return
    else:
        show()

    var rects: Array[TextureRect]

    for child in get_children():
        if child is TextureRect:
            rects.append(child)

    for i in range(6):
        if i > totum.glyphs.size() - 1:
            rects[i].texture = blank_face_texture
            continue
        var glyph = totum.glyphs[i]
        rects[i].texture = glyph.texture
