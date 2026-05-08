extends Camera2D


@export var max_speed: float = 1.0
@export var drag: float = 0.9

var speed: Vector2 = Vector2(0, 0)


func _process(delta: float) -> void:
    position += speed * delta
    # speed *= drag


func _input(_event: InputEvent) -> void:
    var input_velocity = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
    speed = max_speed * input_velocity
