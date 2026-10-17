extends Area2D

@onready var ingredients: Area2D = $"../ingredients"
@onready var condiments: Area2D = $"../condiments"
@onready var particle: GPUParticles2D = $GPUParticles2D
@onready var droplets: Sprite2D = $droplets
@onready var sample_finish: Sprite2D = $"../../sample_finish"
@onready var animation_player: AnimationPlayer = $"../../transtion_canvas/AnimationPlayer"

var current_condiment: Area2D = null
var stacked_condiments: Array[Area2D] = []
var current_ingredient: Area2D = null
var stacked_ingredients: Array[Area2D] = []
var current_stack_offset := 0
var stack_spacing := 1.1

func _on_area_entered(area: Area2D) -> void:
	area.inside_pan = true

func _on_area_exited(area: Area2D) -> void:
	area.inside_pan = false

func ingredient_to_pan(new_ingredient: Area2D):
	new_ingredient.reparent(self)
	current_ingredient = new_ingredient
	current_stack_offset = stacked_ingredients.size()
	stacked_ingredients.append(new_ingredient)
	new_ingredient.visible = true

func ingredient_to_pan_animation():
	current_ingredient.position = Vector2(0, -48 -current_stack_offset * stack_spacing)
	current_ingredient.rotation = 0
	current_ingredient.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		current_ingredient, "position", Vector2(0, -14 -current_stack_offset * stack_spacing), 0.5
	)
	tween.tween_property(
		current_ingredient, "rotation", deg_to_rad(90), 0.5
	)

func condiment_to_pan(condiment: Area2D):
	condiment.reparent(self,true)
	current_condiment = condiment
	stacked_condiments.append(condiment)
	condiment.visible = true
	
	particle.set_particle(condiment)

func condiment_to_pan_animation():
	current_condiment.position = Vector2(15, -50)
	current_condiment.rotation = deg_to_rad(-150)
	particle.global_position = current_condiment.global_position
	particle.emitting = true
	
	var tween = create_tween()
	tween.tween_property(current_condiment, "position", Vector2(-10, -50), 0.5)
	tween.parallel().tween_property(particle, "position", Vector2(-10, -50), 0.5)
	tween.tween_property(current_condiment, "position", Vector2(15, -50), 0.5)
	tween.parallel().tween_property(particle, "position", Vector2(15, -50), 0.5)
	
	var tween2 = create_tween()
	for i in range(10):
		tween2.tween_property(
			current_condiment, "rotation", deg_to_rad(-170 if i % 2 == 0 else -150), 0.1
		)
		
	await tween2.finished
	
	create_droplets()
	
func create_droplets() -> void:
	for i in range(10):
		var droplet := Sprite2D.new()

		droplet.texture = particle.texture

		droplet.position = Vector2(
			randf_range(-10, 10),
			randf_range(-20, -2)
		)

		$droplets.add_child(droplet)

func finish_cooking() -> void:
	for ingredient in stacked_ingredients:
		if is_instance_valid(ingredient):
			ingredient.queue_free()
	
	stacked_ingredients.clear()
	current_ingredient = null
	
	sample_finish.visible = true
	animation_player.play("finish_saute")
