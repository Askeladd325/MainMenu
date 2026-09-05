extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var settings_button: VBoxContainer = $"CanvasLayer/Panel/Settings Button"
@onready var language_panel: Panel = $"CanvasLayer/Panel/Language panel"
@onready var label: Label = $CanvasLayer/Panel/Label
@onready var sound_panel: Panel = $"CanvasLayer/Panel/Sound Panel"
@onready var english_btn: CheckButton = $"CanvasLayer/Panel/Language panel/VBoxContainer/englishBtn"
@onready var filipino_btn: CheckButton = $"CanvasLayer/Panel/Language panel/VBoxContainer/filipinoBtn"
@onready var kitchen: Node2D = $kitchen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	language_panel.visible = false;
	sound_panel.visible = false;
	kitchen.visible = false;

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


func _on_button_pressed() -> void:
	panel.visible = false;
	kitchen.visible = true;
