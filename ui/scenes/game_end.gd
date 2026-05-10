extends Control

signal go_to_main_menu

@onready var won_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/YouWonLabel
@onready var lose_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/YouLoseLabel

var did_win: bool = false:
    set(value):
        did_win = value
        if did_win:
            won_label.show()
            lose_label.hide()
        else:
            lose_label.show()
            won_label.hide()

func _on_go_to_menu_pressed() -> void:
    go_to_main_menu.emit()
