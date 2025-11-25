extends Node2D

@export var days_to_grow: int = 1
var planted_day: int = 0

func _ready() -> void:
	planted_day = GlobalStats.day_number

func _process(_delta: float) -> void:
	if GlobalStats.day_number >= planted_day + days_to_grow:
		_grow_into_tree()

func _grow_into_tree() -> void:
	var tree_scene: PackedScene = preload("res://interactables/trees/tree.tscn")
	var tree := tree_scene.instantiate()
	tree.global_position = global_position
	get_tree().current_scene.add_child(tree)
	queue_free()


func save() -> Dictionary:
	return {
		"position_x": global_position.x,
		"position_y": global_position.y,
		"is_sapling": true, 
		"planted_day": planted_day,
		"days_to_grow": days_to_grow
	}

func load(save_data: Dictionary):
	global_position = Vector2(
		save_data["position_x"],
		save_data["position_y"]
	)

	planted_day = save_data.get("planted_day", GlobalStats.day_number)
	days_to_grow = save_data.get("days_to_grow", 1)
