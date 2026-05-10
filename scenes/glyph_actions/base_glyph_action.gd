extends Node2D

class_name BaseGlyphAction

@export var current_layer: WorldLayer
@export var totum_that_spawned_me: Totum

signal attack_ended
signal buff


enum BuffType { Goated, Heal, HpUp, DefUp }
