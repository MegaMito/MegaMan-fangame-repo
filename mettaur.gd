extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var in_range := false
var hide := false
var shoot_timer = 60
var shoot_timer_max = 60


func _physics_process(delta: float) -> void:
	
	if $RayCast_Left.is_colliding():
		$Sprite2D/AnimationPlayer.play("mettaur_peek")
		$Sprite2D.flip_h = false
		$hurtbox.monitorable = true
		$hurtbox.monitoring = true
		$helmet.monitoring = false
		$helmet.monitorable = false
	elif $RayCast_Right.is_colliding():
		$Sprite2D/AnimationPlayer.play("mettaur_peek")
		$Sprite2D.flip_h = true
		$hurtbox.monitorable = true
		$hurtbox.monitoring = true
		$helmet.monitoring = false
		$helmet.monitorable = false
	else:
		$Sprite2D/AnimationPlayer.play("mettaur_crouch")
		$hurtbox.monitorable = false
		$hurtbox.monitoring = false
		$helmet.monitoring = true
		$helmet.monitorable = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 0.05
	
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	queue_free()
