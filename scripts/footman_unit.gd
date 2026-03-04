extends CharacterBody3D
class_name FootmanUnit

@export var movement_speed: float = 5.0
@export var attack_range: float = 2.0
@export var damage: float = 10.0
@export var max_health: float = 100.0
@export var faction_id: int = 0  # 0: Fire, 1: Water, 2: Light, 3: Poison

@onready var navigation_agent = $NavigationAgent3D

var current_health: float
var target: Node3D = null

func _ready():
	current_health = max_health
	# Start moving towards the center of the map immediately
	set_movement_target(Vector3.ZERO)

func _physics_process(delta):
	if target and is_instance_valid(target):
		_handle_combat(delta)
	else:
		_handle_movement(delta)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _handle_movement(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	var new_velocity: Vector3 = current_agent_position.direction_to(next_path_position) * movement_speed
	velocity = new_velocity
	
	# Make the unit face the movement direction
	if velocity.length_squared() > 0.1:
		look_at(global_position + velocity, Vector3.UP)
		
	move_and_slide()

func _handle_combat(delta):
	if global_position.distance_to(target.global_position) <= attack_range:
		# Attack logic here (deferred to animation timing for Agent 2/7 synergy)
		pass
	else:
		set_movement_target(target.global_position)

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	# Play 'popping' VFX and despawn
	queue_free()
