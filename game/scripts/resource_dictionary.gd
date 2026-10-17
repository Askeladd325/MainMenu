extends Node2D

var cooking_container = [
	{"name": "Pan", "image": preload("res://res/kitchen/pan v5.png")},
	{"name": "Pot_Back", "image": preload("res://res/kitchen/pot_back.png")},
	{"name": "Pot_Front", "image": preload("res://res/kitchen/pot_front.png")}
]

var utensils = [
	{"name": "Spatula", "image": preload("res://res/kitchen/spatula.png")},
	{"name": "Ladle", "image": preload("res://res/kitchen/ladle.png")}
]

var ingredients = [
	{"name": "Artichoke", "quantity": 0, "image": preload("res://res/vegetables/artichoke_01.png")},
	{"name": "Asparagus", "quantity": 0, "image": preload("res://res/vegetables/asparagus_01.png")},
	{"name": "Avocado", "quantity": 0, "image": preload("res://res/vegetables/avacado_01.png")},
	{"name": "Beet", "quantity": 0, "image": preload("res://res/vegetables/beet_01.png")},
	{"name": "Bell Pepper", "quantity": 0, "image": preload("res://res/vegetables/bell pepper_01.png")},
	{"name": "Cabbage", "quantity": 0, "image": preload("res://res/vegetables/cabbage_01.png")},
	{"name": "Chicken", "quantity": 0, "image": preload("res://res/meats/chicken.png")},
	{"name": "Garlic", "quantity": 0, "image": preload("res://res/vegetables/garlic_01.png")},
	{"name": "Ginger", "quantity": 0, "image": preload("res://res/vegetables/ginger_01.png")},
	{"name": "Onion", "quantity": 0, "image": preload("res://res/vegetables/onion_01.png")}	
]

var condiments = [
	{"name": "Salt", "image": preload("res://res/kitchen/salt.png")},
	{"name": "Soy Sauce", "image": preload("res://res/kitchen/soy_sauce.png")},
	{"name": "Cooking Oil", "image": preload("res://res/kitchen/cooking_oil.png")},
	{"name": "Water", "image": preload("res://res/kitchen/pitcher-1.png.png")}
]

var particles = [
	{"name": "Salt", "image": preload("res://res/kitchen/salt_particle.png")},
	{"name": "Soy Sauce", "image": preload("res://res/kitchen/soy_sauce_particle.png")},
	{"name": "Cooking Oil", "image": preload("res://res/kitchen/oil_particle.png")},
	{"name": "Water", "image": preload("res://res/kitchen/pitcher_particle.png")}
]

var dishes = [
	{
		"name": "Chicken Tinola", "type": {"Soup": true, "Saute": true},
		"ingredients": {
			"saute_condiments": [
				{"name": "Cooking Oil", "required": true}
			],
			"aromatics": [
				{"name": "Garlic", "required": true},
				{"name": "Ginger", "required": true},
				{"name": "Onion", "required": true}
			],
			"saute_main": [
				{"name": "Chicken", "required": true}
			],
			"liquid": [
				{"name": "Water", "required": true}
			],
			"main": [
				{"name": "Sayote"},
				{"name": "Moringa Leaf", "required": true}
			],
			"seasoning": [
				{"name": "Bouillon Cube", "required": true}
			],
			"condiments": [
				{"name": "Soy Sauce"},
				{"name": "Salt", "required": true}
			]
		}
	}
]
