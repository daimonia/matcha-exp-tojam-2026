extends Control

@export var play_scene: PackedScene

@onready var settings_modal = get_node("SettingsModal")

func _on_play() -> void:
    get_tree().change_scene_to_packed(play_scene)

func _on_quit() -> void:
    get_tree().quit(0)

func _toggle_settings_modal_visible() -> void:
    settings_modal.visible = !settings_modal.visible

func _on_settings_modal_submitted() -> void:
    settings_modal.visible = false
