extends CharacterBody2D

@export var SPEED = 400
@onready var player = load("res://megaman.tscn")

var dir : float
var spawnPos : Vector2
var spawnRot : float
var zdex : int
var test = 0

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot

func _physics_process(delta):
	velocity = Vector2(SPEED, 0).rotated(dir)
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
func _on_timer_timeout() -> void:
	queue_free()
func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
