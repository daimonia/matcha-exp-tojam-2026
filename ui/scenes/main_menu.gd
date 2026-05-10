extends Control

signal play_game

@onready var settings_modal = get_node("SettingsModal")
@onready var audio_player_splash = $AudioPlayerSplash

func _ready() -> void:
    audio_player_splash.play()

func _on_play() -> void:
    play_game.emit()

func _on_quit() -> void:
    get_tree().quit(0)

func _toggle_settings_modal_visible() -> void:
    settings_modal.visible = !settings_modal.visible

func _on_settings_modal_submitted() -> void:
    settings_modal.visible = false
