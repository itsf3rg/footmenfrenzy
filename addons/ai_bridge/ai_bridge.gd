@tool
extends EditorPlugin

var server_node

func _enter_tree():
	server_node = preload("res://addons/ai_bridge/bridge_server.gd").new()
	add_child(server_node)
	print("AI Bridge Plugin Enabled.")

func _exit_tree():
	if server_node:
		server_node.queue_free()
