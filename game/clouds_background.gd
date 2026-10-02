extends ParallaxBackground

# Bilis ng paggalaw ng ulap (pwedeng lakasan o hinaan sa Inspector)
@export var cloud_speed: float = 20.0

@onready var parallax_layer: ParallaxLayer = $ParallaxLayer

func _process(delta: float) -> void:
	# I-move ang offset ng ParallaxLayer papuntang kaliwa
	parallax_layer.motion_offset.x -= cloud_speed * delta
