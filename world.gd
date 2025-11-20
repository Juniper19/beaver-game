class_name World
extends Node2D

var load_initial_resources: bool = true
const SAVE_PATH = "user://world_save.save"

func _ready():
	if load_initial_resources:
		if FileAccess.file_exists(SAVE_PATH):
			var error: Error = DirAccess.remove_absolute(SAVE_PATH)
			if error != OK:
				push_error("Error deleting save file: ", error)
	else:
		for node in %InitialResources.get_children():
			node.queue_free()


func _on_tree_exiting():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persistent")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		node_data["filename"] = node.get_scene_file_path()
		node_data["parent"] = node.get_parent().get_parent()

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)


func _on_tree_entered():
	pass # Replace with function body.
