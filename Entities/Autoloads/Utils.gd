extends Node

signal fps
var fps = 0 setget fps_emitter

func fps_emitter(val):
	fps = val
	emit_signal("fps")

func calculateRandomPosition(source, maxDistance, minDistance = 0):
	var distance = maxDistance-minDistance
	var x = randi()%distance*2 - distance + minDistance
	var y = randi()%distance*2 - distance + minDistance
	return (source + Vector2(x, y))