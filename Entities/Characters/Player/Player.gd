extends "res://Entities/Characters/Character.gd"

var blink_skill_factory = preload("res://Entities/Skills/Blink.tscn")
var boomerang_skill_factory = preload("res://Entities/Skills/Boomerang.tscn")

const FLOOR_NORMAL = Vector2(0, 1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 150 # pixels/sec
const SIDING_CHANGE_SPEED = 10
const STOP_ANIMATION_THRESHOLD = 5

const EXTERNAL_IMPULSE = 4000
const IMPULSE_MITIGATION_FACTOR = 2

const MAX_SPEED_AND_IMPULSE = 400

var linear_vel = Vector2()
var target_vel = Vector2()
var prev_anim="IdleDown"

var externalImpulse = Vector2()

#Skills
var attackAttemp = false
var attacking = false
var attackCooldown = false

var blinkAttemp = false
var blinkCooldown = false

var boomerangAttemp = false
var boomerangCooldown = false

var casting = false

func _ready():
	PlayerStats.player_hp = PlayerStats.player_hp_max
	PlayerStats.player_energy = PlayerStats.player_energy_max
	
	add_to_group(Constants.G_PLAYER)
	$Animations/AnimationMovement.play("IdleDown")
	
	$body/Sword.collision_mask = 0
	$body/Sword.collision_layer = 0
	
func _physics_process(delta):
	PlayerStats.player_energy += PlayerStats.player_energy_recovery*delta
	PlayerStats.player_hp += PlayerStats.player_hp_recovery*delta
	
	read_input()
	process_skills()
	move(delta)
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
	attackAttemp = Input.is_action_just_pressed("ui_attack")
	blinkAttemp = Input.is_action_pressed("ui_blink")
	boomerangAttemp = Input.is_action_just_pressed("ui_boomerang")
		
	target_vel = target_vel.normalized()
func process_skills():
	if !casting:
		if attackAttemp && !attackCooldown:
			skill_sword_dash()
		else:
			if blinkAttemp && !blinkCooldown:
				skill_blink()
			if boomerangAttemp && !boomerangCooldown:
				skill_boomerang()

func move(_delta):
	if !attacking:
		target_vel *= WALK_SPEED
	else:
		target_vel *= 0
	linear_vel.x = lerp(linear_vel.x, target_vel.x + externalImpulse.x, 0.1)
	linear_vel.y = lerp(linear_vel.y, target_vel.y + externalImpulse.y, 0.1)
	
	#We clamp the linear velocity
	linear_vel = linear_vel.clamped(MAX_SPEED_AND_IMPULSE)
	linear_vel = $body.move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	externalImpulse /= IMPULSE_MITIGATION_FACTOR

func finishCasting():
	casting = false

func animate():
	var anim = ""
	var idle = false
	
	if attacking:
		$Animations/AnimationMovement.stop()
		match(prev_anim):
			"WalkLeft", "IdleLeft":
				$Animations/AnimationSword.play("AtackLeft")
				prev_anim = "AtackLeft"
			"WalkRight", "IdleRight":
				$Animations/AnimationSword.play("AtackRight")
				prev_anim = "AtackRight"
			"WalkUp", "IdleUp":
				$Animations/AnimationSword.play("AtackUp")
				prev_anim = "AtackUp"
			"WalkDown", "IdleDown":
				$Animations/AnimationSword.play("AtackDown")
				prev_anim = "AtackDown"
			_:
				pass
		return

	if (pow(linear_vel.x,2) > pow(linear_vel.y,2)):
		if linear_vel.x < -STOP_ANIMATION_THRESHOLD:
			anim = "WalkLeft"
		elif linear_vel.x > STOP_ANIMATION_THRESHOLD:
			anim = "WalkRight"
		else:
			idle = true
	elif(pow(linear_vel.y,2) > 1):
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
	if anim != prev_anim && anim!="":
		$Animations/AnimationMovement.play(anim)
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
	PlayerStats.player_hp -= _fis + _mag

################################################ ATACK
func skill_sword_dash():
	if PlayerStats.player_energy < 5:
		return
	PlayerStats.player_energy -= 5
	casting = true
	attackCooldown = true
	attacking = true

func finish_atack():
	attacking = false

func reset_atack_cooldown():
	attackCooldown = false
	
################################################ Blink
func skill_blink():
	var blink = blink_skill_factory.instance()
	# the parent can be get_tree().get_root() or some other node
	get_tree().get_root().add_child(blink)
	if blink.getCost() > PlayerStats.player_energy:
		blink.queue_free()
		return
	PlayerStats.player_energy -= blink.getCost()
	blink.assign_parent(self)
	blink.play($body.global_position + linear_vel.normalized()*100)
	casting = true
	blinkCooldown = true
	$Animations/AnimationBlink.play("Blink")
	

func reset_blink_cooldown():
	blinkCooldown = false

################################################ Boomerang
func skill_boomerang():
	var boomerang = boomerang_skill_factory.instance()
	if boomerang.getCost() > PlayerStats.player_energy:
		boomerang.queue_free()
		return
	get_tree().get_root().add_child(boomerang)
	boomerang.assign_parent(self)
	if linear_vel.length() > 1:
		boomerang.play($body.global_position + linear_vel.normalized()*32)
	else:
		boomerang.play($body.global_position + getOrientation().normalized()*32)
	boomerangCooldown = true
	PlayerStats.player_energy -= boomerang.getCost()

func reset_boomerang_cooldown():
	boomerangCooldown = false

################################################ Position
func getGlobalPosition():
	return $body.global_position

func setGlobalPosition(newPos):
	$body.global_position = newPos

func getOrientation():
	if "Down".is_subsequence_of(prev_anim):
		return Vector2(0, 1)
	if "Up".is_subsequence_of(prev_anim):
		return Vector2(0,-1)
	if "Right".is_subsequence_of(prev_anim):
		return Vector2(1, 0)
	if "Left".is_subsequence_of(prev_anim):
		return Vector2(-1, 0)
	OS.alert(get_name() + " getOrientation failed, orientation not recognized \"" + prev_anim + "\"", "Runtime error")
		
################################################ Aux
func getId():
	return 1

func _on_Sword_body_entered(body):
	var collider = body.get_parent()
	if(collider.is_in_group(Constants.G_ENEMY)):
		collider.receiveDmg(5,0,self)

func _animate_with_parameter(animation):
	if animation != prev_anim:
		$AnimationPlayer.play(animation)