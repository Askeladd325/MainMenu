extends CharacterBody2D
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var joystick: Control = $"../CanvasLayer/Virtual joystick"
@onready var mapLayer2: TileMapLayer = $"../TileMapLayer/TileMapLayer2"
@onready var mapLayer1: TileMapLayer = $"../TileMapLayer"
@onready var mapLayer3: TileMapLayer = $"../TileMapLayer/TileMapLayer2/TileMapLayer3"

const SPEED = 100.0
var last_direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	var raw_input = joystick.joystick_vector
	var move_direction = Vector2.ZERO
	
	if raw_input != Vector2.ZERO:
		if abs(raw_input.x) > abs(raw_input.y):
			if raw_input.x > 0:
				move_direction = Vector2.RIGHT
			else:
				move_direction = Vector2.LEFT
		else: 
			if raw_input.y > 0:
				move_direction = Vector2.DOWN
			else: 
				move_direction = Vector2.UP
				
		last_direction = move_direction
	
	velocity = move_direction * SPEED
	move_and_slide()
	_handle_animations(move_direction)
	
	# --- MULTI-LAYER DEBUG CODE ---
	var pos_to_check = global_position
	
	var tile_l1 = mapLayer1.local_to_map(mapLayer1.to_local(pos_to_check))
	var tile_l2 = mapLayer2.local_to_map(mapLayer2.to_local(pos_to_check))
	var tile_l3 = mapLayer3.local_to_map(mapLayer3.to_local(pos_to_check))
	
	print("L1 ID: ", mapLayer1.get_cell_source_id(tile_l1), 
		  " | L2 ID: ", mapLayer2.get_cell_source_id(tile_l2), 
		  " | L3 ID: ", mapLayer3.get_cell_source_id(tile_l3))
	# -------------------------------



	
	
func _handle_animations(direction: Vector2):
	if direction == Vector2.ZERO:
		if last_direction == Vector2.RIGHT:
			animatedSprite.play("idle_right")
		elif last_direction == Vector2.LEFT:
			animatedSprite.play("idle_left")
		elif last_direction == Vector2.UP:
			animatedSprite.play("idle_up")
		elif last_direction == Vector2.DOWN:
			animatedSprite.play("idle_down")	
	elif direction == Vector2.RIGHT:
		animatedSprite.flip_h = false
		animatedSprite.play("walking_right")
	elif direction == Vector2.LEFT:
		animatedSprite.play("walking_left")
	elif direction == Vector2.UP:
		animatedSprite.play("walking_up")
	elif direction == Vector2.DOWN:
		animatedSprite.play("walking_down")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		_try_interact()
		
func _try_interact():
	var player_tile_pos = mapLayer2.local_to_map(global_position)
	var tile_data = mapLayer2.get_cell_tile_data(player_tile_pos)
	
	if tile_data:
		var is_interactable = tile_data.get_custom_data("kitchen station")
		if is_interactable:
			_trigger_tile_action(player_tile_pos)
			
func _trigger_tile_action(tile_coords: Vector2i):
	print("just testing")
