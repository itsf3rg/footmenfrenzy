extends CharacterBody3D
class_name FootmanUnit

enum State {
	IDLE,
	MOVING,
	ATTACKING,
	DEAD
}

@export var movement_speed: float = 5.0
@export var attack_range: float = 2.0
@export var damage: float = 10.0
@export var max_health: float = 100.0
@export var attack_speed: float = 1.0 # Attacks per second
@export var faction_id: int = 0  # 0: Fire, 1: Water, 2: Light, 3: Poison

@onready var navigation_agent = $NavigationAgent3D

var current_health: float
var current_state: State = State.IDLE
var target_unit: FootmanUnit = null
var attack_cooldown_timer: float = 0.0

func _ready():
	current_health = max_health
	current_state = State.MOVING
	# Start moving towards the center of the map immediately
	set_movement_target(Vector3.ZERO)

func _physics_process(delta):
	if current_state == State.DEAD:
		return
		
	_acquire_target()
	
	match current_state:
		State.MOVING:
			_handle_movement(delta)
		State.ATTACKING:
			_handle_combat(delta)

func _acquire_target():
	# If we already have a valid target in range, keep it.
	if target_unit and is_instance_valid(target_unit) and target_unit.current_state != State.DEAD:
		if global_position.distance_to(target_unit.global_position) <= attack_range:
			current_state = State.ATTACKING
			return
		else:
			# Target moved out of range, move to chase
			current_state = State.MOVING
			set_movement_target(target_unit.global_position)
			return
			
	# Placeholder: In a real implementation, we'd use an Area3D or a spatial hash to find nearest enemy
	# For now, if no target, keep moving to center.
	target_unit = null
	current_state = State.MOVING
	set_movement_target(Vector3.ZERO)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _handle_movement(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	var new_velocity: Vector3 = current_agent_position.direction_to(next_path_position) * movement_speed
	velocity = new_velocity
	
	if velocity.length_squared() > 0.1:
		look_at(global_position + velocity, Vector3.UP)
		
	move_and_slide()

func _handle_combat(delta):
	# Stop moving when attacking
	velocity = Vector3.ZERO
	move_and_slide()
	
	if target_unit and is_instance_valid(target_unit):
		look_at(target_unit.global_position, Vector3.UP)
		
	attack_cooldown_timer -= delta
	if attack_cooldown_timer <= 0.0:
		_execute_attack()
		# Reset cooldown based on attack speed (e.g. 1.0 / 2.0 = 0.5 seconds between attacks)
		attack_cooldown_timer = 1.0 / attack_speed

func _execute_attack():
	if target_unit and is_instance_valid(target_unit):
		# Deterministic damage application. 
		# In future, sync this exactly to the animation hit frame (Agent 7's job)
		target_unit.take_damage(damage)

func take_damage(amount: float):
	if current_state == State.DEAD:
		return
		
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	current_state = State.DEAD
	# Disable collisions immediately so alive units walk through the corpse
	if $CollisionShape3D:
		$CollisionShape3D.disabled = true
	# Play 'popping' VFX and despawn (Placeholder for now)
	queue_free()
