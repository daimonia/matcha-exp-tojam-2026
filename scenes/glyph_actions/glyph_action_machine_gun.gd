extends BaseGlyphAction


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

#cardinal directions
var damage_directions: Array[Vector2] = [Vector2(0,1),Vector2(0,-1),Vector2(-1,0),Vector2(1,0)]

var rng = RandomNumberGenerator.new()
#number of bullets
var times = rng.rangei(1,3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    sprite.play()
    audio_player.play()

    if current_layer: #passed by the totum when it attacks
        var cell = current_layer.get_cell_at_global_position(global_position)
        var takeDamage: int = 0
        #check if there's a cell where the totum is and if so, deal damage
        if cell:
            takeDamage += current_layer.get_cell_at_position(cell.coords).take_damage(1000)
            
            #deal damage to the cardinal directions on same layer
            for direction in damage_directions:
                for i in times:
                    var temp = current_layer.get_cell_at_position(cell.coords + direction*i)
                    if temp:
                        takeDamage += temp.take_damage(1000)
    else:
        push_warning('%s: no current layer specified' % name)


func _on_timer_timeout() -> void:
    attack_ended.emit()
    queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
    sprite.hide()
