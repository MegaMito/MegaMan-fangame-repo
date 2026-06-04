extends CharacterBody2D

@export var SPEEDX = 100
@export var SPEEDY = 0
@onready var player = load("res://megaman.tscn")

var dir : float
var spawnPos : Vector2
var spawnRot : float
var zdex : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = spawnPos
	global_rotation = spawnRot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(SPEEDX, SPEEDY).rotated(dir)
	move_and_slide()


func _on_timer_timeout() -> void:
	queue_free()
