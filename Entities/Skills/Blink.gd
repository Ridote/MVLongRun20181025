extends "res://Entities/Skills/Skill.gd"

func _ready():
	cost = 50

func play(pos):
	$Sprite.position = parent.getGlobalPosition()
	parent.setGlobalPosition(pos)
	$AnimationPlayer.play("Vanish")