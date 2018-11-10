extends "res://Entities/Skills/Skill.gd"

const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 350 # pixels/sec
const SIDING_CHANGE_SPEED = 10
const STOP_ANIMATION_THRESHOLD = 15

const ROTATION_SPEED = 20

const EXTERNAL_IMPULSE = 4000
const IMPULSE_MITIGATION_FACTOR = 2

const MAX_SPEED_AND_IMPULSE = 400

var direction = Vector2(0, 0)
var target_vel = Vector2(0, 0)
var linear_vel = Vector2(0, 0)

var onParentCollision = false

var backing = false

func _ready():
	fisDmg = 1
	magDmg = 1
	cost = 10

func _physics_process(delta):
	move(delta)
	process_collisions()
	
func move(delta):
	if backing:
		target_vel = (parent.getGlobalPosition() - $body.global_position).normalized() * WALK_SPEED
	else:
		target_vel = WALK_SPEED*direction
	
	#linear_vel.x = lerp(linear_vel.x, target_vel.x, 0.1)
	#linear_vel.y = lerp(linear_vel.y, target_vel.y, 0.1)
	
	linear_vel = target_vel
	
	#We clamp the linear velocity
	linear_vel = linear_vel.clamped(MAX_SPEED_AND_IMPULSE)
	
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	
	$body.rotate(delta*ROTATION_SPEED)

func process_collisions():
	if backing && onParentCollision:
		parent.reset_boomerang_cooldown()
		queue_free()
	#We won't collide when backing
	var collider = null
	for i in range($body.get_slide_count()):
		collider = $body.get_slide_collision(i).get_collider().get_parent()
		if(collider.is_in_group(Constants.G_ENEMY)):
			collider.receiveDmg(fisDmg, magDmg, self)
			backing = true
		if(collider.is_in_group(Constants.G_WALL)):
			backing = true

func getGlobalPosition():
	return $body.global_position

func setGlobalPosition(pos):
	$body.global_position = pos

func play(pos):
	$body.global_position = pos
	direction = ($body.global_position - parent.getGlobalPosition()).normalized()

func _on_ComeBack_timeout():
	backing = true
	#We don't do anything when backing
	$body.collision_layer = 0
	$body.collision_mask = 0

func _on_PlayerCollision_body_entered(body):
	var collider = body.get_parent()
	if collider == parent:
		onParentCollision = true

func _on_PlayerCollision_body_exited(body):
	if body == parent:
		onParentCollision = false
