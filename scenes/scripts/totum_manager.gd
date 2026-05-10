extends Node


@export var hud: HUD
@export var totums: Array[Totum]

var selected_totum: Totum = null

func _ready() -> void:
    var totum_hotbars = hud.get_totum_hotbar_items()

    for i in totum_hotbars.size():
        var hotbar = totum_hotbars[i]
        var totum = totums[i]

        totum.state_transitioned.connect(hotbar.update_totum_state)
        totum.facing_glyph_updated.connect(hotbar.update_totum_glyph)
        totum.buff.connect(_on_buff_triggered)

        hotbar.drag_started.connect(totum.transition_state.bind(Totum.State.Dragging))
        hotbar.drag_started.connect(_on_select_totum.bind(hotbar, totum))
        hotbar.drag_dropped.connect(totum.transition_state.bind(Totum.State.Dropped))
        hotbar.drag_canceled.connect(totum.transition_state.bind(Totum.State.Holstered))


func _on_buff_triggered(_triggering_totum: Totum, callback: Callable):
    for totum in totums:
        callback.call(totum)


func _on_select_totum(hotbar_item: TotumHotbar, totum: Totum) -> void:
    selected_totum = totum

    for item in hud.get_totum_hotbar_items():
        item.is_selected = false

    hotbar_item.is_selected = true
    hud.set_selected_totum(totum)
