extends Panel

class_name RewardsPanel

signal hover_started
signal hover_ended
signal finished_picking

@export var rewards: Array[Glyph]
@export var draggable_reward_scene: PackedScene  # DraggableReward

@onready var draggable_rewards_container: Container = $HBoxContainer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var num_picked: int = 0

func _ready():
    redraw_rewards()

## populate a fresh set of rewards.
func add_rewards(_rewards: Array[Glyph]):
    rewards += _rewards
    if rewards.size() > Totum.NUM_FACES:
        var new_rewards: Array[Glyph] = []

        for reward in rewards:
            if reward.name == "Goat Key":
                new_rewards.append(reward)

        if new_rewards.size() >= Totum.NUM_FACES:
            rewards = new_rewards
        else:
            while new_rewards.size() < Totum.NUM_FACES:
                new_rewards.append(rewards.pop_front())

        rewards = new_rewards
    redraw_rewards()

func redraw_rewards():
    for child in draggable_rewards_container.get_children():
        child.queue_free()

    for reward in rewards:
        var draggable: DraggableReward = draggable_reward_scene.instantiate()
        draggable.set_glyph(reward)
        draggable.drop_finished.connect(reward_used.bind(draggable, reward))
        draggable.hover_started.connect(hover_started.emit)
        draggable.hover_ended.connect(hover_ended.emit)
        draggable_rewards_container.add_child(draggable)

    if rewards.size() == 0:
        hide()
    else:
        audio_player.play()
        show()


func reset_rewards():
    rewards = []
    num_picked = 0
    redraw_rewards()


func reward_used(draggable: DraggableReward, _glyph: Glyph):
    draggable.queue_free()
    num_picked += 1
    if num_picked >= 2:
        finished_picking.emit()
