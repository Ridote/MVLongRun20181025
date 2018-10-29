extends Node

func _ready():
	add_to_group(Constants.G_CHARACTER, true)

#float, float, first element in the tree (Node2D with script)
func receiveDmg(_fis, _mag, _source):
	print(get_groups())
	OS.alert(get_name() + " receiveDmg not implemented", "Implementation error")

func applyForce(_force, _source):
	OS.alert(get_name() + " applyForce not implemented", "Implementation error")

func process_collisions():
	OS.alert(get_name() + " process_collisions not implemented", "Implementation error")

func process_external_collision(_collider):
	OS.alert(get_name() + "process_external_collision not implemented", "Implementation error")

func getGlobalPosition():
	OS.alert(get_name() + "getGlobalPosition not implemented", "Implementation error")

func setGlobalPosition(_newPos):
	OS.alert(get_name() + "setGlobalPosition not implemented", "Implementation error")