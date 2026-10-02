extends Control

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

func _ready() -> void:
	connect("visibility_changed", _on_visibility_changed)
	
	if is_instance_valid(BasketManager):
		if BasketManager.has_signal("recipes_updated"):
			BasketManager.recipes_updated.connect(func(_matches): update_basket_display())

func _on_visibility_changed() -> void:
	if visible:
		update_basket_display()

func update_basket_display() -> void:
	# Linisin muna ang lumang items sa UI grid
	for child in grid_container.get_children():
		child.queue_free()
		
	if not is_instance_valid(BasketManager):
		return
		
	# I-loop ang lahat ng nai-save na items mula sa BasketManager
	for item_name in BasketManager.current_basket_items:
		var item_box = HBoxContainer.new()
		item_box.add_theme_constant_override("separation", 15)
		
		# 1. Image Icon
		var slot = TextureRect.new()
		if BasketManager.has_method("get_item_texture"):
			slot.texture = BasketManager.get_item_texture(item_name)
		slot.custom_minimum_size = Vector2(64, 64)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# 2. Label ng Pangalan ng Pagkain (Kulay Itim)
		var label = Label.new()
		label.text = item_name
		label.add_theme_color_override("font_color", Color.BLACK)
		label.add_theme_font_size_override("font_size", 24)
		
		# 3. Button para sa pagtanggal (Remove)
		var remove_btn = Button.new()
		remove_btn.text = " Alisin "
		remove_btn.pressed.connect(func(): _on_remove_item_pressed(item_name))
		
		item_box.add_child(slot)
		item_box.add_child(label)
		item_box.add_child(remove_btn)
		
		grid_container.add_child(item_box)

func _on_remove_item_pressed(item_name: String) -> void:
	if is_instance_valid(BasketManager) and BasketManager.has_method("remove_item"):
		BasketManager.remove_item(item_name)
		update_basket_display()
