extends Button

@onready var dictionary: Node2D = $"../../../../../../resource_dictionary"
@onready var ingredient_label: Label = $"../Label"
@onready var quantity_label: Label = $"../Label2"


func _on_pressed() -> void:
	for item in dictionary.ingredients:
		if item["name"] == ingredient_label.text:
			if item["quantity"] > 0:
				item["quantity"] -= 1
				quantity_label.text = str(item["quantity"])
				break

func _on_button_2_pressed() -> void:
	for item in dictionary.ingredients:
		if item["name"] == ingredient_label.text:
			item["quantity"] += 1
			quantity_label.text = str(item["quantity"])
			break
