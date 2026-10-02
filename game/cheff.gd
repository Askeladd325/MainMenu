extends CharacterBody2D

@export var speed: float = 200.0

# Function para i-move si Cheff gamit ang Tween galing sa UIManager
func move_to_x(target_x: float, duration: float = 1.2) -> Tween:
	var tween = create_tween()
	tween.tween_property(self, "global_position:x", target_x, duration)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
	return tween
