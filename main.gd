extends Node2D

@export var play_scene: PackedScene


func _on_main_menu_play_game() -> void:
    var play = play_scene.instantiate()
    play.soundtrack = $Soundtrack

    remove_child(%Menu)
    add_child(play)
