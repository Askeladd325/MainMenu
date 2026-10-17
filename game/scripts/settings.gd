extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var settings_button: VBoxContainer = $"CanvasLayer/Panel/Settings Button"
@onready var language_panel: Panel = $"CanvasLayer/Panel/Language panel"
@onready var label: Label = $CanvasLayer/Panel/Label
@onready var sound_panel: Panel = $"CanvasLayer/Panel/Sound Panel"
@onready var english_btn: CheckButton = $"CanvasLayer/Panel/Language panel/VBoxContainer/englishBtn"
@onready var filipino_btn: CheckButton = $"CanvasLayer/Panel/Language panel/VBoxContainer/filipinoBtn"
@onready var kitchen: Node2D = $kitchen
@onready var cooking_station: Node2D = $cooking_station
@onready var joystick_canvas: CanvasLayer = $kitchen/joystick_canvas
@onready var dictionary: Node2D = $resource_dictionary
@onready var condiment_markers: Node2D = $"cooking_station/condiment markers"
@onready var markers = condiment_markers.get_children().filter(func(node): return node is Marker2D)
@onready var guide_canvas: CanvasLayer = $user_interface/guide_canvas
@onready var minigames: Control = $minigames_canvas/Minigames
@onready var base: GPUParticles2D = $cooking_station/background/base

const condiment_scene = preload("res://res/scenes/condiments.tscn")

func _ready() -> void:
	language_panel.visible = false;
	sound_panel.visible = false;
	kitchen.visible = false;
	cooking_station.visible = true;
	joystick_canvas.visible = false;
	
	var slot := 0
	
	for condiment_list in dictionary.condiments:
		var condiment = condiment_scene.instantiate()
		add_child(condiment)
		condiment.set_condiment(condiment_list["name"], condiment_list["image"])
		
		condiment.global_position = markers[slot].global_position
		
		slot += 1

func zoom_to_point(camera: Camera2D, point: Vector2, zoom_value: float) -> void:
	camera.global_position = point
	camera.zoom = Vector2(zoom_value, zoom_value)

func _on_language_pressed() -> void:
	language_panel.visible = true;
	settings_button.visible = false;
	label.visible = false;

func _on_back_pressed() -> void:
	language_panel.visible = false;
	settings_button.visible = true;
	label.visible = true;

func _on_soundSetting_pressed() -> void:
	sound_panel.visible = true;
	settings_button.visible = false;
	label.visible = false;


func _on_soundBack_pressed() -> void:
	sound_panel.visible = false;
	settings_button.visible = true;
	label.visible = true;

func _on_languageSaveBtn_pressed() -> void:
	if english_btn.button_pressed:
		TranslationServer.set_locale("english");
	elif filipino_btn.button_pressed: 
		TranslationServer.set_locale("filipino");
		
	language_panel.visible = false;
	settings_button.visible = true;
	label.visible = true;

func _on_play_pressed() -> void:
	panel.visible = false;
	joystick_canvas.visible = true;
	kitchen.visible = true;

func _on_texture_button_pressed() -> void:
	if base.emitting:
		return
	minigames.visible = true
