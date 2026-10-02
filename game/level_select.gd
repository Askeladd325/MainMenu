extends Control

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	pass

# --- BUTTON SIGNALS ---

func _on_level_button_1_pressed() -> void:
	await play_click_sfx()
	GameData.set_level(1, "3-5 years old")
	get_tree().change_scene_to_file("res://main.tscn")

func _on_level_button_2_pressed() -> void:
	await play_click_sfx()
	GameData.set_level(2, "6-9 years old")
	get_tree().change_scene_to_file("res://main.tscn")

func _on_level_button_3_pressed() -> void:
	await play_click_sfx()
	GameData.set_level(3, "10-12 years old")
	get_tree().change_scene_to_file("res://main.tscn")

func _on_home_button_pressed() -> void:
	await play_click_sfx()
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_settings_button_pressed() -> void:
	await play_click_sfx()
	get_tree().change_scene_to_file("res://settings.tscn")

# --- AUDIO HELPER ---

func play_click_sfx() -> void:
	if has_node("AudioStreamPlayer") and audio_player and audio_player.stream:
		audio_player.play()
		await get_tree().create_timer(0.15).timeout
