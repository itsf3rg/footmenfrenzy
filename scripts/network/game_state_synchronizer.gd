extends Node

# Responsible for synchronizing core game state (units, positions) from server to clients

const SYNC_RATE = 20.0 # How many times per second to broadcast state
var sync_timer = 0.0

# Dictionary containing all active entities that need syncing.
# Key: node path or unique ID, Value: {pos: Vector3, hp: float, state: int}
var game_state_snapshot = {}

func _process(delta):
	if not MultiplayerManager.is_server:
		return
		
	sync_timer += delta
	if sync_timer >= (1.0 / SYNC_RATE):
		sync_timer = 0.0
		_broadcast_state()

func _broadcast_state():
	# In a real build, we'd recursively gather node paths and values
	# and pack them tightly into a byte array. For the prototype, we use RPC dicts.
	
	# Pack the state here...
	# game_state_snapshot["unit_123"] = { "pos": unit.global_position, ... }
	
	_receive_state.rpc(game_state_snapshot)

@rpc("authority", "unreliable")
func _receive_state(new_state: Dictionary):
	if MultiplayerManager.is_server:
		return
		
	# Apply the snapshot to the local client state based on Network IDs.
	# We intentionally use "unreliable" RPCs for state updates to prevent packet buildup.
	pass
