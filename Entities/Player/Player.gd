extends Node2D

const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const SIDING_CHANGE_SPEED = 10
const STOP_ANIMATION_THRESHOLD = 15

const EXTERNAL_IMPULSE = 4000
const IMPULSE_MITIGATION_FACTOR = 2

var linear_vel = Vector2()
var target_vel = Vector2()
var prev_anim=""

var externalImpulse = Vector2()

func _ready():
	add_to_group(Constants.G_PLAYER)
	$AnimationPlayer.play("IdleDown")
	
func _physics_process(_delta):
	### MOVEMENT ###
	# Apply external forces
	#linear_vel += delta * EXTERNAL_FORCES
	read_input()
	move(_delta)
	process_collisions()
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
		
func move(_delta):
	target_vel *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_vel.x + externalImpulse.x, 0.1)
	linear_vel.y = lerp(linear_vel.y, target_vel.y + externalImpulse.y, 0.1)
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	externalImpulse /= IMPULSE_MITIGATION_FACTOR
func animate():
	var anim = ""
	var idle = false
	if(abs(linear_vel.aspect()) > 1):
		if linear_vel.x < -STOP_ANIMATION_THRESHOLD:
			anim = "WalkLeft"
		elif linear_vel.x > STOP_ANIMATION_THRESHOLD:
			anim = "WalkRight"
		else:
			idle = true
	else:
		if linear_vel.y < -STOP_ANIMATION_THRESHOLD:
			anim = "WalkUp"
		elif linear_vel.y > STOP_ANIMATION_THRESHOLD:
			anim = "WalkDown"
		else:
			idle = true
	if idle:
		if(prev_anim.ends_with("Left")):
			anim = "IdleLeft"
		elif(prev_anim.ends_with("Right")):
			anim = "IdleRight"
		elif(prev_anim.ends_with("Up")):
			anim = "IdleUp"
		elif(prev_anim.ends_with("Down")):
			anim = "IdleDown"
	if anim != prev_anim:
		$AnimationPlayer.play(anim)
		prev_anim = anim

func process_collisions():
	var collider = null
	for i in range($body.get_slide_count()):
		collider = $body.get_slide_collision(i).get_collider().get_parent()
		if(collider.is_in_group(Constants.G_ENEMY)):
			collider.process_external_collision(self)

#float, float, first element in the tree (Node2D with script)
func receiveDmg(_fis, _mag, _source):
	var sourcePos = _source.getGlobalPosition()
	var direction = ($body.global_position - sourcePos).normalized()
	externalImpulse += direction*EXTERNAL_IMPULSE
	