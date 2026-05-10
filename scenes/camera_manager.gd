extends Node2D

@export var max_speed: float = 1000.0
@export var zoom_speed: float = 0.1

@export var max_zoom: float = 4
@export var min_zoom: float = 0.1

@onready var camera: Camera2D = $Camera2D


var velocity: Vector2 = Vector2(0, 0)


func _process(delta: float) -> void:
    global_position += velocity * delta

func _input(event: InputEvent) -> void:
    var input_velocity = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
    velocity = max_speed * input_velocity
    #global_position += velocity
    if Input.is_action_pressed("ZoomIn") && (camera.zoom < Vector2(max_zoom, max_zoom)):
        camera.zoom += Vector2(zoom_speed, zoom_speed)# * delta

    elif Input.is_action_pressed("ZoomOut") && (camera.zoom > Vector2(min_zoom, min_zoom)):
        camera.zoom -= Vector2(zoom_speed, zoom_speed)# * delta
