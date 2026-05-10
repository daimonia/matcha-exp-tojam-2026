extends BaseGlyphAction


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var rng = RandomNumberGenerator.new()
#choose a number of tiles to dig down
var times: int = 2

#set up an array of the 4 cardinal directions
var damage_directions: Array[Vector2] = [Vector2(0,1),Vector2(0,-1),Vector2(-1,0),Vector2(1,0)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    sprite.play()
    audio_player.play()

    if current_layer: #passed by the totum when it attacks
        var cell = current_layer.get_cell_at_global_position(global_position)
        var takeDamage: int = 0
        #check if there's a cell where the totum is and if so, deal damage
        if cell:
            #deal damage to the same tile on each layer down for each time generated
            var temp = current_layer.get_cell_at_position(cell.coords)
            for time in times:
                if temp:
                    takeDamage += temp.take_damage(1000)
                    for direction in damage_directions:
                        var tempDirection = current_layer.get_cell_at_position(cell.coords + direction)
                        takeDamage += tempDirection.take_damage(1000)
                    temp = current_layer.layer_below.get_cell_at_position(cell.coords)
        #if the totum is shielded, remove it, otherwise, deal damage to it
        if totum_that_spawned_me.shield == true:
            totum_that_spawned_me.shield = false
        elif takeDamage > 0:
            totum_that_spawned_me.hp -= takeDamage
    else:
        push_warning('%s: no current layer specified' % name)


func _on_timer_timeout() -> void:
    attack_ended.emit()
    queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
    sprite.hide()
