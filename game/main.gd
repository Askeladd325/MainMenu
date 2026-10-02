extends Node2D

@onready var cheff = $Cheff

@onready var go_window = $"UI Manager/GoFoodWindow"
@onready var grow_window = $"UI Manager/GrowFoodWindow"
@onready var glow_window = $"UI Manager/GlowFoodWindow"

# Reference para sa BasketIcon
@onready var basket_icon = $"UI Manager/BasketIcon"

# References para sa Recipe Prompt UI & Visual Dish Cards
@onready var recipe_prompt_panel = $RecipePromptPanel
@onready var header_label = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel
@onready var dish_buttons_container = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel/DishButtonsContainer

# Visual Dish Cards
@onready var scroll_container = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel/DishButtonsContainer/ScrollContainer
@onready var dish_row_1 = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel/DishButtonsContainer/ScrollContainer/VBoxContainer/DishRow1
@onready var dish_button_1 = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel/DishButtonsContainer/ScrollContainer/VBoxContainer/DishRow1/DishImage1/DishButton1

@onready var dish_row_2 = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel/DishButtonsContainer/ScrollContainer/VBoxContainer/DishRow2
@onready var dish_button_2 = $RecipePromptPanel/MarginContainer/VBoxContainer/HeaderLabel/DishButtonsContainer/ScrollContainer/VBoxContainer/DishRow2/DishImage2/DishButton2

# Ingredient Checklist Panel References
@onready var checklist_panel = $RecipePromptPanel/MarginContainer/VBoxContainer/IngredientChecklistPanel
@onready var selected_dish_image = $RecipePromptPanel/MarginContainer/VBoxContainer/IngredientChecklistPanel/SelectedDishImage
@onready var selected_dish_title = $RecipePromptPanel/MarginContainer/VBoxContainer/IngredientChecklistPanel/SelectedDishTitle
@onready var checklist_vbox = $RecipePromptPanel/MarginContainer/VBoxContainer/IngredientChecklistPanel/ScrollContainer/VBoxContainer


# Positions ng tatlong stall sa X-axis
const GO_X_POS: float = 200.0
const GROW_X_POS: float = 900.0
const GLOW_X_POS: float = 1750.0

var current_stall_index: int = 0
var is_moving: bool = false
var current_matches: Dictionary = {}
var current_language: String = "TL"

# Tinitingnan nito kung nakabukas ang checklist o hindi
var is_checklist_open: bool = false
var current_selected_dish: String = ""

# Translation Dictionary
var translations: Dictionary = {
	"TL": {
		"header_selection": "MGA PWEDENG LUTUIN",
		"header_checklist": "CHECKLIST",
		"back_button": "◀ Bumalik",
		"complete": "\n🎉 KUMPLETO NA ANG INGREDIENTS!"
	},
	"EN": {
		"header_selection": "POSSIBLE DISHES",
		"header_checklist": "CHECKLIST",
		"back_button": "◀ Back",
		"complete": "\n🎉 INGREDIENTS COMPLETE!"
	}
}

func _ready() -> void:
	cheff.global_position.x = GO_X_POS
	
	# Nakatago muna ang lahat ng UI Windows sa simula ng laro
	_show_window(null)
	
	# Automatic Center Alignment para sa Headers
	if is_instance_valid(header_label):
		header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_instance_valid(selected_dish_title):
		selected_dish_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if is_instance_valid(recipe_prompt_panel):
		recipe_prompt_panel.visible = false
	if is_instance_valid(checklist_panel):
		checklist_panel.visible = false
		

		
	if is_instance_valid(dish_button_1):
		dish_button_1.pressed.connect(func(): _show_dish_checklist("Tinolang Manok"))
	if is_instance_valid(dish_button_2):
		dish_button_2.pressed.connect(func(): _show_dish_checklist("Pinakbet"))
		
	if is_instance_valid(BasketManager):
		BasketManager.recipes_updated.connect(_on_recipes_updated)

	# MAG-AANTAY NG 3 SECONDS BAGO LUMABAS ANG GO FOOD WINDOW
	await get_tree().create_timer(3.0).timeout
	_show_window(go_window)

# --- STALL NAVIGATION LOGIC ---
func _on_next_stall_button_pressed() -> void:
	if is_moving:
		return
		
	current_stall_index += 1
	if current_stall_index > 2:
		current_stall_index = 0
		
	_move_cheff_to_stall(current_stall_index)

func _on_prev_stall_button_pressed() -> void:
	if is_moving:
		return
		
	current_stall_index -= 1
	if current_stall_index < 0:
		current_stall_index = 2
		
	_move_cheff_to_stall(current_stall_index)

func _move_cheff_to_stall(index: int) -> void:
	is_moving = true
	var target_x: float
	var target_window: Control
	
	_show_window(null)
	
	match index:
		0:
			target_x = GO_X_POS
			target_window = go_window
		1:
			target_x = GROW_X_POS
			target_window = grow_window
		2:
			target_x = GLOW_X_POS
			target_window = glow_window

	var tween = create_tween()
	tween.tween_property(cheff, "global_position:x", target_x, 1.0)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	_show_window(target_window)
	is_moving = false

func _show_window(active_window: Control) -> void:
	go_window.visible = (active_window == go_window)
	grow_window.visible = (active_window == grow_window)
	glow_window.visible = (active_window == glow_window)
	
	if is_instance_valid(basket_icon):
		basket_icon.visible = (active_window != null)
		
		if active_window == null and "basket_window" in basket_icon and is_instance_valid(basket_icon.basket_window):
			basket_icon.basket_window.visible = false

# --- RECIPE PROMPT LOGIC ---
func _on_recipes_updated(matches: Dictionary) -> void:
	current_matches = matches
	if matches.is_empty():
		recipe_prompt_panel.visible = false
		is_checklist_open = false
		current_selected_dish = ""
	else:
		recipe_prompt_panel.visible = true
		
		if is_checklist_open and current_selected_dish != "":
			_show_dish_checklist(current_selected_dish)
		else:
			_show_dish_selection_list()

func _show_dish_selection_list() -> void:
	var lang = translations[current_language]
	header_label.text = lang["header_selection"]
	checklist_panel.visible = false
	dish_buttons_container.visible = true
	
	dish_row_1.visible = false
	dish_row_2.visible = false
	
	if current_matches.has("Tinolang Manok"):
		dish_row_1.visible = true
		
	if current_matches.has("Pinakbet"):
		dish_row_2.visible = true

func _show_dish_checklist(dish_name: String) -> void:
	if not current_matches.has(dish_name):
		return

	is_checklist_open = true
	current_selected_dish = dish_name

	var lang = translations[current_language]
	header_label.text = lang["header_checklist"]
	
	dish_buttons_container.visible = false
	checklist_panel.visible = true
	
	var data = current_matches[dish_name]
	selected_dish_title.text = dish_name
	
	if data.has("icon") and ResourceLoader.exists(data["icon"]):
		selected_dish_image.texture = load(data["icon"])
		selected_dish_image.visible = true
		
		selected_dish_image.custom_minimum_size = Vector2(100, 100)
		selected_dish_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		selected_dish_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		selected_dish_image.position.y = 10
	else:
		selected_dish_image.visible = false
	
	
	for child in checklist_vbox.get_children():
		child.queue_free()

	# 2. Kunin ang lahat ng kailangang ingredients ng recipe mula sa BasketManager
	var all_ingredients = []
	if BasketManager.recipes.has(dish_name):
		all_ingredients = BasketManager.recipes[dish_name]["ingredients"]

	# 3. Gumawa ng CheckBox para sa bawat ingredient
	for item in all_ingredients:
		var checkbox = CheckBox.new()
		checkbox.text = item
		
		# GAWING KULAY ITIM ANG TEXT COLOR NG CHECKBOX
		checkbox.add_theme_color_override("font_color", Color.BLACK)
		checkbox.add_theme_color_override("font_pressed_color", Color.BLACK)
		checkbox.add_theme_color_override("font_hover_color", Color.BLACK)
		checkbox.add_theme_color_override("font_disabled_color", Color.BLACK)
		
		# --- PAG-ADJUST NG FONT SIZE, LAKI, AT CHECK MARK ICON ---
		checkbox.add_theme_font_size_override("font_size", 30)
		checkbox.custom_minimum_size = Vector2(0, 50)
		checkbox.scale = Vector2(5.0, 5.0) # Pwede mong taasan pa (hal. 1.8 o 2.0) kung gusto mo pang mas lumaki
		# ---------------------------------------------------------
		
		# I-check kung ito ay nahanap na sa basket (nasa matched list)
		if item in data["matched"]:
			checkbox.button_pressed = true
		else:
			checkbox.button_pressed = false
			
		# I-disable para hindi ito ma-manual click ng player (awtomatiko base sa basket)
		checkbox.disabled = true
		
		# Idagdag sa VBoxContainer
		checklist_vbox.add_child(checkbox)

	# 4. Kung kumpleto na ang recipe, magdagdag ng completion text sa dulo ng VBoxContainer
	if data["is_complete"]:
		var complete_label = Label.new()
		complete_label.text = lang["complete"]
		complete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		complete_label.add_theme_color_override("font_color", Color.BLACK)
		complete_label.add_theme_font_size_override("font_size", 30)
		checklist_vbox.add_child(complete_label)

# --- BUTTON SIGNALS ---
func _on_go_next_stall_button_pressed() -> void:
	_on_next_stall_button_pressed()

func _on_grow_next_stall_button_pressed() -> void:
	_on_next_stall_button_pressed()

func _on_grow_prev_stall_button_pressed() -> void:
	_on_prev_stall_button_pressed()

func _on_glow_prev_stall_button_pressed() -> void:
	_on_prev_stall_button_pressed()

func _on_proceed_button_pressed() -> void:
	get_tree().change_scene_to_file("res://dish_selection_scene.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select.tscn")
