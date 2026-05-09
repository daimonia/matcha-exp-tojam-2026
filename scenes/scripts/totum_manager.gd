extends Node


@export var hud: HUD
@export var totums: Array[Totum]


func _ready() -> void:
    var totum_hotbars = hud.get_totum_hotbar_items()

    for i in totum_hotbars.size():
        var hotbar = totum_hotbars[i]
        var totum = totums[i]

        totum.state_transitioned.connect(hotbar.update_totum_state)

        hotbar.drag_started.connect(totum.transition_state.bind(Totum.State.Dragging))
        hotbar.drag_dropped.connect(totum.transition_state.bind(Totum.State.Dropped))
