extends Control

@onready var base: Sprite2D = $base
@onready var handle: Sprite2D = $base/handle

# Scaled down specifically for your 480x270 pixel art screen
@export var max_length: float = 16.0  
@export var deadzone: float = 2.0     

# This is the exact variable your player character looks for!
var joystick_vector: Vector2 = Vector2.ZERO
var is_dragging: bool = false

func _ready():
	# Center the visual artwork inside your 64x64 control box area
	base.position = size / 2
	handle.position = base.position

func _input(event):
	# Check if the player is using a touchscreen or mouse clicking
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed():
			# Start dragging if the touch point is within range of the joystick
			if event.position.distance_to(base.global_position) <= max_length * 2:
				is_dragging = true
				_update_joystick(event.position)
		else:
			# Reset everything to the center when they lift their thumb
			is_dragging = false
			joystick_vector = Vector2.ZERO
			handle.position = base.position
			
	# Update position while dragging
	elif event is InputEventScreenDrag or (event is InputEventMouseMotion and is_dragging):
		if is_dragging:
			_update_joystick(event.position)

func _update_joystick(touch_position: Vector2):
	var center = base.global_position
	var offset = touch_position - center
	
	# Clamp the inner handle circle so it can't exit the outer base circle
	if offset.length() > max_length:
		offset = offset.normalized() * max_length
		
	handle.global_position = center + offset
	
	# Normalize and pass the clean directional data to 'joystick_vector'
	if offset.length() > deadzone:
		joystick_vector = offset / max_length
	else:
		joystick_vector = Vector2.ZERO
