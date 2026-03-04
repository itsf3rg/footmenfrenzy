extends CharacterBody3D
class_name HeroUnit

# Agent 2: Base Hero scripting. MOBA-style direct control.

@export var hero_id: String = "base_hero"
@export var movement_speed: float = 8.0

# Stats populated by Agent 5's JSON data
var max_health: float = 500.0
var current_health: float
var max_mana: float = 200.0
var current_mana: float

# Abilities (References to Ability Resource nodes)
var ability_q: Node
var ability_w: Node
var ability_e: Node
var ability_r: Node # Ultimate

@onready var navigation_agent = $NavigationAgent3D

var is_local_player: bool = false
var target_position: Vector3

func _ready():
	current_health = max_health
	current_mana = max_mana
	target_position = global_position

func setup_local_player():
	is_local_player = true
	# Attach camera or notify CameraController to follow this hero
	pass

func _physics_process(delta):
	if not is_local_player:
		# If this is a networked peer, movement is driven by the GameStateSynchronizer
		return
		
	# MOBA-style click-to-move input
	if Input.is_action_just_pressed("right_click"):
		_handle_movement_input()
		
	_execute_movement(delta)
	_handle_ability_inputs()

func _handle_movement_input():
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Raycast from camera to ground plane
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	# Assuming a flat map at y=0 for the prototype
	var t = -ray_origin.y / ray_dir.y if ray_dir.y != 0 else 0
	target_position = ray_origin + ray_dir * t
	
	navigation_agent.set_target_position(target_position)

func _execute_movement(delta):
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return
		
	var next_pos = navigation_agent.get_next_path_position()
	var dir = global_position.direction_to(next_pos)
	
	velocity = dir * movement_speed
	
	if velocity.length_squared() > 0.1:
		look_at(global_position + velocity, Vector3.UP)
		
	move_and_slide()

func _handle_ability_inputs():
	if Input.is_action_just_pressed("ability_q") and ability_q:
		ability_q.try_cast(self)
	elif Input.is_action_just_pressed("ability_w") and ability_w:
		ability_w.try_cast(self)
	# ... etc
