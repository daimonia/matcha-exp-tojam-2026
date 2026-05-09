extends BaseGlyphAction


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.



func _on_timer_timeout() -> void:
    attack_ended.emit()
    queue_free()
