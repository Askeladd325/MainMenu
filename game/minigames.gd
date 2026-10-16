extends Control

@onready var sub_viewport: SubViewport = $"Pop-up Window/SubViewportContainer/SubViewport"
@onready var camera_2d: Camera2D = $"Pop-up Window/SubViewportContainer/SubViewport/Camera2D"
@onready var settings: Control = get_tree().current_scene
@onready var sub_viewport_container: SubViewportContainer = $"Pop-up Window/SubViewportContainer"
@onready var pop_up_window: Panel = $"Pop-up Window"
@onready var stove_minigame: Panel = $"Pop-up Window/stove_minigame"
@onready var pan: Area2D = $"../../cooking_station/pan"
@onready var stir_progress: ProgressBar = $"Pop-up Window/stir_progress"
@onready var label: Label = $"Pop-up Window/Label"
@onready var guide_canvas: CanvasLayer = $"../../user_interface/guide_canvas"

@export var spatula: Node2D
@export var stir_radius: float = 55.0
@export var push_strength: float = 180.0
@export var ingredient_container: Node2D

var previous_spatula_position: Vector2
var dragging_spatula := false
var stirring_active := true

func _ready():
	var main_viewport := get_viewport()
	
	sub_viewport.world_2d = main_viewport.world_2d
	sub_viewport_container.visibility_layer = 1
	sub_viewport.canvas_cull_mask = 1

	settings.zoom_to_point(camera_2d, Vector2(200,140), 1.7)

func _input(event: InputEvent) -> void:
	if not visible or not stirring_active:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_local := sub_viewport_container.get_local_mouse_position()

				var popup_rect := Rect2(Vector2.ZERO, sub_viewport_container.size)

				if popup_rect.has_point(mouse_local):
					dragging_spatula = true
			else:
				dragging_spatula = false


func _process(delta: float) -> void:
	if not visible or not stirring_active:
		dragging_spatula = false
		return

	if dragging_spatula:
		previous_spatula_position = spatula.global_position
		
		var mouse_local := sub_viewport_container.get_local_mouse_position()

		move_spatula(mouse_local)
		
		var movement := (spatula.global_position - previous_spatula_position)
		
		if movement.length() > 0.1:
			stir_ingredients(movement.normalized(), delta)
		
func move_spatula(mouse_local: Vector2) -> void:
	var viewport_pos := Vector2(
		mouse_local.x * sub_viewport.size.x / sub_viewport_container.size.x,
		mouse_local.y * sub_viewport.size.y / sub_viewport_container.size.y
	)

	var world_pos := (sub_viewport.get_canvas_transform().affine_inverse() * viewport_pos)
	var pan_local_pos := pan.to_local(world_pos)

	pan_local_pos = clamp_to_pan_shape(pan_local_pos)

	spatula.global_position = pan.to_global(pan_local_pos)
	
func stir_ingredients(direction: Vector2, delta: float):
	for ingredient in pan.stacked_ingredients:
		var spatula_offset := Vector2(-6, 6)
		var spatula_point := spatula.position + spatula_offset
		var distance: float = spatula_point.distance_to(ingredient.position)
		if distance < stir_radius:
			var influence := 1.0 - distance / stir_radius
			ingredient.global_position += (direction * push_strength * influence * delta)
			clamp_ingredient_to_pan(ingredient)
			
			stir_progress.value += 20 * influence * delta
			
			if stir_progress.value >= stir_progress.max_value:
				stirring_active = false
				
				label.visible = true
				label.set_text("Completed!")
				label.position.y = 100
				label.modulate = Color.GREEN
				label.add_theme_font_size_override("font_size", 20)
				
				await get_tree().create_timer(1.5).timeout
				visible = false
				label.visible = false
				guide_canvas.guide_complete("Stir the pan")
	
func clamp_ingredient_to_pan(ingredient: Node2D):
	var pan_local_pos := pan.to_local(ingredient.global_position)

	pan_local_pos.x = clampf(pan_local_pos.x, -15, 17)
	pan_local_pos.y = clampf(pan_local_pos.y, -22, -4)
	
	var cut := 10
	var nw_cut := 6
	var se_cut := 7
	var sw_cut := 10
	if pan_local_pos.x < -15 + cut and pan_local_pos.y < -22 + cut: #here
		var corner_dist = (pan_local_pos.x + 15.0) + (pan_local_pos.y + 22.0)
		var limit = cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x += correction
			pan_local_pos.y += correction
		
	if pan_local_pos.x > 17 - nw_cut and pan_local_pos.y < -22 + nw_cut:
		var corner_dist = (17 - pan_local_pos.x) + (pan_local_pos.y + 22.0)
		var limit = nw_cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x -= correction
			pan_local_pos.y += correction
			
	if pan_local_pos.x < -15 + se_cut and pan_local_pos.y > -10:  #se
		var corner_dist = (pan_local_pos.x + 15) + (-4 - pan_local_pos.y)  
		var limit = se_cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x += correction
			pan_local_pos.y -= correction
	if pan_local_pos.x > 17 - sw_cut and pan_local_pos.y > -10: 
		var corner_dist = (17 - pan_local_pos.x) + (-4 - pan_local_pos.y) 
		var limit = sw_cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x -= correction
			pan_local_pos.y -= correction
	ingredient.global_position = pan.to_global(pan_local_pos)

func clamp_to_pan_shape(pan_local_pos: Vector2) -> Vector2:
	pan_local_pos.x = clampf(pan_local_pos.x, -9, 26)
	pan_local_pos.y = clampf(pan_local_pos.y, -32, -10)
	
	var cut := 10
	var nw_cut := 6
	var se_cut := 7
	var sw_cut := 10
	if pan_local_pos.x < -9 + cut and pan_local_pos.y < -32 + cut:
		var corner_dist = (pan_local_pos.x + 9.0) + (pan_local_pos.y + 32.0)
		var limit = cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x += correction
			pan_local_pos.y += correction
		
	if pan_local_pos.x > 26 - nw_cut and pan_local_pos.y < -32 + nw_cut:
		var corner_dist = (26.0 - pan_local_pos.x) + (pan_local_pos.y + 32.0)
		var limit = nw_cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x -= correction
			pan_local_pos.y += correction
			
	if pan_local_pos.x < -9 + se_cut and pan_local_pos.y > -16: 
		var corner_dist = (pan_local_pos.x + 9) + (-10 - pan_local_pos.y)  
		var limit = se_cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x += correction
			pan_local_pos.y -= correction

	if pan_local_pos.x > 26 - sw_cut and pan_local_pos.y > -19: 
		var corner_dist = (26 - pan_local_pos.x) + (-10 - pan_local_pos.y) 
		var limit = sw_cut
		
		if corner_dist < limit:
			var correction = (limit - corner_dist) / 2.0
			pan_local_pos.x -= correction
			pan_local_pos.y -= correction

	return pan_local_pos

func pan_stir():
	visible = true
	stove_minigame.visible = false
	
	var height := 220
	sub_viewport.size.y = height - 4
	pop_up_window.size.y = height
	
	settings.zoom_to_point(camera_2d, Vector2(200,140), 2.4)
	
	stirring_active = true
	stir_progress.value = 0

func stop_pan_stir() -> void:
	stirring_active = false
