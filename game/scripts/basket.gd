extends Area2D

@onready var basket: Area2D = $"."
@onready var dictionary: Node2D = $"../../resource_dictionary"
@onready var markers = basket.get_children().filter(func(node): return node is Marker2D)

const ingredient_scene = preload("res://ingredients.tscn")

var created_ingredients: Array[Area2D] = []

func create_ingredient(name: String, image: Texture2D):
	var new_ingredient = ingredient_scene.instantiate()
	add_child(new_ingredient)
	new_ingredient.set_ingredient(name, image)
	
	return new_ingredient

func _on_area_entered(area: Area2D) -> void:
	area.inside_basket = true
	
func _on_area_exited(area: Area2D) -> void:
	area.inside_basket = false

func _on_button_pressed() -> void:
	var slot := 0
	for item in dictionary.ingredients:
		if item["quantity"] > 0:
			for i in item["quantity"]:
				if slot >= markers.size():
					return
				var new_ingredient = create_ingredient(item["name"], item["image"])
				new_ingredient.global_position = markers[slot].global_position
				created_ingredients.append(new_ingredient)
				
				slot += 1
