class_name Sapling
extends Node2D

@export var tree_data: TreeData = null
var days_until_grown = -1


func _ready() -> void:
	if !tree_data:
		print_stack()
		push_error("Sapling has no data!")
		
	if days_until_grown < 0:
		days_until_grown = tree_data.days_to_grow
	elif days_until_grown > 0:
		days_until_grown -= 1
		
	_update()


func _update():
	if !tree_data:
		print_stack()
		push_error("Sapling made with no data!")
	
	$Sprite2D.texture = tree_data.texture_sapling
	if days_until_grown <= 0:
		_grow_into_tree.call_deferred()


func _grow_into_tree() -> void:
	var tree_scene: PackedScene = preload("res://interactables/trees/tree.tscn")
	var tree := tree_scene.instantiate()
	tree.global_position = global_position
	tree.data = tree_data
	get_tree().current_scene.add_child(tree)
	queue_free()


func save() -> Dictionary:
	return {
		"position_x": global_position.x,
		"position_y": global_position.y,
		"days_until_grown": days_until_grown,
		"tree_data": tree_data.resource_path,
	}

func load(save_data: Dictionary):
	global_position = Vector2(
		save_data["position_x"],
		save_data["position_y"]
	)
	
	days_until_grown = save_data["days_until_grown"]
	tree_data = ResourceLoader.load(save_data["tree_data"])
