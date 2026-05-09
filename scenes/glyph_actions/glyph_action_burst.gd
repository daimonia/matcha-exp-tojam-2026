extends BaseGlyphAction

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    sprite.play()
    audio_player.play()
    
    if current_layer:
        var cell = current_layer.get_cell_at_global_position(global_position)

        if cell:
            cell.take_damage(1000)
    else:
        push_warning('%s: no current layer specified' % name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_timer_timeout() -> void:
    pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
    pass # Replace with function body.
