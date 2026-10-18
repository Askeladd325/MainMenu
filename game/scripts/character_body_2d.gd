extends CharacterBody2D
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var joystick: Control = $"../joystick_canvas/Virtual joystick"
@onready var mapLayer1: TileMapLayer = $"../TileMapLayer"
@onready var mapLayer2: TileMapLayer = $"../TileMapLayer2"
@onready var mapLayer3: TileMapLayer = $"../TileMapLayer3"
@onready var cooking_station: Node2D = $"../../cooking_station"
@onready var kitchen: Node2D = $".."
@onready var animation_player: AnimationPlayer = $"../../transtion_canvas/AnimationPlayer"
@onready var joystick_canvas: CanvasLayer = $"../joystick_canvas"

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
		
func _try_interact():
	var player_tile_pos = mapLayer2.local_to_map(global_position)
	var tile_data = mapLayer2.get_cell_tile_data(player_tile_pos)
	print("l2 tiledata: ", tile_data)
	
	if tile_data:
		var is_interactable = tile_data.get_custom_data("kitchen station")
		if is_interactable:
			_trigger_tile_action(player_tile_pos)
			
func _trigger_tile_action(tile_coords: Vector2i):
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	cooking_station.visible = true
	joystick_canvas.visible = false
	animation_player.play("fade_in")

func _on_button_pressed() -> void:
	_try_interact()
