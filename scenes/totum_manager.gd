extends Node


@onready var totums: Array[TotumStateMachine] = [
    TotumStateMachine.new(),
    TotumStateMachine.new(),
    TotumStateMachine.new(),
    TotumStateMachine.new(),
]


func _ready() -> void:
    pass


func _process(delta: float) -> void:
    pass
