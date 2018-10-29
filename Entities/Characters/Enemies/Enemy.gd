extends "res://Entities/Characters/Character.gd"

func _ready():
	add_to_group(Constants.G_ENEMY, true)

func releaseLoot():
	OS.alert(get_name() + " releaseLoot not implemented", "Implementation error")