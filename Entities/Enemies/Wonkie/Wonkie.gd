extends "res://Entities/Enemies/Enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Wonkie", true)
	receiveDmg(0,0,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
