extends Node

signal recipes_updated(suggested_recipes: Dictionary)

var basket_items: Array = []
var current_basket_items: Array = [] 

var recipes: Dictionary = {
	"Tinolang Manok": {
		"ingredients": ["Manok", "Sayote", "Bawang", "Sibuyas", "Luya", "Malunggay", "Kanin", "Saging", ],
		"icon": "res://assets/tinola.png"
	},
	"Pinakbet": {
		"ingredients": ["Sibuyas", "Bawang", "Kalabasa", "Sitaw", "Talong", "Okra", "Ampalaya", "Baboy", "Kanin", "Saging",],
		"icon": "res://assets/pinakbet.png"
	}
}

func add_item(item_input: Variant) -> void:
	var item_data: Dictionary = {}

	if item_input is String:
		item_data = {"name": item_input, "category": "Go"}
	elif item_input is Dictionary:
		item_data = item_input
	else:
		return

	basket_items.append(item_data)
	
	var item_name = item_data.get("name", "")
	if not current_basket_items.has(item_name):
		current_basket_items.append(item_name)
		
	print("Naidagdag sa basket: ", item_name, " [Category: ", item_data.get("category", ""), "]")
	_check_all_recipes()

func remove_item(item_name: String) -> void:
	for i in range(basket_items.size() - 1, -1, -1):
		if basket_items[i].get("name") == item_name:
			basket_items.remove_at(i)
			
	var still_exists = false
	for item in basket_items:
		if item.get("name") == item_name:
			still_exists = true
			break
			
	if not still_exists:
		current_basket_items.erase(item_name)
			
	_check_all_recipes()

func get_item_texture(item_name: String) -> Texture2D:
	for item in basket_items:
		if item.get("name") == item_name and item.has("texture"):
			return item.get("texture")
	return null

func get_items_by_category(category_name: String) -> Array:
	var filtered: Array = []
	for item in basket_items:
		if item.get("category") == category_name:
			filtered.append(item)
	return filtered

func clear_basket() -> void:
	basket_items.clear()
	current_basket_items.clear()
	_check_all_recipes()

func _check_all_recipes() -> void:
	var matches: Dictionary = {}
	var current_item_names: Array = []
	
	for item in basket_items:
		var n = item.get("name")
		if n and not current_item_names.has(n):
			current_item_names.append(n)

	for recipe_name in recipes.keys():
		var recipe_data = recipes[recipe_name]
		var required_items: Array = recipe_data["ingredients"]
		var matched_items: Array = []
		var missing_items: Array = []

		for req in required_items:
			if current_item_names.has(req):
				matched_items.append(req)
			else:
				missing_items.append(req)

		if matched_items.size() >= 1:
			matches[recipe_name] = {
				"matched": matched_items,
				"missing": missing_items,
				"is_complete": missing_items.is_empty(),
				"icon": recipe_data.get("icon", "")
			}

	recipes_updated.emit(matches)
