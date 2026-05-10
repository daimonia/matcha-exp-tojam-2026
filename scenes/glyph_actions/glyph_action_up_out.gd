extends BaseGlyphAction

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var damage_directions_first: Array[Vector2] = [
     Vector2(0,1),
     Vector2(0,-1),
     Vector2(-1,0),
     Vector2(1,0),
     Vector2(1,1),
     Vector2(1,-1),
     Vector2(-1,1),
     Vector2(-1,-1)
    ]
var damage_directions_second: Array[Vector2] = [
     Vector2(0,2),
     Vector2(0,-2),
     Vector2(-2,0),
     Vector2(2,0),
     Vector2(2,2),
     Vector2(2,-2),
     Vector2(-2,2),
     Vector2(-2,-2),
     Vector2(2,1),
     Vector2(2,-1),
     Vector2(-1,2),
     Vector2(1,2),
     Vector2(-2,1),
     Vector2(-2,-1),
     Vector2(-1,-2),
     Vector2(-1,-2)
    ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    sprite.play()
    audio_player.play()
    
    if current_layer.layer_above:
        var cell = current_layer.layer_above.get_cell_at_global_position(global_position)
        var takeDamage: int = 0

        #check if there's a cell where the totum is and if so, deal damage
        if cell:
            takeDamage += current_layer.layer_above.get_cell_at_position(cell.coords).take_damage(1000)
            #deal damage to the layer above
            for direction in damage_directions_first:
                var temp = current_layer.layer_above.get_cell_at_position(cell.coords + direction)
                if temp:
                    takeDamage += temp.take_damage(1000)
                    #check if there's a layer above the above layer and if so, do an even bigger attack
            if current_layer.layer_above.layer_above:
                takeDamage += current_layer.layer_above.layer_above.get_cell_at_position(cell.coords).take_damage(1000)
                for direction in damage_directions_first:
                    var temp = current_layer.layer_above.layer_above.get_cell_at_position(cell.coords + direction)
                    if temp:
                        takeDamage += temp.take_damage(1000)
                for direction in damage_directions_second:
                    var temp = current_layer.layer_above.layer_above.get_cell_at_position(cell.coords + direction)
                    if temp:
                        takeDamage += temp.take_damage(1000)
            else:
                push_warning('%s: no additional above layer specified' % name)
    else:
        push_warning('%s: no above layer specified' % name)



func _on_timer_timeout() -> void:
    attack_ended.emit()
    queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
    sprite.hide()
