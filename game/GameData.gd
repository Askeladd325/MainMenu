extends Node

var selected_level: int = 1 # 1 = 3-5yo, 2 = 6-9yo, 3 = 10-12yo
var selected_age_group: String = "3-5 years old"

func set_level(level_id: int, age_label: String) -> void:
	selected_level = level_id
	selected_age_group = age_label
	print("Level selected: ", selected_age_group)
