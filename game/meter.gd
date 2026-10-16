extends Node2D

@export var min_angle: float = -20
@export var max_angle: float = 110
@export var speed: float = 180.0

@onready var minigames: Control = $"../../.."
@onready var settings: Control = get_tree().current_scene
@onready var hand_pivot: Node2D = $hand_pivot
@onready var base: GPUParticles2D = $"../../../../../cooking_station/background/base"
@onready var sides: Array[GPUParticles2D] = [
	$"../../../../../cooking_station/background/left",
	$"../../../../../cooking_station/background/right"
]
@onready var sides_front: Array[GPUParticles2D] = [
	$"../../../../../cooking_station/background/left_front",
	$"../../../../../cooking_station/background/right_front"
]
@onready var guide_canvas: CanvasLayer = settings.get_node("user_interface/guide_canvas")
@onready var hint: Label = $"../../../../../user_interface/hint"
@onready var ingredients: Area2D = $"../../../../../cooking_station/ingredients"
@onready var condiments: Area2D = $"../../../../../cooking_station/condiments"

var current_angle: float = -90.0
var direction: float = 1.0
var is_stopped: bool = false

func _ready() -> void:
	current_angle = min_angle
	hand_pivot.rotation_degrees = current_angle
	
func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	if is_stopped:
		return

	current_angle += speed * direction * delta

	if current_angle >= max_angle:
		current_angle = max_angle
		direction = -1.0
	elif current_angle <= min_angle:
		current_angle = min_angle
		direction = 1.0

	hand_pivot.rotation_degrees = current_angle

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if is_stopped:
		return

	if event is InputEventScreenTouch and event.pressed:
		stop_meter()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			stop_meter()

func start_meter() -> void:
	is_stopped = false
	current_angle = min_angle
	direction = 1.0
	hand_pivot.rotation_degrees = current_angle

func stop_meter() -> void:
	is_stopped = true

	print("Stopped at angle: ", current_angle)

	if current_angle >= -20 and current_angle <= 20:
		print("white")
		set_fire_strength("Low")
	elif current_angle > 20 and current_angle <= 66:
		print("yellow")
		set_fire_strength("Medium")
	elif current_angle > 66:
		print("red")
		set_fire_strength("High")
		
		
	await get_tree().create_timer(1.5).timeout
	minigames.visible = false
	guide_canvas.condiment_guide_locked = false
	guide_canvas.ingredient_guide_locked = false
	hint.visible = false

func set_fire_strength(level: String):
	base.emitting = true
	for fire in sides:
		fire.emitting = true
	for fire in sides_front:
		fire.emitting = true
	match level:
		"Low":
			base.amount = 20
			base.speed_scale = 0.3
			base.lifetime = 0.35
			for fire in sides_front:
				fire.amount = 3
				fire.speed_scale = 0.1
				fire.lifetime = 0.1
			for fire in sides:
				fire.amount = 20
				fire.speed_scale = 0.3
				fire.lifetime = 0.35
				var mat := fire.process_material as ParticleProcessMaterial
				if mat:
					var scale := 0.8
					mat.scale_min = scale
					mat.scale_max = scale
					mat.initial_velocity_min = 15.0
					mat.initial_velocity_max = 40.0
		"Medium":
			base.amount = 20
			base.speed_scale = 0.6
			base.lifetime = 0.55
			for fire in sides_front:
				fire.amount = 3
				fire.speed_scale = 0.1
				fire.lifetime = 0.1
			for fire in sides:
				fire.amount = 20
				fire.speed_scale = 0.6
				fire.lifetime = 0.55
				var mat := fire.process_material as ParticleProcessMaterial
				if mat:
					var scale := 0.8
					mat.scale_min = scale
					mat.scale_max = scale
					mat.initial_velocity_min = 15.0
					mat.initial_velocity_max = 40.0
		"High":
			base.amount = 80
			base.speed_scale = 1
			base.lifetime = 0.5
			for fire in sides_front:
				fire.amount = 10
				fire.speed_scale = 1
				fire.lifetime = 0.25
			for fire in sides:
				fire.amount = 40
				fire.speed_scale = 1
				fire.lifetime = 0.5
				var mat := fire.process_material as ParticleProcessMaterial
				if mat:
					var scale := 1
					mat.scale_min = scale
					mat.scale_max = scale
					mat.initial_velocity_min = 40
					mat.initial_velocity_max = 60.0


func _on_button_pressed() -> void:
	start_meter()
	print(guide_canvas.guide_sections)
