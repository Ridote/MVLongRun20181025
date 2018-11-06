extends "res://Entities/Skills/Skill.gd"

const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const SIDING_CHANGE_SPEED = 10
const STOP_ANIMATION_THRESHOLD = 15

const ROTATION_SPEED = 20

const EXTERNAL_IMPULSE = 4000
const IMPULSE_MITIGATION_FACTOR = 2

const MAX_SPEED_AND_IMPULSE = 400

var direction = Vector2(0, 0)
var target_vel = Vector2(0, 0)
var linear_vel = Vector2(0, 0)

var backing = false

func assign_parent(node):
	.assign_parent(node)
		
	direction = (node.getGlobalPosition() - $body.global_position).normalized()
	

func _physics_process(delta):
	move(delta)
	process_collisions()
	
func move(delta):
	if backing:
		target_vel = (parent.getGlobalPosition() - $body.global_position).normalized() * WALK_SPEED
	else:
		target_vel = WALK_SPEED*direction
	
	linear_vel.x = lerp(linear_vel.x, target_vel.x, 0.1)
	linear_vel.y = lerp(linear_vel.y, target_vel.y, 0.1)
	
	#We clamp the linear velocity
	linear_vel = linear_vel.clamped(MAX_SPEED_AND_IMPULSE)
	
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	
	$body.rotate(delta*ROTATION_SPEED)

func process_collisions():
	#We won't collide when backing
	var collider = null
	for i in range($body.get_slide_count()):
		collider = $body.get_slide_collision(i).get_collider().get_parent()
		if(collider.is_in_group(Constants.G_PLAYER) && backing):
			parent.reset_boomerang_cooldown()
			queue_free()
		if(collider.is_in_group(Constants.G_ENEMY)):
			print("Yo!!")
			collider.process_external_collision(self)
			backing = true
		if(collider.is_in_group(Constants.G_WALL)):
			backing = true

func setGlobalPosition(pos):
	$body.global_position = pos

func play(pos):
	$body.global_position = pos
	direction = ($body.global_pos - parent.getGlobalPosition()).normalized()

func _on_ComeBack_timeout():
	backing = true
	#We add the father
	$body.collision_mask |= parent.getId()
