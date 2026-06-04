extends CharacterBody2D

@onready var main = get_tree().get_root().get_node("main")
@onready var projectile = load("res://badguy_lemon.tscn")

const SPEED = 150.0
const JUMP_VELOCITY = -600.0

var shoot := false
var jump_timer = 300
var jump_timer_max = 300
var jumped := false
var shoot_timer = 300
var shoot_timer_max = 300

func _physics_process(delta: float) -> void:
	
	if $RayCast_Left.is_colliding():
		$Sprite2D.flip_h = true
		$shield/CollisionShape2D.position.x = -11.5
	elif $RayCast_Right.is_colliding():
		$Sprite2D.flip_h = false
		$shield/CollisionShape2D.position.x = 9.5
	#print("x pos: ", $shield/CollisionShape2D.position.x)
	
	if shoot:
		$Sprite2D/AnimationPlayer.play("sniper_joe_shoot")
	else:
		$Sprite2D/AnimationPlayer.play("sniper_joe_idle")
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 0.03
		$Sprite2D/AnimationPlayer.play("sniper_joe_jump")

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
	#print("jump_timer: ", jump_timer)
	#print("jump_timer_max: ", jump_timer_max)
	if jump_timer <= jump_timer_max:
		jump_timer -= 1
	if jump_timer <= 0:
		velocity.y = JUMP_VELOCITY
		jump_timer = jump_timer_max
	
	if shoot_timer <= shoot_timer_max:
		shoot_timer -= 1
	#	print("hi")
	#	print("shoot_timer: ", shoot_timer)
	#	print("shoot_timer_max: ", shoot_timer_max)
	if shoot_timer <= 60:
		$Sprite2D/AnimationPlayer.play("sniper_joe_shoot")
		$shield.monitoring = false
		$shield.monitorable = false
	if shoot_timer == 60:
		shooting()
	if shoot_timer <= 0:
		shoot_timer = shoot_timer_max
		shoot = false
		$shield.monitoring = true
		$shield.monitorable = true
	#print(shoot_timer)
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	queue_free()

func shooting():
	var instance = projectile.instantiate()
	if $Sprite2D.flip_h == false:
		instance.dir = rotation
		instance.spawnRot = rotation
	else:
		instance.dir = PI
		instance.spawnRot = PI
	instance.spawnPos = global_position
	
	instance.zdex = z_index -1
	main.add_child.call_deferred(instance)
