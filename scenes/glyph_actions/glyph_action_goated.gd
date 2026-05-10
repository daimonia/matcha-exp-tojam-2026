extends BaseGlyphAction


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


#var damage_directions: Array[Vector2] = [Vector2(0,1),Vector2(0,-1),Vector2(-1,0),Vector2(1,0)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    sprite.play()
    audio_player.play()

    if current_layer: #passed by the totum when it attacks
        print('%s: emitting buff' % name)
        buff.emit(BaseGlyphAction.BuffType.Goated, on_goat)
    else:
        push_warning('%s: no current layer specified' % name)

func on_goat(totum: Totum):
    print('on_goat', totum)

    var goats_collected: int = 0
    #check if the entire teetotum is covered in goat glyphs
    for glyph in totum.glyphs:
        #check if there's a glyph and if that glyph is a goat
        if (glyph != null) && (glyph.name == "Goat Key"):
            goats_collected += 1
            print("goats collected: " + str(goats_collected) + " / " + str(totum.glyphs.size()))
    # if goats_collected == Totum.NUM_FACES:
    if goats_collected > 0:  # for demo purposes
        totum.won_game.emit()

func _on_timer_timeout() -> void:
    attack_ended.emit()
    queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
    sprite.hide()
