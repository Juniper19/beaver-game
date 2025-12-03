class_name PlayerInventory
extends Marker2D

signal item_added(item: Node2D)
signal item_removed(item: Node2D)

@export var inventory_items: Array[Node2D] = []
@export var item_separation: Vector2 = Vector2(0.0, -12.0)
@export var random_drop_distance: float = 16.0

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


func is_full() -> bool:
	return inventory_items.size() >= GlobalStats.carry_capacity

# Returns if successful
func add_item(item: Node2D) -> bool:
	if is_full():
		print("Inventory full! Cannot carry more items.")
		return false

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
	

func cycle_items(down: bool = true):
	if inventory_items.size() <= 1:
		return
	
	if down:
		var item: Item = inventory_items.pop_front()
		inventory_items.push_back(item)
	else:
		var item: Item = inventory_items.pop_back()
		inventory_items.push_front(item)
	_reset_item_positions(0.35)


#When deposited into Quota Chest
func _on_item_in_chest():
	
	
	var top = inventory_items.size() - 1
	if top < 0:
		return
	
	var item := inventory_items[top]
	if item.item_name in ["Oak Seed", "Aspen Seed", "Pine Seed"]:
		return
		
	if item.item_name == "Oak Log":
		if GlobalStats.wood >= GlobalStats.ReqWood:
			return
			
	if item.item_name == "Pine Log":
		if GlobalStats.pine_log >= GlobalStats.ReqPineLog:
			return
		
	if item.item_name == "Aspen Log":
		if GlobalStats.aspen_log >= GlobalStats.ReqAspenLog:
			return
		
	elif item.item_name == "Mud":
		if GlobalStats.mud >= GlobalStats.ReqMud:
			return
		
	elif item.item_name == "Stone":
		if GlobalStats.stone >= GlobalStats.ReqStone:
			return
		
	ChestDrop = true #Used so a loop isn't created
	Quota = true
	
	drop_item(top)


#When deposited into an Excess Chest
func _on_item_in_excess_chest(ExSt):
	#print(ExSt.storage_names)
	StorageNames = ExSt.storage_names
	#print(StorageNames)
	
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
		AudioManager.playDepositE()
		GlobalStats.emit_signal("inventory_item_placed", item)
	if Quota:
		
			
		AudioManager.playDeposit()
		GlobalStats.emit_signal("Add_to_Quota", item)
	if ChestDrop and CancelQFree == false:
		# In chest drops we don't keep the world instance
		item.queue_free()
	else:
		# Normal ground drop
		AudioManager.playDrop()
		GlobalStats.emit_signal("inventory_item_removed", item)

	ChestDrop = false
	Quota = false
	Excess = false
	CancelQFree = false
	
	_set_z_order()


func _reset_item_positions(time: float = 0.2):
	for i in inventory_items.size():
		var item: Node2D = inventory_items[i]
		var target_pos: Vector2 = i * item_separation
		
		_blacklist.push_back(item)
		
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(item, "position", target_pos, time)
		tween.finished.connect(func ():
			if _blacklist.has(item):
				_blacklist.erase(item)
		)
	_set_z_order()


func try_plant_seed(plant_pos_global: Vector2) -> void:
	# Must have at least one item
	if inventory_items.is_empty():
		return

	var top_item: Item = inventory_items[-1]

	# Only seeds are plantable
	if not top_item.item_name.ends_with("Seed"):
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		print("No player found in 'player' group")
		return

	if not _can_plant_at(plant_pos_global):
		print("Cannot plant here - space is blocked!")
		return
		
	var seed_item: Item = inventory_items.pop_back()
	var tree_data_uid = GlobalStats.ITEM_TO_TREE.get(seed_item.data.name)
	if !tree_data_uid:
		push_warning("Tried to plant seed with no tree data!")
		return
	
	
	_plant_sapling(tree_data_uid, plant_pos_global)


	if _blacklist.has(seed_item):
		_blacklist.erase(seed_item)
	if _item_tweens.has(seed_item):
		_item_tweens.erase(seed_item)

	seed_item.queue_free()

	item_removed.emit(seed_item)
	GlobalStats.emit_signal("inventory_item_removed", seed_item)

	_reset_item_positions()


func _set_z_order():
	for i in inventory_items.size():
		inventory_items[i].z_index = i


func _can_plant_at(pos: Vector2) -> bool:
	var space := get_world_2d().direct_space_state

	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)  # adjust for sapling size

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 4
	query.transform = Transform2D(0, pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = space.intersect_shape(query)
	return results.size() == 0


func _plant_sapling(tree_data_uid: String, pos: Vector2,) -> void:
	var sapling_scene := preload("res://interactables/trees/saplings/sapling.tscn")
	var sapling: Sapling = sapling_scene.instantiate()
	sapling.global_position = pos
	sapling.tree_data = ResourceLoader.load(tree_data_uid)
	get_tree().current_scene.add_child(sapling)
