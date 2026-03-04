extends Node

# Autoload script (singleton) for managing high-level network state and connections

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 8910
const MAX_PLAYERS = 12

var players = {} # Dictionary of id -> {name, faction_id}

# The player info for the local instance, populated before starting/joining
var player_info = {"name": "Player", "faction_id": 0}

var is_server: bool = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error:
		print("Failed to host game: ", error)
		return error
		
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	is_server = true
	print("Server started on port ", PORT)

func join_game(address: String):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		print("Failed to join game: ", error)
		return error
		
	multiplayer.multiplayer_peer = peer
	is_server = false
	print("Connecting to ", address)

func _on_player_connected(id):
	# When a player connects, send them our info
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print("Player connected: ", new_player_id)
	
	if is_server:
		# If we're the server, we need to tell everyone else about this new player
		# and tell the new player about everyone else.
		for peer_id in players:
			if peer_id == new_player_id or peer_id == 1:
				continue
			_register_player.rpc_id(peer_id, players[peer_id])

func _on_player_disconnected(id):
	if players.has(id):
		players.erase(id)
		player_disconnected.emit(id)
	print("Player disconnected: ", id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
