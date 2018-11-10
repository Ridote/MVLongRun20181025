extends Node

var parent = null
var cost = 5
var magDmg = 0
var fisDmg = 0

func _ready():
	add_to_group(Constants.G_SKILL)

func assign_parent(node):
	parent = node

func play(_arg):
	pass

func getCost():
	return cost

func getMagDmg():
	return magDmg
func getFisDmg():
	return fisDmg
	
func getGlobalPosition():
	OS.alert(get_name() + "getGlobalPosition not implemented", "Implementation error")

func setGlobalPosition(_newPos):
	OS.alert(get_name() + "setGlobalPosition not implemented", "Implementation error")