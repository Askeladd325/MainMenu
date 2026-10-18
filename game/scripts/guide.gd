extends CanvasLayer
@onready var guide_container: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/guide_container
@onready var dictionary: Node2D = $"../../resource_dictionary"
@onready var button_2: Button = $"../../cooking_station/Button2"
@onready var button_1: Button = $"../../cooking_station/Button1"
@onready var cooking_station: Node2D = $"../../cooking_station"
@onready var hint: Label = $"../hint"
@onready var minigames: Control = $"../../minigames_canvas/Minigames"
@onready var pan_sprite: Sprite2D = $"../../cooking_station/pan/Sprite2D"
@onready var spatula: Sprite2D = $"../../cooking_station/pan/spatula"
@onready var pan_front: Sprite2D = $"../../cooking_station/pan/pan_front"

var guide_tasks = {}
var guide_sections = {}
var guide_requirements = {}
var guide_queue = []
var active_guide_section: String = ""
var condiment_guide_locked := true
var ingredient_guide_locked := true
var is_completing_guide_animation := false

func show_next_guide():
	if guide_queue.is_empty():
		active_guide_section = ""
		return
	
	var next_guide = guide_queue.pop_front()
	var title = next_guide["title"]
	var ingredients = next_guide.get("ingredients", [])
	var step_type = next_guide.get("type", "ingredients")
	
	create_guide(title, ingredients)

	
	if step_type == "stir":
		minigames.pan_stir()
	


func create_guide(title_text: String, ingredients: Array = []):
	if active_guide_section != "":
		return 
		
	active_guide_section = title_text 
	
	var panel = PanelContainer.new()
	guide_container.add_child(panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0,0,0,0)
	panel.add_theme_stylebox_override("panel", style)
	
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 0)
	panel.add_child(section)
	
	guide_sections[title_text] = panel
	guide_requirements[title_text] = []
	
	var title_margin = MarginContainer.new()
	title_margin.add_theme_constant_override("margin_left", 4)
	section.add_child(title_margin)
	
	var title = Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 10)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_margin.add_child(title)
	
	var task_margin = MarginContainer.new()
	task_margin.add_theme_constant_override("margin_left", 12)
	section.add_child(task_margin)
	
	var tasks = VBoxContainer.new()
	tasks.add_theme_font_size_override("font_size", 8)
	tasks.add_theme_constant_override("separation", 0)
	task_margin.add_child(tasks)
	
	guide_tasks[title_text] = {}
	
	for ingredient in ingredients:
		var task = Label.new()
		task.text = "☐ " + "add " + ingredient["name"]
		task.add_theme_font_size_override("font_size", 8)
		task.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tasks.add_child(task)
		
		guide_tasks[title_text][ingredient["name"]] = task
		guide_requirements[title_text].append(ingredient["name"])

func guide_complete(section_name):
	print("guide compelte", guide_sections)
	if not guide_sections.has(section_name):
		return

	is_completing_guide_animation = true
	var panel = guide_sections[section_name]
	
	guide_sections.erase(section_name)
	guide_tasks.erase(section_name)
	
	if is_instance_valid(panel):
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color.LIME_GREEN
		style.bg_color.a = 0.5
		panel.add_theme_stylebox_override("panel", style)
		
		await get_tree().create_timer(1).timeout
		
		if is_instance_valid(panel):
			var tween = create_tween()
			
			tween.tween_property(
				panel,
				"position:x",
				panel.position.x + 100,
				1.0
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
			tween.parallel().tween_property(
				panel,
				"modulate:a",
				0.0,
				0.4
			)
			
			await tween.finished
			if is_instance_valid(panel):
				panel.queue_free()
		is_completing_guide_animation = false

	active_guide_section = ""

	show_next_guide()

func _on_button_1_pressed() -> void:
	guide_queue.clear()
	for dish in dictionary.dishes:
		if dish["name"] == button_2.text:
			if dish["type"].has("Soup"):
				for container in dictionary.cooking_container:
					if container["name"] == "Pot_Back":
						pan_sprite.texture = container["image"]
						pan_sprite.position.y = -18
						
					if container["name"] == "Pot_Front":
						pan_front.visible = true
						pan_front.texture = container["image"]
						pan_front.position.y = -18
						pan_front.z_index = 2
						
				for utensil in dictionary.utensils:
					if utensil["name"] == "Ladle":
						spatula.texture = utensil["image"]
						spatula.flip_h = false
						spatula.scale = Vector2(1.0, 1.0)
						spatula.position = Vector2(10, -24.5)
			hint.set_visible(true)
			hint.text = "Start the stove"
			
			var tween = create_tween()
			tween.set_loops()
			
			tween.tween_property(hint, "modulate:a", 0.5, 1.0)
			tween.tween_property(hint, "modulate:a", 1.0, 1.0)
			if dish["type"].get("Saute", false):
				saute_guide(dish)
			if dish["type"].get("Soup", false):
				soup_guide(dish)
			if dish["type"].get("Fried", false):
				frying_guide(dish)
			break
	show_next_guide()

#paste to _ready once there's a working ingredient selection/dish selection
func _on_button_2_pressed() -> void:
	guide_queue.clear()
	for dish in dictionary.dishes:
		if dish["name"] == button_2.text:
			if dish["type"].has("Soup"):
				for container in dictionary.cooking_container:
					if container["name"] == "Pot_Back":
						pan_sprite.texture = container["image"]
						pan_sprite.position.y = -18
						
					if container["name"] == "Pot_Front":
						pan_front.visible = true
						pan_front.texture = container["image"]
						pan_front.position.y = -18
						pan_front.z_index = 2
						
				for utensil in dictionary.utensils:
					if utensil["name"] == "Ladle":
						spatula.texture = utensil["image"]
						spatula.flip_h = false
						spatula.scale = Vector2(1.0, 1.0)
						spatula.position = Vector2(10, -24.5)
			hint.set_visible(true)
			hint.text = "Start the stove"
			
			var tween = create_tween()
			tween.set_loops()
			
			tween.tween_property(hint, "modulate:a", 0.5, 1.0)
			tween.tween_property(hint, "modulate:a", 1.0, 1.0)
			if dish["type"].get("Saute", false):
				saute_guide(dish)
			if dish["type"].get("Soup", false):
				soup_guide(dish)
			if dish["type"].get("Fried", false):
				frying_guide(dish)
			break
	show_next_guide()


func saute_guide(dish):
	guide_queue.append({
		"title": "Prepare the pan",
		"ingredients": dish["ingredients"].get("saute_condiments", [])
	})
	guide_queue.append({
		"title": "Saute the aromatics",
		"ingredients": dish["ingredients"].get("aromatics", [])
	})
	
	guide_queue.append({
		"title": "Stir the pan",
		"type": "stir"
	})
	
	guide_queue.append({
		"title": "Sear the base ingredient",
		"ingredients": dish["ingredients"].get("saute_main", [])
	})
	guide_queue.append({
		"title": "Stir the pan",
		"type": "stir"
	})
	
func soup_guide(dish):
	guide_queue.append({
		"title": "Pour the base of soup",
		"ingredients": dish["ingredients"].get("liquid", [])
	})
	guide_queue.append({
		"title": "Put all main ingredients",
		"ingredients": dish["ingredients"].get("main", [])
	})
	guide_queue.append({
		"title": "Add Condiments",
		"ingredients": dish["ingredients"].get("condiments", [])
	})
	
func frying_guide(dish):
	guide_queue.append({
		"title": "Fry main ingredients",
		"ingredients": dish["ingredients"].get("main", [])
	})
