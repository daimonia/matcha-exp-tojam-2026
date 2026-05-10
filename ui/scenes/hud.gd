extends Control

class_name HUD


@export var totum_hotbar_items: Array[TotumHotbar]

@onready var countdown_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Countdown
@onready var totum_panel: SelectedTotumPanel = $MarginContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/SelectedTotumPanel

func get_totum_hotbar_items() -> Array[TotumHotbar]:
    return totum_hotbar_items


func set_remaining_time(time: float) -> void:
    var minutes = floor(time / 60)
    var seconds = floor(time - (minutes * 60))

    countdown_label.text = '%d:%2d' % [minutes, seconds]

func set_selected_totum(totum: Totum) -> void:
    totum_panel.set_totum(totum)
