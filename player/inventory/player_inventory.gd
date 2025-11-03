class_name PlayerInventory
extends Marker2D

signal item_added(item: Node2D)
signal item_removed(item: Node2D)

@export var inventory_items: Array[Node2D] = []
@export var item_separation: Vector2 = Vector2(0.0, -25.0)
@export var random_drop_distance: float = 40.0

var _item_tweens: Dictionary[Node2D, Tween] = {}
var _blacklist: Array[Node2D] = []


func _kill_item_tween(item: Node2D):
	if _item_tweens.has(item):
		var tween: Tween = _item_tweens[item]
		if tween.is_running():
			tween.kill()
		_item_tweens.erase(item)

func get_items() -> Array[Node2D]:
	return inventory_items

func add_item(item: Node2D):
	if _blacklist.has(item):
		return
	
	if inventory_items.has(item):
		push_warning("Tried to add inventory item that's already held")
		return
	
	var item_pos_global: Vector2 = item.global_position
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


func drop_top_item():
	var top = inventory_items.size() - 1
	if top >= 0:
		drop_item(top)

func drop_item(index: int):
	
	if index >= inventory_items.size() or index < 0:
		push_warning("Tried to drop inventory item out of bounds!")
		return
	
	if _blacklist.has(inventory_items[index]):
		return
	
	var item: Node2D = inventory_items.pop_at(index)
	
	var item_pos: Vector2 = item.global_position
	remove_child(item)
	get_tree().current_scene.add_child(item) ## CHANGE THIS? maybe get_parent().get_parent()?
	item.global_position = item_pos
	
	const TWEEN_TIME: float = 0.3
	var rng := RandomNumberGenerator.new()
	var rand_angle: float = rng.randf_range(0.0, TAU)
	var rand_dir: Vector2 = Vector2(cos(rand_angle), abs(sin(rand_angle)) * 2.0)
	var target_pos = global_position + random_drop_distance * rand_dir
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "global_position:x", target_pos.x, TWEEN_TIME) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_LINEAR)
			
	tween.tween_property(item, "global_position:y", target_pos.y, TWEEN_TIME) \
			.set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_BACK)
			
	_blacklist.push_back(item)
	tween.finished.connect(func():
		if _blacklist.has(item):
			_blacklist.erase(item)
	)

	if item is Area2D:
		item.monitorable = true
	
	item_removed.emit(item)
	
func _reset_item_positions():
	for i in inventory_items.size():
		var item: Node2D = inventory_items[i]
		var target_pos: Vector2 = i * item_separation
		
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(item, "position", target_pos, 0.2)
