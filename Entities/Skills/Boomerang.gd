extends "res://Entities/Skills/Skill.gd"

const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const SIDING_CHANGE_SPEED = 10
const STOP_ANIMATION_THRESHOLD = 15

const EXTERNAL_IMPULSE = 4000
const IMPULSE_MITIGATION_FACTOR = 2

const MAX_SPEED_AND_IMPULSE = 400

var direction = Vector2(0, 0)
var target_vel = Vector2(0, 0)
var linear_vel = Vector2(0, 0)

var backing = false

func _physics_process(_delta):
	move()
	process_collisions()
	
func move():
	target_vel *= WALK_SPEED
	
	linear_vel.x = lerp(linear_vel.x, target_vel.x, 0.1)
	linear_vel.y = lerp(linear_vel.y, target_vel.y, 0.1)
	
	#We clamp the linear velocity
	linear_vel = linear_vel.clamped(MAX_SPEED_AND_IMPULSE)
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)

func process_collisions():
	#We won't collide when backing
	var collider = null
	for i in range($body.get_slide_count()):
		collider = $body.get_slide_collision(i).get_collider().get_parent()
		if(collider.is_in_group(Constants.G_PLAYER) && backing):
			queue_free()
		if(collider.is_in_group(Constants.G_ENEMY)):
			collider.process_external_collision(self)
			backing = true

func play(pos):
	$body.global_position = pos
	direction = ($body.global_pos - parent.getGlobalPosition()).normalized()