extends TextureRect

class_name DraggableReward

signal hover_started
signal hover_ended
signal drop_finished

@export var glyph: Glyph:
    set(value):
        glyph = value

        if glyph == null:
            hide()
            return

        show()
        texture = glyph.texture

var is_dragging = false

func set_glyph(_glyph: Glyph):
    glyph = _glyph

func _get_drag_data(_at_position: Vector2) -> Variant:
    if glyph == null:
        return null

    var preview = TextureRect.new()
    preview.texture = glyph.texture
    preview.size = Vector2(32, 32)
    set_drag_preview(preview)

    is_dragging = true

    return glyph


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_DRAG_END:
            if is_dragging and get_viewport().gui_is_drag_successful():
                is_dragging = false
                drop_finished.emit()


func _on_mouse_entered() -> void:
    hover_started.emit(glyph)


func _on_mouse_exited() -> void:
    hover_ended.emit()
