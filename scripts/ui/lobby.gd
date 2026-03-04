extends Control

# Lobby Script
# Handles UI input for Hosting or Joining a game and connects to MultiplayerManager.

@onready var ip_input = $VBoxContainer/IPInput
@onready var host_btn = $VBoxContainer/HostButton
@onready var join_btn = $VBoxContainer/JoinButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var start_game_btn = $VBoxContainer/StartGameButton
@onready var players_list = $VBoxContainer/PlayersList

func _ready():
	# Connect to MultiplayerManager signals
	MultiplayerManager.player_connected.connect(_on_player_connected)
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	MultiplayerManager.server_disconnected.connect(_on_server_disconnected)
	
	start_game_btn.hide()

func _on_host_button_pressed():
	var err = MultiplayerManager.host_game()
	if err == OK:
		status_label.text = "Hosting on port " + str(MultiplayerManager.PORT)
		host_btn.disabled = true
		join_btn.disabled = true
		ip_input.editable = false
		start_game_btn.show() # Only host can start
		_update_player_list()
	else:
		status_label.text = "Failed to host."

func _on_join_button_pressed():
	var ip = ip_input.text
	if ip == "":
		ip = "127.0.0.1"
	
	status_label.text = "Connecting..."
	var err = MultiplayerManager.join_game(ip)
	if err == OK:
		host_btn.disabled = true
		join_btn.disabled = true
		ip_input.editable = false
	else:
		status_label.text = "Failed to connect."

func _on_player_connected(id, info):
	status_label.text = "Connected!"
	_update_player_list()

func _on_player_disconnected(id):
	_update_player_list()

func _on_server_disconnected():
	status_label.text = "Server disconnected."
	host_btn.disabled = false
	join_btn.disabled = false
	ip_input.editable = true
	start_game_btn.hide()
	players_list.clear()

func _update_player_list():
	players_list.clear()
	for p_id in MultiplayerManager.players:
		players_list.add_item(MultiplayerManager.players[p_id].name + " (Faction " + str(MultiplayerManager.players[p_id].faction_id) + ")")

func _on_start_game_button_pressed():
	if MultiplayerManager.is_server:
		_start_game.rpc()

@rpc("authority", "call_local")
func _start_game():
	get_tree().change_scene_to_file("res://main.tscn")
