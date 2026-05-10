extends Node2D

class_name Play


@onready var timer: Timer = $GameTimer
@onready var hud: HUD = $CanvasLayer/HUD

var soundtrack: Soundtrack

signal quit_to_main_menu


func _process(_delta: float) -> void:
    hud.set_remaining_time(timer.time_left)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
    if event.is_action("EndGame") and event.is_pressed() and not event.is_echo():
        if $CanvasLayer/GameEnd.visible:
            # if the menu is already up, pressing esc again quits the game
            get_tree().quit()

        end_game(false)
        return

    if event is InputEventKey:
        match event.physical_keycode:
            49:
                soundtrack.set_track(Soundtrack.Track.Layer1)
            50:
                soundtrack.set_track(Soundtrack.Track.Layer2)
            51:
                soundtrack.set_track(Soundtrack.Track.Layer3)


func _on_game_timer_timeout() -> void:
    end_game(false)


func _on_game_end_go_to_main_menu() -> void:
    quit_to_main_menu.emit()


func _on_totum_manager_won_game() -> void:
    end_game(true)


func end_game(did_win: bool) -> void:
    timer.stop()
    hud.hide()
    $CanvasLayer/GameEnd.did_win = did_win
    $CanvasLayer/GameEnd.show()
