extends "res://Entities/Skills/Skill.gd"

func _ready():
	cost = 50

func play(pos):
	parent.setGlobalPosition(pos)
	queue_free()