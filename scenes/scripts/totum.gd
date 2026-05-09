@tool

extends Node2D

@export var glyphs: Array[Glyph] = []
@export var glyphVis: bool
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_update_glyph()


func _update_glyph():
	for glyph in glyphs:
		if (glyphVis == true):
			var sprite = Sprite2D.new()
			sprite.texture = glyph.texture
			add_child(sprite)

func spin_start():
	#start the timer and run the spinning animation
	timer.start()
	animation_player.play("spin")
	#print("spinning, I swears it, mistress")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# running as a tool script, so don't do anything wild
		return


func _on_timer_timeout() -> void:
	#when the timer stops, also stop the spinning animation
	animation_player.play("default")
	print("done timin things")
	
