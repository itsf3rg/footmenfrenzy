extends AnimationTree
class_name UnitAnimator

# Agent 7: Rigger & Animator
# Handles the AnimationTree state machine for all characters (Footmen and Heroes)

@export var animation_player: AnimationPlayer
@onready var state_machine: AnimationNodeStateMachinePlayback = get("parameters/playback")

var current_state_name: String = "idle"

func _ready():
	if animation_player:
		# Ensure the tree is active
		active = true

func play_idle():
	if current_state_name != "idle":
		current_state_name = "idle"
		state_machine.travel("Idle")

func play_run():
	if current_state_name != "run":
		current_state_name = "run"
		state_machine.travel("Run")

func play_attack():
	# Allow re-triggering attack
	current_state_name = "attack"
	state_machine.travel("Attack")

func play_death():
	current_state_name = "death"
	state_machine.travel("Death")

# Called by the footman_unit.gd or hero_unit.gd script to sync animations with logic state
func sync_with_movement_velocity(velocity: Vector3):
	if current_state_name in ["death", "attack"]:
		return # Prioritize distinct actions
		
	if velocity.length_squared() > 0.1:
		play_run()
	else:
		play_idle()
