extends Area2D

func _ready() -> void:
	input_event.connect(_on_area_input_event)

func _on_area_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked!")
