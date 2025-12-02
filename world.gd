
class_name World
extends Node2D

const SAVE_PATH = "user://world_save.save"



const Columns = 3
const Starting_Pos = Vector2(60,60)
const Cell_Size = Vector2(110,110)


const ExcessStorage = preload("res://interactables/Storage/excess_storage.tscn")
@onready var inventory_ui := get_node("Player/PlayerInventory")

func _ready():
	GlobalStats.ItemInExcessChest.connect(inventory_ui._on_item_in_excess_chest)
	spawn_storage_grid(GlobalStats.ExcessStorageCount)

	if GlobalStats.initialize_world:
		DirAccess.remove_absolute(SAVE_PATH)
		_spawn_resources()
		GlobalStats.initialize_world = false
	$InitialResourceSpawners.queue_free()
	
	if FileAccess.file_exists(SAVE_PATH):
		_load()


func _spawn_resources():
	for node in $InitialResourceSpawners.get_children():
		if node is ResourceArea:
			node.spawn_resources(self)


func spawn_storage_grid(count: int):
	for i in range(count):
		var Storage = ExcessStorage.instantiate()
		
		Storage.chest_id = i
		
		add_child(Storage)

		@warning_ignore("integer_division")
		var row = i / Columns
		var col = i % Columns
		
		Storage.position = Vector2(col *Cell_Size.x + Starting_Pos.x, row *Cell_Size.y + Starting_Pos.y)

func save():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persistent")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			push_warning("persistent node %s is not an instanced!?" % node.name)
			continue

		if !node.has_method("save"):
			push_warning("persistent node %s is missing a save() function!!" % node.name)
			continue

		var node_data = node.call("save")
		node_data["filename"] = node.get_scene_file_path()
		node_data["parent"] = node.get_parent().get_path()

		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)
	save_file.close()
	
	
# Yanked from the docs bar for bar
# https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
func _load():
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("Loading with no file")
	

	var save_nodes = get_tree().get_nodes_in_group("persistent")
	for i in save_nodes:
		i.queue_free()
		
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			push_warning("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object: Node = load(node_data["filename"]).instantiate()
		if not new_object.has_method("load"):
			push_error("Cannot load node without a load function!")
		new_object.load(node_data)
		get_node(node_data["parent"]).add_child(new_object)
