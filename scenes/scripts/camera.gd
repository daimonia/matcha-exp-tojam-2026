extends Camera2D


@export var max_speed: float = 1.0
@export var zoom_speed: float = 0.5

@export var max_zoom: float = 4
@export var min_zoom: float = 0.1

var velocity: Vector2 = Vector2(0, 0)


func _process(delta: float) -> void:
    position += velocity * delta

    if Input.is_action_pressed("ZoomIn"):
        zoom += Vector2(zoom_speed, zoom_speed) * delta
    elif Input.is_action_pressed("ZoomOut"):
        zoom -= Vector2(zoom_speed, zoom_speed) * delta


func _input(event: InputEvent) -> void:
    var input_velocity = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
    velocity = max_speed * input_velocity
