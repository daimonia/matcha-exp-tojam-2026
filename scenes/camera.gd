extends Camera2D


@export var max_speed: float = 1.0
@export var zoom_speed: float = 0.1

var velocity: Vector2 = Vector2(0, 0)
var zoom_velocity: Vector2 = Vector2(0, 0)


func _process(delta: float) -> void:
    position += velocity * delta
    zoom += zoom_velocity * delta


func _input(event: InputEvent) -> void:
    var input_velocity = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
    velocity = max_speed * input_velocity

    if event.is_action_pressed("ZoomIn"):
        zoom_velocity = Vector2(zoom_speed, zoom_speed)
    elif event.is_action_pressed("ZoomOut"):
        zoom_velocity = -Vector2(zoom_speed, zoom_speed)
    else:
        zoom_velocity = Vector2.ZERO
