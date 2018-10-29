extends "res://Entities/Characters/Enemies/Enemy.gd"

const WALK_SPEED = 40
const CHASE_SPEED = 70
const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const NEXT_POSITION_STOP_THRESHOLD = 7
const EXTERNAL_IMPULSE = 4000
const IMPULSE_MITIGATION_FACTOR = 2
var nextPosition = Vector2(0,0)
var externalImpulse = Vector2(0,0)

var maxDistNextPos = 50
var minDistNextPos = 10

var magAtack = 0
var fisAtack = 5

var linear_vel = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Constants.GE_WONKY, true)
	nextPosition = Utils.calculateRandomPosition($body.global_position, maxDistNextPos, minDistNextPos)
	
func _physics_process(_delta):
	move(_delta)
	process_collisions()
	
func move(_delta):	
	var direction = (nextPosition-$body.global_position)
	var target_vel = Vector2(0,0)
	if (direction.distance_to(Vector2(0,0)) < NEXT_POSITION_STOP_THRESHOLD):
		target_vel = Vector2(0,0)
	else:
		target_vel = direction.normalized()*WALK_SPEED
	
	linear_vel.x = lerp(linear_vel.x, target_vel.x + externalImpulse.x, 0.1)
	linear_vel.y = lerp(linear_vel.y, target_vel.y + externalImpulse.y, 0.1)
	
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)

	externalImpulse /= IMPULSE_MITIGATION_FACTOR

func process_collisions():
	var collider = null
	for i in range($body.get_slide_count()):
		collider = $body.get_slide_collision(i).get_collider().get_parent()
		if(collider.is_in_group(Constants.G_PLAYER)):
			collider.receiveDmg(fisAtack, magAtack, self)

#Process a collision not detected by the enemy but by the external entity
func process_external_collision(collider):
	collider.receiveDmg(fisAtack, magAtack, self)

func receiveDmg(_fis, _mag, source):
	var sourcePos = source.getGlobalPosition()
	var direction = ($body.global_position - sourcePos).normalized()
	externalImpulse += direction*EXTERNAL_IMPULSE
	

func getGlobalPosition():
	return $body.global_position

func setGlobalPosition(newPos):
	$body.global_position = newPos

func _on_NextPositionLimit_timeout():
	nextPosition = Utils.calculateRandomPosition($body.global_position, maxDistNextPos, minDistNextPos)