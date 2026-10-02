extends TextureButton

@export var basket_window: Control
@export var item_container: Control

# Properties para sa Pop/Bounce Animation
@export var bounce_scale: Vector2 = Vector2(1.25, 1.25) # Lalaki ng 25%
@export var bounce_duration: float = 0.12 # Bilis ng animation

var basket_items: Dictionary = {}
var original_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	if basket_window:
		basket_window.visible = false
		
	# I-save ang orihinal na scale
	original_scale = scale
	
	# Set pivot sa center para pantay ang pag-pop ng button
	pivot_offset = size / 2.0
	
	pressed.connect(_on_basket_pressed)
	_play_idle_animation()

func _play_idle_animation() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 3, 0.75).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 0.75).set_trans(Tween.TRANS_SINE)

# --- POP ANIMATION (KAPAG NAKAKUHA NG ITEM) ---
func play_bounce_animation() -> void:
	# Siguraduhing naisasaayos ang pivot kapag nagbago man ang size ng UI
	pivot_offset = size / 2.0
	
	var tween = create_tween()
	# 1. Mabilis na lalakid/pumopop
	tween.tween_property(self, "scale", bounce_scale, bounce_duration)\
		 .set_trans(Tween.TRANS_BACK)\
		 .set_ease(Tween.EASE_OUT)
		
	# 2. Smooth na babalik sa normal scale
	tween.tween_property(self, "scale", original_scale, bounce_duration)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)

func _on_basket_pressed() -> void:
	if basket_window:
		basket_window.visible = !basket_window.visible

func _on_close_button_pressed() -> void:
	if basket_window:
		basket_window.visible = false

# --- DRAG AND DROP HANDLERS ---
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("texture") and data.has("name")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var category = data.get("category", "Go")
	add_item_to_basket(data.name, data.texture, category)
	
	# POP/BOUNCE ANIMATION KAPAG NA-DROP ANG ITEM
	play_bounce_animation()
	
	# PADALHAN NG DATA ANG BASKET MANAGER PARA LUMABAS ANG RECIPE PANEL
	if is_instance_valid(BasketManager):
		BasketManager.add_item(data)

# --- BASKET LOGIC ---
func add_item_to_basket(food_name: String, food_texture: Texture2D, food_category: String = "") -> void:
	if basket_items.has(food_name):
		_add_quantity(food_name)
		return

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	
	var img = TextureRect.new()
	img.texture = food_texture
	img.custom_minimum_size = Vector2(70, 70)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	var name_label = Label.new()
	name_label.text = food_name
	name_label.add_theme_font_size_override("font_size", 40)
	name_label.add_theme_color_override("font_color", Color.BLACK)
	
	var qty_label = Label.new()
	qty_label.text = "x1"
	qty_label.add_theme_font_size_override("font_size", 25)
	
	var delete_btn = Button.new()
	delete_btn.text = " Remove "
	delete_btn.custom_minimum_size = Vector2(50, 50)
	delete_btn.add_theme_font_size_override("font_size", 25)
	delete_btn.pressed.connect(func(): _delete_item(food_name))
	
	row.add_child(img)
	row.add_child(name_label)
	row.add_child(qty_label)
	row.add_child(delete_btn)
	
	if item_container:
		item_container.add_child(row)
		
	basket_items[food_name] = {
		"quantity": 1,
		"category": food_category,
		"row_node": row,
		"qty_label": qty_label
	}

func _add_quantity(food_name: String) -> void:
	if basket_items.has(food_name):
		basket_items[food_name]["quantity"] += 1
		var current_qty = basket_items[food_name]["quantity"]
		basket_items[food_name]["qty_label"].text = "x" + str(current_qty)

func _subtract_quantity(food_name: String) -> void:
	if not basket_items.has(food_name):
		return
		
	var item_data = basket_items[food_name]
	item_data["quantity"] -= 1
	
	if item_data["quantity"] > 0:
		item_data["qty_label"].text = "x" + str(item_data["quantity"])
	else:
		_delete_item(food_name)

func _delete_item(food_name: String) -> void:
	if basket_items.has(food_name):
		basket_items[food_name]["row_node"].queue_free()
		basket_items.erase(food_name)
		
		# I-UPDATE DIN ANG BASKET MANAGER KAPAG NATANGGAL ANG ITEM
		if is_instance_valid(BasketManager) and BasketManager.has_method("remove_item"):
			BasketManager.remove_item(food_name)
