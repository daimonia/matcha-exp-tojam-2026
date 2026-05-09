extends Control

class_name HUD


@onready var countdown_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Countdown


@export var totum_hotbar_items: Array[TotumHotbar]


func get_totum_hotbar_items() -> Array[TotumHotbar]:
    return totum_hotbar_items


func set_remaining_time(time: float) -> void:
    var minutes = floor(time / 60)
    var seconds = floor(time - (minutes * 60))

    countdown_label.text = '%d:%d' % [minutes, seconds]
