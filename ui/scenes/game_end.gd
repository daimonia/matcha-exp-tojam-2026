extends Control

signal go_to_main_menu

func _on_go_to_menu_pressed() -> void:
    go_to_main_menu.emit()
