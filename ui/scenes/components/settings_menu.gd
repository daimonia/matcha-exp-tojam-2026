@tool
extends VBoxContainer

@export_tool_button("Repaint") var repaint = _create_action_list

@export var input_button_scene: PackedScene = preload("res://ui/scenes/components/rebind_input_button.tscn")

var is_remapping = false
var action_to_remap: StringName = ""
var remapping_button: Button = null

const input_actions = {
    "move up": "Move Up",
    "move down": "Move Down",
    "move left": "Move Left",
    "move right": "Move Right",
    "jump": "Jump"
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _create_action_list()


func _input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        return

    if !is_remapping:
        return

    if (
        event is InputEventKey ||
        (event is InputEventMouseButton && event.pressed)
    ):
        if event is InputEventMouseButton and event.double_click:
            event.double_click = false

        InputMap.action_erase_events(action_to_remap)
        InputMap.action_add_event(action_to_remap, event)
        _update_action_list(remapping_button, event)

        is_remapping = false
        action_to_remap = ""
        remapping_button = null

        accept_event()


func _create_action_list() -> void:
    InputMap.load_from_project_settings()
    for item in %ActionList.get_children():
        item.queue_free()

    for action in InputMap.get_actions():
        if action not in input_actions:
            continue

        var button = input_button_scene.instantiate()
        var action_label = button.find_child("ActionLabel")
        var input_label = button.find_child("InputLabel")

        action_label.text = action

        var events = InputMap.action_get_events(action)
        if events.size() > 0:
            input_label.text = events[0].as_text().trim_suffix("- Physical")
        else:
            input_label.text = ""

        %ActionList.add_child(button)
        button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _update_action_list(button: Button, event: InputEvent) -> void:
    button.find_child("InputLabel").text = event.as_text().trim_suffix("- Physical")


func _on_input_button_pressed(button: Button, action: StringName) -> void:
    if !is_remapping:
        is_remapping = true
        action_to_remap = action
        remapping_button = button
        button.find_child("InputLabel").text = "Press a key..."


func _on_reset_to_default_pressed() -> void:
    InputMap.load_from_project_settings()
    _create_action_list()
