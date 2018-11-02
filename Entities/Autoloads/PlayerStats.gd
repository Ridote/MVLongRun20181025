extends Node

signal player_hp
signal player_energy
signal fps

var player_hp = 100 setget player_hp_emitter
var player_mana = 100 setget player_energy_emitter
var fps = 0 setget fps_emitter

func _process(delta):
	fps = Engine.get_frames_per_second()

func player_hp_emitter(val):
	player_hp = val
	emit_signal("player_hp")

func player_energy_emitter(val):
	player_mana = val
	emit_signal("player_energy")

func fps_emitter(val):
	fps = val
	emit_signal("fps")