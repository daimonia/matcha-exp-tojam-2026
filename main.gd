extends Node2D

@export var play_scene: PackedScene

@onready var menu: Node = %Menu
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var active_play_scene: Node


func _on_main_menu_play_game() -> void:
    active_play_scene = play_scene.instantiate()
    active_play_scene.connect("quit_to_main_menu", _on_play_quit_to_main_menu)
    active_play_scene.soundtrack = $Soundtrack

    remove_child(menu)
    add_child(active_play_scene)
    audio_player.play()


func _on_play_quit_to_main_menu() -> void:
    active_play_scene.queue_free()
    add_child(menu)
    $Soundtrack.set_track(Soundtrack.Track.Layer1)
