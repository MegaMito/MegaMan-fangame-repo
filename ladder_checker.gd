extends Area2D

var player: CharacterBody2D
var tilemap: TileMap
var touching_ladder := false

func _ready():
	player = get_parent()  # CharacterBody2D

func _on_body_entered(body):
	if body is TileMap:
		tilemap = body
		touching_ladder = true
		print(touching_ladder)

func _on_body_exited(body):
	if body is TileMap:
		touching_ladder = false
		tilemap = null

func _physics_process(delta):
	if not touching_ladder or tilemap == null:
		return

func snap_player_to_ladder_tile():
	var world_pos = global_position
	var tile_pos = tilemap.local_to_map(tilemap.to_local(world_pos))

	var tile_size_vec = Vector2(tilemap.tile_set.tile_size)
	var tile_center = tilemap.map_to_local(tile_pos) + tile_size_vec * 0.5

	player.velocity = Vector2.ZERO
	player.global_position = tile_center

	# Only activate when pressing W or S
	if Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		snap_player_to_ladder_tile()
		print("hi")
