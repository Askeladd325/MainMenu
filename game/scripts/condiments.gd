extends Area2D

@onready var pan: Area2D = get_tree().current_scene.get_node("cooking_station/pan")
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var particle: GPUParticles2D = get_tree().current_scene.get_node("cooking_station/pan/GPUParticles2D")
@onready var guide_canvas: CanvasLayer = get_tree().current_scene.get_node("user_interface/guide_canvas")
@onready var hint: Label = get_tree().current_scene.get_node("user_interface/hint")

var dragging := false
var drag_offset := Vector2.ZERO
var inside_basket := false
var inside_pan := false
var condiment_name := ""
var original_position = Vector2.ZERO
static var currently_dragging: Area2D = null

func _ready():
	original_position = global_position
	particle.emitting = false

func set_condiment(name: String, image: Texture2D):
	condiment_name = name
	sprite.texture = image
	var shape = RectangleShape2D.new()
	shape.size = image.get_size()
	collision.shape = shape

func _input(event):
	if guide_canvas.is_completing_guide_animation:
		return
	if guide_canvas.condiment_guide_locked:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if currently_dragging:
					return
				if is_mouse_inside():
					currently_dragging = self
					original_position = global_position
					dragging = true
					drag_offset = global_position - get_global_mouse_position()
					
			else:
				if currently_dragging != self:
					return
				if not dragging:
					return
				dragging = false
				currently_dragging = null
				if inside_pan:
					for section in guide_canvas.guide_requirements:
						if guide_canvas.guide_requirements[section].has(condiment_name):
							var task = guide_canvas.guide_tasks[section][condiment_name]
							task.modulate = Color.GREEN
							task.text = task.text.replace("☐", "☑")
							hint.visible = false
							pan.condiment_to_pan(self)
							await pan.condiment_to_pan_animation()
							guide_canvas.guide_complete(section)
						else:
							hint.visible = true
							hint.text = "Follow the Guide!"
					self.rotation = 0
					particle.emitting = false
					
				self.global_position = original_position
	if event is InputEventMouseMotion:
		if dragging:
			global_position = get_global_mouse_position() + drag_offset

func screen_to_world(screen_pos: Vector2):
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func is_touch_inside(touch: Vector2):
	var local_touch = collision.to_local(touch)
	
	var shape = collision.shape
	
	if shape is RectangleShape2D:
		var half_size = shape.size / 2
		return Rect2(-half_size, shape.size).has_point(local_touch)
		
	return

func is_mouse_inside():
	var mouse_pos = get_global_mouse_position()
	var local_mouse = collision.to_local(mouse_pos)
	
	var shape = collision.shape
	
	if shape is RectangleShape2D:
		var half_size = shape.size / 2
		return Rect2(-half_size, shape.size).has_point(local_mouse)
		
	return
