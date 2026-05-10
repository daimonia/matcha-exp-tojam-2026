extends HBoxContainer

class_name SelectedTotumPanel


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

    var droppable_faces: Array[DroppableTotumFace]

    for child in get_children():
        if child is DroppableTotumFace:
            droppable_faces.append(child)

    for i in range(6):
        if i > totum.glyphs.size() - 1:
            droppable_faces[i].set_glyph(null)
            continue

        var glyph = totum.glyphs[i]
        droppable_faces[i].set_glyph(glyph)

        droppable_faces[i].dropped_glyph.connect(
            func(glyph: Glyph):
                totum.glyphs[i] = glyph
        )
