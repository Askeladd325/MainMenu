extends Area2D

var dragging := false
var offset := Vector2.ZERO
var in_sink := false

var wash_progress := 0.0
var wash_time := 3.0
var washed := false

@onready var ingredient = get_node("../..")
@onready var animation_player = get_node("../../AnimationPlayer")
@onready var wash_progress_bar = get_node("../../../WashProgress")
@onready var water_animation = get_node("../../../water/WaterAnimation")
@onready var water_particles = get_node("../../../water/WaterParticles")
@onready var water = get_node("../../../water")
@onready var dirt_spot1 = get_node("../../Dirt/DirtSpot1")
@onready var dirt_spot2 = get_node("../../Dirt/DirtSpot2")
@onready var dirt_spot3 = get_node("../../Dirt/DirtSpot3")
@onready var dirt_spot4 = get_node("../../Dirt/DirtSpot4")

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	water_animation.stop()
	water_particles.emitting = false
	water.visible = false

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				offset = ingredient.global_position - get_global_mouse_position()
			else:
				dragging = false

func _process(delta):
	if dragging:
		ingredient.global_position = get_global_mouse_position() + offset

	if in_sink and not washed:
		wash_progress += delta
		wash_progress_bar.value = wash_progress

		# Remove dirt gradually
		if wash_progress >= 0.75:
			dirt_spot1.visible = false

		if wash_progress >= 1.5:
			dirt_spot2.visible = false

		if wash_progress >= 2.25:
			dirt_spot3.visible = false

		if wash_progress >= 3.0:
			dirt_spot4.visible = false

		if wash_progress >= wash_time:
			washed = true
			print("🐔 CHICKEN IS WASHED!")
			animation_player.stop()
			water_animation.stop()
			water_particles.emitting = false
			water.visible = false

func _on_area_entered(area):
	if area.name == "SinkArea":
		in_sink = true
		print("🐔 CHICKEN ENTERED THE SINK!")
		
		water.visible = true
		water_animation.play("water_drop")
		water_particles.emitting = true
		
		animation_player.play("was_chicken")

func _on_area_exited(area):
	if area.name == "SinkArea":
		in_sink = false
		print("🐔 CHICKEN LEFT THE SINK!")
		
		water.visible = false
		water_animation.stop()
		water_particles.emitting = false
		
		animation_player.stop()
		
		if not washed:
			wash_progress = 0.0
			wash_progress_bar.value = 0.0

			dirt_spot1.visible = true
			dirt_spot2.visible = true
			dirt_spot3.visible = true
			dirt_spot4.visible = true
