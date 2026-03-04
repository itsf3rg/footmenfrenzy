@tool
extends Node

var server := TCPServer.new()
var peers := []
var port := 8081

func _ready():
	var err = server.listen(port)
	if err == OK:
		print("AI Bridge listening on port ", port)
	else:
		push_error("AI Bridge failed to start: ", err)

func _process(_delta):
	if server.is_connection_available():
		var peer = server.take_connection()
		peers.append(peer)
		
	for i in range(peers.size() - 1, -1, -1):
		var peer: StreamPeerTCP = peers[i]
		peer.poll()
		if peer.get_status() == StreamPeerTCP.STATUS_NONE or peer.get_status() == StreamPeerTCP.STATUS_ERROR:
			peers.remove_at(i)
			continue
			
		var bytes = peer.get_available_bytes()
		if bytes > 0:
			var data = peer.get_utf8_string(bytes)
			_handle_command(data, peer)

func _handle_command(data: String, peer: StreamPeerTCP):
	var json = JSON.new()
	var error = json.parse(data.strip_edges())
	if error == OK:
		var command = json.data
		var response = _execute_command(command)
		peer.put_utf8_string(JSON.stringify(response) + "\n")
		peer.disconnect_from_host() # Disconnect to signal end of stream for python script
	else:
		peer.put_utf8_string(JSON.stringify({"status": "error", "message": "Invalid JSON"}) + "\n")
		peer.disconnect_from_host()

func _execute_command(cmd: Dictionary) -> Dictionary:
	var action = cmd.get("action", "")
	
	if action == "ping":
		return {"status": "ok", "message": "pong"}
		
	elif action == "get_scene_tree":
		var root = EditorInterface.get_edited_scene_root()
		if root:
			return {"status": "ok", "tree": _dump_node(root)}
		else:
			return {"status": "error", "message": "No scene opened"}
			
	elif action == "add_node":
		var root = EditorInterface.get_edited_scene_root()
		if not root:
			return {"status": "error", "message": "No scene opened"}
		
		var parent_path = cmd.get("parent", ".")
		var node_type = cmd.get("type", "Node")
		var node_name = cmd.get("name", "NewNode")
		
		var parent = root
		if parent_path != ".":
			parent = root.get_node_or_null(parent_path)
			
		if not parent:
			return {"status": "error", "message": "Parent not found"}
			
		if not ClassDB.class_exists(node_type):
			return {"status": "error", "message": "Invalid node type"}
			
		var new_node = ClassDB.instantiate(node_type)
		new_node.name = node_name
		parent.add_child(new_node)
		new_node.owner = root # Crucial for saving in the editor!
		return {"status": "ok", "message": "Node added successfully"}
		
	elif action == "set_property":
		var root = EditorInterface.get_edited_scene_root()
		var node_path = cmd.get("node", ".")
		var prop_name = cmd.get("property", "")
		var prop_value = cmd.get("value", null)
		
		var node = root if node_path == "." else root.get_node_or_null(node_path)
		if node and prop_name != "":
			node.set(prop_name, prop_value)
			return {"status": "ok", "message": "Property set"}
		return {"status": "error", "message": "Node or property invalid"}

	return {"status": "error", "message": "Unknown action"}

func _dump_node(node: Node) -> Dictionary:
	var root = EditorInterface.get_edited_scene_root()
	var data = {
		"name": node.name,
		"class": node.get_class(),
		"path": str(root.get_path_to(node)) if node != root else ".",
		"children": []
	}
	for child in node.get_children():
		data["children"].append(_dump_node(child))
	return data
