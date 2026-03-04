extends Camera3D
class_name RTSCamera

@export var move_speed: float = 20.0
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 40.0
@export var edge_scroll_margin: float = 20.0
@export var pan_smoothing: float = 10.0

var target_position: Vector3
var target_zoom: float

func _ready():
	target_position = global_position
	# For isometric view, camera should generally have a fixed rotation of 
	# roughly X: -45, Y: 45 or 0, depending on the map orientation.
	target_zoom = translation.y

func _process(delta):
	_handle_movement(delta)
	_handle_zoom(delta)
	
	# Smoothly interpolate real position to target position
	global_position = global_position.lerp(target_position, pan_smoothing * delta)

func _handle_movement(delta):
	var move_vec = Vector3.ZERO
	var mouse_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().size
	
	# Keyboard movement (WASD or Arrows)
	if Input.is_action_pressed("ui_up") or mouse_pos.y < edge_scroll_margin:
		move_vec.z -= 1
	if Input.is_action_pressed("ui_down") or mouse_pos.y > vp_size.y - edge_scroll_margin:
		move_vec.z += 1
	if Input.is_action_pressed("ui_left") or mouse_pos.x < edge_scroll_margin:
		move_vec.x -= 1
	if Input.is_action_pressed("ui_right") or mouse_pos.x > vp_size.x - edge_scroll_margin:
		move_vec.x += 1
		
	if move_vec.length_squared() > 0:
		move_vec = move_vec.normalized()
		# Depending on camera rotation, we might need to rotate the move vec
		# to match the screen's forward/right directions, but assuming a fixed angled camera:
		target_position += move_vec * move_speed * delta

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)

func _handle_zoom(delta):
	target_position.y = target_zoom
