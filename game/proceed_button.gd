extends TextureButton

func _ready() -> void:
	# I-set ang pivot point sa gitna para pantay ang pagliit at paglaki
	pivot_offset = size / 2
	
	# I-connect ang click at release signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	resized.connect(_on_resized)

func _on_resized() -> void:
	pivot_offset = size / 2

func _on_button_down() -> void:
	# Paliitin ang button sa 85% kapag pinindot
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_button_up() -> void:
	# Bumuwanse pabalik sa 100% kapag binitawan
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
