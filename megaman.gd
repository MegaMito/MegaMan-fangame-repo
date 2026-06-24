extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("main")
@onready var projectile = load("res://lemon.tscn")
@onready var explosion = load("res://explosion.tscn")

const SPEED = 150.0
const JUMP_VELOCITY = -600.0

var jump_modifier = 0.5
var speed_modifier = 3
var speed_modifier_max = 3
var shoot_timer = 7.5
var shoot_timer_max = 7.5
var shooting := false
var on_ladder := false
var ladder_timer = 1
var ladder_timer_max = 1
var climbing := false
var climb_down := false
var climb_up := false
var coyote_timer = 10
var coyote_timer_max = 10
var damaged := false
var invincible := false
var damage_timer = 3
var damage_timer_max = 3
var invincible_timer = 6
var invincible_timer_max = 6
var on_enemy := false
var jumped := false
var sliding := false

var spawned := false
var spawn_timer = 2

var desired_x_pos: float
var x_pos_tween: Tween

func _input(event):
	if event.is_action_released("jump"):
		if velocity.y < 0.0:
			velocity.y *= jump_modifier

func _physics_process(delta: float) -> void:
	#print("----------------------------")
	#print("coyote: ", coyote_timer)
	#print("speed: ", speed_modifier)
	#print("ladder_timer: ", ladder_timer)
	#print("is_on_floor: ", is_on_floor())
	#print("onladder: ", on_ladder)
	#print("climbing: ", climbing)
	#print("damaged: ", damaged)
	#print("invincible: ", invincible)
	#print("damaged_timer: ", damage_timer)
	#print("invincible_timer: ", invincible_timer)
	
	if !spawned:
		_spawn()
		
	move_and_slide()
	_damaged()
	_movement()
	_ladder_movement()

	if Input.is_action_just_pressed("test"):
		dead()
	
func _spawn():
	#ENTRY ANIMATION
	if !spawned and !is_on_floor():
		$Node2D/AnimationPlayer.play("teleport_air")
	else: if !spawned and is_on_floor():
		$Node2D/AnimationPlayer.play("teleport_ground")
		spawn_timer -= 0.1
		
	if spawn_timer <= 0:
		spawned = true

func _movement():
	# GRAVITY
	if not is_on_floor() and !climbing:
		velocity += get_gravity() * 0.05
		if shooting and !damaged and spawned:
			$Node2D/AnimationPlayer.play("jump_shoot")
		else: if !damaged and spawned:
			$Node2D/AnimationPlayer.play("jump")
	
	# COYOTE TIME
	if !is_on_floor() and coyote_timer > 0:
		coyote_timer -= 1
	if is_on_floor():
		coyote_timer = coyote_timer_max
		jumped = false
	
	# JUMP
	if(jumped == false):
		if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0 or climbing) and !damaged:
			velocity.y = JUMP_VELOCITY
			
	if Input.is_action_just_pressed("jump"):
		jumped = true
		
	# MOVING RIGHT
	if Input.is_action_pressed("right") and !climbing and !damaged and spawned:
		velocity.x = SPEED
		$Node2D.flip_h = false
		# MOVING RIGHT ANIMATION
		if is_on_floor() and shooting: $Node2D/AnimationPlayer.play("run_shoot")
		else: if is_on_floor(): $Node2D/AnimationPlayer.play("run")
		
	# MOVE LEFT
	elif Input.is_action_pressed("left") and !climbing and !damaged and spawned:
		velocity.x = -SPEED
		$Node2D.flip_h = true
		# MOVING LEFT ANIMATION
		if is_on_floor() and shooting: $Node2D/AnimationPlayer.play("run_shoot")
		else: if is_on_floor(): $Node2D/AnimationPlayer.play("run")
		
	# IDLE
	else:
		if is_on_floor() and shooting and !damaged and spawned:
			$Node2D/AnimationPlayer.play("idle_shoot")
		else: if is_on_floor() and !damaged and spawned:
			$Node2D/AnimationPlayer.play("idle")
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# SLIDE
	if Input.is_action_just_pressed("slide"):
		sliding = true
		
	#if sliding and speed_modifier > 1 and !on_ladder and !climb_down and !damaged and spawned:
	if sliding and speed_modifier > 1 and !on_ladder and !damaged and spawned:
		# SLIDE ANIMATION
		if shooting: $Node2D/AnimationPlayer.play("slide_shoot")
		else: $Node2D/AnimationPlayer.play("slide")
		# SLIDE DIRECTION SPEED
		if $Node2D.flip_h == true: velocity.x = -SPEED * speed_modifier
		else: velocity.x = SPEED * speed_modifier
		# slows down slide speed over time
		if speed_modifier > 1: speed_modifier -= 0.1
	# SLIDE RESET
	if speed_modifier <= 1 or climbing:
		speed_modifier = speed_modifier_max
		sliding = false
	
	#SHOOTING
	if Input.is_action_just_pressed("shoot") and !damaged and spawned: 
		shooting = true
		_shoot()
	if shoot_timer <= shoot_timer_max and shoot_timer > 0:
		shoot_timer -= 0.1
	if shoot_timer <= 0: 
		shoot_timer = shoot_timer_max
		shooting = false

func _ladder_movement():
	# CLIMB
	_ladder_detect()
	_down_ladder_detect()
	if on_ladder and ladder_timer <= 0.1 and (Input.is_action_pressed("up") or Input.is_action_pressed("down") and !is_on_floor()):
		climbing = true
		
		desired_x_pos = $LadderChecker.get_collider().get_child($LadderChecker.get_collider_shape()).global_position.x
		if global_position.x != desired_x_pos:
			x_pos_tween = create_tween().set_trans(Tween.TRANS_SINE)
			x_pos_tween.tween_property(self, "global_position:x", desired_x_pos, 0)
		
	if Input.is_action_pressed("down") and is_on_floor() and on_ladder and climbing:
		climbing = false
	if Input.is_action_just_pressed("jump") and climbing:
		velocity.y = JUMP_VELOCITY
		climbing = false
		ladder_timer = ladder_timer_max
	if !on_ladder and climbing:
		climbing = false
	if ladder_timer > 0.1:
		ladder_timer -= 0.1
	
	if on_ladder and climbing:
		if Input.is_action_pressed("up") and !damaged:
			if climb_up: $Node2D/AnimationPlayer.play("climb_up")
			else:
				$Node2D/AnimationPlayer.play("climb")
			velocity.y = -100
		elif Input.is_action_pressed("down") and !damaged:
			$Node2D/AnimationPlayer.play("climb")
			velocity.y = 100
		elif Input.is_action_pressed("shoot") and !damaged:
			if Input.is_action_pressed("right"):
				$Node2D.flip_h = false
			if Input.is_action_pressed("left"):
				$Node2D.flip_h = true
			if Input.is_action_pressed("up"):
				velocity.y = -100
			else:
				velocity.y = 0
			
			if Input.is_action_pressed("down"):
				velocity.y = 100
			else:
				velocity.y = 0
			$Node2D/AnimationPlayer.play("climb_shoot")
		elif !shooting and !damaged:
			velocity.y = 0
			if climb_up: $Node2D/AnimationPlayer.play("climb_up")
			else:
				$Node2D/AnimationPlayer.play("climb")
			$Node2D/AnimationPlayer.stop()
	if climb_down:
		if Input.is_action_just_pressed("down") and is_on_floor():
			position.y += 32

func _shoot():
	var instance = projectile.instantiate()
	if $Node2D.flip_h == false:
		instance.dir = rotation
		instance.spawnRot = rotation
	else:
		instance.dir = PI
		instance.spawnRot = PI
	instance.spawnPos = global_position
	
	instance.zdex = z_index -1
	main.add_child.call_deferred(instance)

func _hit(): #order matters here
	if $Camera2D/Energy_1/Energy_4.frame == 55:
		dead()
	
	if $Camera2D/Energy_1/Energy_3.frame == 55 and $Camera2D/Energy_1/Energy_4.frame >= 56:
		$Camera2D/Energy_1/Energy_4.frame -= 8
		
	if $Camera2D/Energy_1/Energy_2.frame == 55 and $Camera2D/Energy_1/Energy_3.frame >= 56:
		$Camera2D/Energy_1/Energy_3.frame -= 8
		
	if $Camera2D/Energy_1.frame == 55 and $Camera2D/Energy_1/Energy_2.frame >= 56:
		$Camera2D/Energy_1/Energy_2.frame -= 8
		
	if $Camera2D/Energy_1.frame >= 56:
		$Camera2D/Energy_1.frame -= 8

func _damaged():
	#DAMAGED
	if on_enemy:
		damaged = true
	
	if damaged and !invincible:
		$Node2D/AnimationPlayer.play("damaged")
		if $Node2D.flip_h == false: velocity.x = -200
		else: velocity.x = 200
		climbing = false
		damage_timer -= 0.1
	
	if damage_timer == 2.9:
		_hit()
	
	if damage_timer <= 0 and !invincible:
		#damaged = false
		invincible = true
		damage_timer = damage_timer_max
	
	if invincible:
		invincible_timer -= 0.1
		damaged = false
	
	if invincible_timer <= 0:
		invincible = false
		invincible_timer = invincible_timer_max

func dead():
	var instance = explosion.instantiate()
	
	instance.spawnPos = global_position
	add_child(instance)

func _on_up_ladder_checker_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	climb_up = false
func _on_up_ladder_checker_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	climb_up = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	on_enemy = true
func _on_area_2d_body_exited(body: Node2D) -> void:
	on_enemy = false

func _ladder_detect():
	if $LadderChecker.is_colliding():
		on_ladder = true
		
		#if is_on_floor():
		#	climb_down = true
		#else:
		#	climb_down = false
	else:
		on_ladder = false

func _down_ladder_detect():
	if $DownLadderChecker.is_colliding():
		climb_down = true
	else:
		climb_down = false
