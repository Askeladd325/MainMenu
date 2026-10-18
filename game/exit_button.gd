extends TextureButton

@export var hover_scale := Vector2(1.1, 1.1)
@export var click_scale := Vector2(0.95, 0.95)
@export var transition_duration := 0.1

var default_scale := Vector2.ONE

func _ready() -> void:
	default_scale = scale
	
	pivot_offset = size / 2.0
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _animate_scale(target_scale: Vector2) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, transition_duration)

func _on_mouse_entered() -> void:
	_animate_scale(hover_scale)

func _on_mouse_exited() -> void:
	_animate_scale(default_scale)

func _on_button_down() -> void:
	_animate_scale(click_scale)

func _on_button_up() -> void:
	if is_hovered():
		_animate_scale(hover_scale)
	else:
		_animate_scale(default_scale)


func _on_pressed() -> void:
	get_tree().quit()
