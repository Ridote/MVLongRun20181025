#warnings-disable

extends Node

signal player_hp
signal player_energy

var player_hp_max = 100
var player_energy_max = 100

var player_energy_recovery = 1
var player_hp_recovery = 0.1

var player_hp = 1 setget player_hp_emitter
var player_energy = 1 setget player_energy_emitter

func player_hp_emitter(val):
	player_hp = val
	if player_hp > player_hp_max:
		player_hp = player_hp_max
	elif player_hp < 0:
		player_hp = 0
	emit_signal("player_hp")

func player_energy_emitter(val):
	player_energy = val
	if player_energy > player_energy_max:
		player_energy = player_energy_max
	elif player_energy < 0:
		player_energy = 0
	emit_signal("player_energy")