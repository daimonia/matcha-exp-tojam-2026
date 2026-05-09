extends Node2D


var soundtrack: Soundtrack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        print(event.keycode)

        match event.physical_keycode:
            49:
                soundtrack.set_track(Soundtrack.Track.Layer1)
            50:
                soundtrack.set_track(Soundtrack.Track.Layer2)
            51:
                soundtrack.set_track(Soundtrack.Track.Layer3)
