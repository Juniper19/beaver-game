class_name MudZone
extends InteractionArea

signal mud_depleted

@export var max_spawnable_mud: int = 5
var _spawned_mud: int = 0

const ITEM = preload("uid://cdbqttwtbxchw")
const MUD_DATA = preload("res://interactables/items/item_resources/mud.tres") 
var rect: RectangleShape2D
var half_size: Vector2

func _ready():
	rect = $CollisionShape2D.shape as RectangleShape2D
	half_size = rect.size / 2.0


func _spawn_mud():
	if _spawned_mud >= max_spawnable_mud:
		return
	
	var rand_point: Vector2 = Vector2(
		randi_range(int(-half_size.x), int(half_size.x)),
		randi_range(int(-half_size.y), int(half_size.y))
	)
	
	rand_point = rand_point.rotated(rotation)
	rand_point += Vector2(global_position.x, global_position.y)
	
	var mud_item: Item = ITEM.instantiate()
	mud_item.data = MUD_DATA
	get_parent().add_child(mud_item)
	mud_item.global_position = rand_point
	
	_spawned_mud += 1
	if _spawned_mud >= max_spawnable_mud:
		$CollisionShape2D.disabled = true
		mud_depleted.emit()


func _on_interaction(by):
	if by is not Player:
		return
	_spawn_mud()
