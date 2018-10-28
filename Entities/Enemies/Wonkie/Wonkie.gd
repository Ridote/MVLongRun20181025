extends "res://Entities/Enemies/Enemy.gd"

const WALK_SPEED = 40
const CHASE_SPEED = 70
const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const NEXT_POSITION_STOP_THRESHOLD = 7


var nextPosition = Vector2(0,0)

var maxDistNextPos = 50
var minDistNextPos = 10

var magAtack = 0
var fisAtack = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Constants.GE_WONKY, true)
	nextPosition = Utils.calculateRandomPosition($body.global_position, maxDistNextPos, minDistNextPos)
	
func _physics_process(_delta):
	move(_delta)
	process_collisions()
	
func move(_delta):	
	var direction = (nextPosition-$body.global_position)
	if (direction.distance_to(Vector2(0,0)) < NEXT_POSITION_STOP_THRESHOLD):
		return
	var linear_vel = direction.normalized()*WALK_SPEED
	#linear_vel.x = lerp(linear_vel.x, target_vel.x, 0.1)
	#linear_vel.y = lerp(linear_vel.y, target_vel.y, 0.1)
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)

func process_collisions():
	var collider = null
	for i in range($body.get_slide_count()):
		collider = $body.get_slide_collision(i).get_collider()
		if(collider.is_in_group(Constants.G_PLAYER)):
			collider.receiveDmg(fisAtack, magAtack, self)
	

func _on_NextPositionLimit_timeout():
	nextPosition = Utils.calculateRandomPosition($body.global_position, maxDistNextPos, minDistNextPos)