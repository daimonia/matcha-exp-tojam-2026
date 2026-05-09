extends BaseGlyphAction


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    assert(current_layer != null, "current_layer is null")

    current_layer.get_cell_at_global_position(global_position).take_damage(1000)


func _on_timer_timeout() -> void:
    attack_ended.emit()
    queue_free()
