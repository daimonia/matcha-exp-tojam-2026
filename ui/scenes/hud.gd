extends Control

class_name HUD


@export var totum_hotbar_items: Array[TotumHotbar]

@onready var countdown_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Countdown
@onready var totum_panel: SelectedTotumPanel = $MarginContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/SelectedTotumPanel
@onready var rewards_panel: RewardsPanel = $MarginContainer/Panel/MarginContainer/VBoxContainer/MarginContainer/RewardsPanel
@onready var glyph_name_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/GlyphNameLabel
@onready var glyph_description_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/GlyphDescriptionLabel

signal picked_all_rewards


func populate_rewards(rewards: Array[Glyph]):
    rewards_panel.populate_rewards(rewards)


func get_totum_hotbar_items() -> Array[TotumHotbar]:
    return totum_hotbar_items


func set_remaining_time(time: float) -> void:
    var minutes = floor(time / 60)
    var seconds = floor(time - (minutes * 60))

    countdown_label.text = '%d:%02d' % [minutes, seconds]


func set_selected_totum(totum: Totum) -> void:
    totum_panel.set_totum(totum)


func _on_rewards_panel_finished_picking() -> void:
    populate_rewards([])
    picked_all_rewards.emit()


func show_glyph_description(glyph: Glyph):
    if glyph == null:
        glyph_name_label.text = ''
        glyph_description_label.text = ''
        return

    glyph_name_label.text = glyph.name
    glyph_description_label.text = glyph.description


func _on_selected_totum_panel_hover_started(glyph: Glyph) -> void:
    show_glyph_description(glyph)

func _on_selected_totum_panel_hover_ended() -> void:
    show_glyph_description(null)

func _on_rewards_panel_hover_started(glyph: Glyph) -> void:
    show_glyph_description(glyph)

func _on_rewards_panel_hover_ended() -> void:
    show_glyph_description(null)
