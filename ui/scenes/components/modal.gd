@tool
extends CanvasLayer
class_name Modal

signal closed
signal submitted

@export var title: String = "Huh?":
    set(value):
        title = value
        _update_labels()

@export var cancel_label: String = "Cancel":
    set(value):
        cancel_label = value
        _update_labels()

@export var submit_label: String = "OK":
    set(value):
        submit_label = value
        _update_labels()

@export var content_scene: PackedScene:
    set(value):
        content_scene = value
        _update_content_scene()

func _ready() -> void:
    _update_content_scene()

## Set the modal content directly.
func set_content(node: Control) -> void:
    _update_content_node(node)

func _update_content_scene() -> void:
    if not is_node_ready():
        return

    if not content_scene:
        return

    var instance = content_scene.instantiate()
    assert(instance is Control, "content must be a Control node!")
    _update_content_node(instance)

func _update_content_node(node: Control) -> void:
    if not is_node_ready():
        return

    for child in %ContentSlot.get_children():
        child.queue_free()

    %ContentSlot.add_child(node)

func _update_labels() -> void:
    %TitleLabel.text = title
    %CancelButton.text = cancel_label
    %OKButton.text = submit_label

func _save() -> void:
    if Engine.is_editor_hint():
        return

    submitted.emit()


func _close() -> void:
    if Engine.is_editor_hint():
        return

    closed.emit()
