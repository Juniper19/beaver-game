class_name PlayerInventory
extends Marker2D

signal item_added(item: Node2D)
signal item_removed(item: Node2D)

@export var inventory_items: Array[Node2D] = []
@export var item_separation: Vector2 = Vector2(0.0, -25.0)
@export var random_drop_distance: float = 40.0

var _item_tweens: Dictionary[Node2D, Tween] = {}
var _blacklist: Array[Node2D] = []

var ChestDrop: bool
var Quota: bool
var Excess: bool
var Test: bool
var CancelQFree: bool
var StorageNames = []

func _ready():
	GlobalStats.ItemInChest.connect(_on_item_in_chest)
	#GlobalStats.ItemInExcessChest.connect(_on_item_in_excess_chest)
	GlobalStats.ItemFromExcessChest.connect(_on_item_from_excess_chest)


func _kill_item_tween(item: Node2D):
	if _item_tweens.has(item):
		var tween: Tween = _item_tweens[item]
		if tween.is_running():
			tween.kill()
		_item_tweens.erase(item)

func get_items() -> Array[Node2D]:
	return inventory_items

func _on_item_from_excess_chest(item_data) -> void:
	# item_data is an ItemData resource coming from the chest
	var item_scene: PackedScene = load("res://interactables/items/item.tscn")
	var item: Node2D = item_scene.instantiate()
	
	# The Item script uses `data` in _ready() to set name and texture
	if "data" in item:
		item.data = item_data
	Test = true
	add_item(item)


# Returns if successful
func add_item(item: Node2D) -> bool:
	AudioManager.playItemPickUp()
	if _blacklist.has(item):
		return false
	
	if inventory_items.has(item):
		push_warning("Tried to add inventory item that's already held")
		return false
	
	var item_pos_global: Vector2 = item.global_position
	if item.get_parent() != null:
		item.get_parent().remove_child(item)
	add_child(item)
	item.position = to_local(item_pos_global)
	
	var target_pos: Vector2 = item_separation * inventory_items.size()
	
	#_kill_item_tween(item)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(item, "position", target_pos, 0.2)
	_item_tweens[item] = tween
	

	inventory_items.append(item)
	item_added.emit(item)
	GlobalStats.emit_signal("inventory_item_added", item)
	
	_blacklist.push_back(item)
	tween.finished.connect(func():
		if _blacklist.has(item):
			_blacklist.erase(item)
	)
	
	item.tree_exiting.connect(func():
		if _blacklist.has(item):
			_blacklist.erase(item)
	)
	
	if item is Area2D:
		item.monitorable = false
	
	return true
	

#When deposited into Quota Chest
func _on_item_in_chest():
	ChestDrop = true #Used so a loop isn't created
	Quota = true
	var top = inventory_items.size() - 1
	if top >= 0:
		drop_item(top)

#When deposited into an Excess Chest
func _on_item_in_excess_chest(ExSt):
	#print(ExSt.storage_names)
	StorageNames = ExSt.storage_names
	print(StorageNames)
	
	#Storage is full
	if ExSt.storage.size() >= GlobalStats.StorageLimit:
		return
	
	#Inventory Item doesn't match item type in chest
	var top_index := inventory_items.size() - 1
	if top_index < 0:
		return
		
	var top_item := inventory_items[top_index]
	if StorageNames.size() > 0:
		if top_item.item_name != StorageNames[-1]:
			return
	
	ChestDrop = true #Used so a loop isn't created
	Excess = true
	var top = inventory_items.size() - 1
	if top >= 0:
		drop_item(top)

func drop_top_item():
	var top = inventory_items.size() - 1
	if top >= 0 and ChestDrop == false:
		drop_item(top)

func drop_item(index: int) -> void:
	AudioManager.playDrop()
	if index >= inventory_items.size() or index < 0:
		push_warning("Tried to drop inventory item out of bounds!")
		return

	if _blacklist.has(inventory_items[index]):
		return

	var item: Node2D = inventory_items.pop_at(index)

	var item_pos: Vector2 = item.global_position
	remove_child(item)
	get_tree().current_scene.add_child(item)
	item.global_position = item_pos

	# Tween & random drop
	var TWEEN_TIME: float = 0.3
	var rng = RandomNumberGenerator.new()
	var rand_angle: float = rng.randf_range(0.0, TAU)
	var rand_dir: Vector2 = Vector2(cos(rand_angle), abs(sin(rand_angle)) * 2.0)
	var target_pos: Vector2 = global_position + random_drop_distance * rand_dir

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "global_position:x", target_pos.x, TWEEN_TIME) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(item, "global_position:y", target_pos.y, TWEEN_TIME) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_BACK)

	_blacklist.push_back(item)
	tween.finished.connect(func ():
		if _blacklist.has(item):
			_blacklist.erase(item)
	)

	if item is Area2D:
		item.monitorable = true

	item_removed.emit(item)

	# >>> Chest logic <<<
	# If we're putting this into a chest, tell the chest which item,
	# and then remove it from the world.
	var ItemType = item.item_name
	
	if Excess:
		#if StorageNames.size() > 0:
			#if item.item_name != StorageNames[-1]:
				#CancelQFree = true
		GlobalStats.emit_signal("inventory_item_placed", item)
	if Quota:
		if ItemType == "Oak Seed":
			CancelQFree = true
		if ItemType == "Oak Log":
			if GlobalStats.wood >= GlobalStats.ReqWood:
				CancelQFree = true
		elif ItemType == "Mud":
			if GlobalStats.mud >= GlobalStats.ReqMud:
				CancelQFree = true
		elif ItemType == "Stone":
			if GlobalStats.stone >= GlobalStats.ReqStone:
				CancelQFree = true
		GlobalStats.emit_signal("Add_to_Quota", item)
	if ChestDrop and CancelQFree == false:
		# In chest drops we don't keep the world instance
		item.queue_free()
	else:
		# Normal ground drop
		GlobalStats.emit_signal("inventory_item_removed", item)

	ChestDrop = false
	Quota = false
	Excess = false
	CancelQFree = false





func _reset_item_positions():
	for i in inventory_items.size():
		var item: Node2D = inventory_items[i]
		var target_pos: Vector2 = i * item_separation
		
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(item, "position", target_pos, 0.2)
