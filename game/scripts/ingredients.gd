extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ingredients: Area2D = $"."
@onready var basket: Area2D = get_tree().current_scene.get_node("cooking_station/basket")
@onready var markers = basket.get_children().filter(func(node): return node is Marker2D)
@onready var pan: Area2D = get_tree().current_scene.get_node("cooking_station/pan")
@onready var guide_canvas: CanvasLayer = get_tree().current_scene.get_node("user_interface/guide_canvas")
@onready var hint: Label = get_tree().current_scene.get_node("user_interface/hint")

var dragging = false
var drag_offset := Vector2.ZERO
var inside_basket := false
var inside_pan := false
var ingredient_name := ""
var original_position := Vector2.ZERO

static var currently_dragging: Area2D = null

func set_ingredient(name: String, image: Texture2D):
	ingredient_name = name
	sprite.texture = image
	var shape = RectangleShape2D.new()
	shape.size = image.get_size()
	collision.shape = shape

func _input(event):
	if guide_canvas.is_completing_guide_animation:
		return
	if guide_canvas.ingredient_guide_locked:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if currently_dragging:
					return
				if is_mouse_inside():
					original_position = global_position
					currently_dragging = self
					dragging = true
					drag_offset = global_position - get_global_mouse_position()
					
			else:
				if currently_dragging != self:
					return
				if not dragging:
					return
				dragging = false
				currently_dragging = null
				
				if inside_basket:
					for marker in markers:
						if marker.get_child_count() == 0:
							reparent(marker)
							position = Vector2.ZERO
							break
							
				if inside_pan:
					var section = guide_canvas.active_guide_section
					var complete := true
					for requirements in guide_canvas.guide_requirements[section]:
						var found := false
						
						if ingredient_name == requirements:
							found = true
							var task = guide_canvas.guide_tasks[section][requirements]
							task.modulate = Color.GREEN
							task.text = task.text.replace("☐", "☑")
							
							var image: Texture2D = sprite.texture
							print("reached")
							var new_ingredient = basket.create_ingredient(ingredient_name, image)
							
							pan.ingredient_to_pan(new_ingredient)
							pan.ingredient_to_pan_animation()
							queue_free()
							break
						else:
							hint.visible = true
							hint.text = "Follow the Guide!"
								
						if not found:
							complete = false
						
					if complete:
						hint.visible = false
						guide_canvas.guide_complete(section)
				self.global_position = original_position
				
	if event is InputEventMouseMotion:
		if dragging:
			global_position = get_global_mouse_position() + drag_offset
			
	#touch
	if event is InputEventScreenTouch:
		if event.pressed:
			var touch_pos = screen_to_world(event.position)
			if is_touch_inside(touch_pos):
				dragging = true
				drag_offset = global_position - touch_pos
				
		else:
			if not dragging:
				return
			dragging = false
			
			if inside_basket:
				for marker in markers:
					if marker.get_child_count() == 0:
						reparent(marker)
						position = Vector2.ZERO
						break
						
			if inside_pan:
				print("inside pan")
			
	if event is InputEventScreenDrag:
		if dragging:
			var touch_pos = screen_to_world(event.position)
			global_position = touch_pos + drag_offset

func is_mouse_inside():
	var mouse_pos = get_global_mouse_position()
	var local_mouse = collision.to_local(mouse_pos)
	
	var shape = collision.shape
	
	if shape is RectangleShape2D:
		var half_size = shape.size / 2
		return Rect2(-half_size, shape.size).has_point(local_mouse)
		
	return
	
	
func screen_to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func is_touch_inside(touch: Vector2):
	var local_point = collision.to_local(touch)
	
	var shape = collision.shape
	
	if shape is RectangleShape2D:
		var half_size = shape.size / 2
		return Rect2(-half_size, shape.size).has_point(local_point)
		
	return
