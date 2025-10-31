class_name PlayerInventory
extends Marker2D

@export var inventory_items: Array[Node2D] = []
@export var item_separation: float = 25.0
@export var random_drop_distance: float = 40.0


func add_item(item: Node2D):
	if inventory_items.has(item):
		push_warning("Tried to add inventory item that's already held")
		return
	
	inventory_items.append(item)
	
	var item_pos_global: Vector2 = item.global_position
	item.reparent(self)
	item.global_position = item_pos_global
	
	var target_pos: Vector2 = Vector2(0.0, (inventory_items.size() - 1) * -item_separation)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(item, "position", target_pos, 0.2)
	
	if item is Area2D:
		item.monitorable = false

func drop_all_items():
	for i in inventory_items.size():
		drop_item(0)

func drop_top_item():
	var top = inventory_items.size() - 1
	if top >= 0:
		drop_item(inventory_items.size() - 1)

func drop_item(index: int):
	if index >= inventory_items.size() or index < 0:
		push_warning("Tried to drop inventory item out of bounds!")
		return
		
	var item: Node2D = inventory_items.pop_at(index)
	var item_pos: Vector2 = item.global_position
	item.reparent(get_tree().root) ## CHANGE THIS?
	item.global_position = item_pos
	
	
	#const TWEEN_TIME: float = 0.3
	#var rng := RandomNumberGenerator.new()
	#var rand_angle: float = rng.randf_range(0.0, TAU)
	#var rand_dir := Vector2(cos(rand_angle), abs(sin(rand_angle)) * 2.0)
	#var target_pos = global_position + random_drop_distance * rand_dir
	#var tween = get_tree().create_tween()
	#tween.set_parallel(true)
	#tween.tween_property(item, "global_position:x", target_pos.x, TWEEN_TIME) \
			#.set_ease(Tween.EASE_IN) \
			#.set_trans(Tween.TRANS_LINEAR)
			#
	#tween.tween_property(item, "global_position:y", target_pos.y, TWEEN_TIME) \
			#.set_ease(Tween.EASE_IN) \
			#.set_trans(Tween.TRANS_BACK)
	
	
	#if item is Area2D:
		#get_tree().create_tween().tween_callback(item.set.bind("monitorable", true)).set_delay(TWEEN_TIME)
	
	if item is Area2D:
		item.monitorable = true
	
	_reset_item_positions()
	
func _reset_item_positions():
	for i in inventory_items.size():
		var item: Node2D = inventory_items[i]
		var target_pos: Vector2 = Vector2(0.0, i * -item_separation)
		
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(item, "position", target_pos, 0.2)
