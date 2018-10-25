extends Node2D

const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const SIDING_CHANGE_SPEED = 10
var linear_vel = Vector2()
var target_vel = Vector2()
var anim=""
 
func _physics_process(delta):
	### MOVEMENT ###
	# Apply external forces
	#linear_vel += delta * EXTERNAL_FORCES
	read_input()
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	animate()
	
func read_input():
	target_vel.x = 0
	target_vel.y = 0
	if Input.is_action_pressed("ui_left"):
		target_vel.x += -1
	elif Input.is_action_pressed("ui_right"):
		target_vel.x += 1
	if Input.is_action_pressed("ui_up"):
		target_vel.y -= 1
	if Input.is_action_pressed("ui_down"):
		target_vel.y = 1

	target_vel *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_vel.x, 0.1)
	linear_vel.y = lerp(linear_vel.y, target_vel.y, 0.1)
	 
func animate():
	var new_anim = "idle"
	if(abs(linear_vel.aspect()) > 1):
		if linear_vel.x < 1:
			new_anim = "WalkLeft"
		elif linear_vel.x > 1:
			new_anim = "WalkRight"
	else:
		if linear_vel.y < 1:
			new_anim = "WalkUp"
		elif linear_vel.y > 1:
			new_anim = "WalkDown"
	if new_anim != anim:
	    anim = new_anim
	    $AnimationPlayer.play(anim)