extends Node

signal player_hp
signal player_energy
signal fps

var player_hp_max = 100

var player_hp = 1 setget player_hp_emitter
var player_energy = 1 setget player_energy_emitter
var fps = 0 setget fps_emitter

func _process(_delta):
	fps = Engine.get_frames_per_second()

func player_hp_emitter(val):
	player_hp = val
	if player_hp > player_hp_max:
		player_hp = player_hp_max
	emit_signal("player_hp")

func player_energy_emitter(val):
	player_energy = val
	emit_signal("player_energy")

func fps_emitter(val):
	fps = val
	emit_signal("fps")
	print("a")