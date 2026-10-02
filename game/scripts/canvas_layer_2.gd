extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func ready():
	color_rect.visible = false
	
	
	
func transition():
	color_rect.visible = true
