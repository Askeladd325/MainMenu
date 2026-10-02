extends Control

@export var item_name: String = "Food Item"
@export var item_category: String = "Go" # Go, Grow, o Glow para sa Pinggang Pinoy
@export var item_texture: Texture2D

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Icon/Label

func _ready() -> void:
	# 1. I-assign ang text sa Label kung may Label node
	if label:
		label.text = item_name
	
	# 2. I-assign ang texture sa Icon Node kung may nakalagay sa Inspector
	if item_texture and icon:
		icon.texture = item_texture
	
	# 3. NAPAKAHALAGA SA MOBILE: Huwag hayaang harangan ng Icon at Label ang touch ng Control node
	if icon:
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if label:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Tiyaking may texture muna bago payagan ang drag
	if not icon or not icon.texture:
		return null

	# 1. Lumikha ng TextureRect para sa visual preview habang dinedrag ng daliri
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.custom_minimum_size = Vector2(80, 80) # Ginawang 80x80 para malinaw sa mobile screen
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	# 2. I-center ang preview sa mismong dulo ng daliri/cursor
	var drag_preview = Control.new()
	drag_preview.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2.0
	
	set_drag_preview(drag_preview)
	
	# 3. Ipadala ang data na babasahin ng Basket (kasama ang category para sa evaluation)
	return {
		"name": item_name,
		"category": item_category,
		"texture": icon.texture
	}
