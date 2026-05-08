extends Control

@export var play_scene: PackedScene

@onready var settings_modal = get_node("SettingsModal")

func _on_play() -> void:
    var parent = get_parent()

    parent.remove_child(%Menu)

    var play = play_scene.instantiate()
    play.soundtrack = %Soundtrack
    parent.add_child(play)

func _on_quit() -> void:
    get_tree().quit(0)

func _toggle_settings_modal_visible() -> void:
    settings_modal.visible = !settings_modal.visible

func _on_settings_modal_submitted() -> void:
    settings_modal.visible = false
