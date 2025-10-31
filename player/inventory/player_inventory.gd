class_name PlayerInventory
extends Marker2D

@export var inventory_items: Array[Node2D] = []
@export var item_separation: float = 25.0


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
	drop_item(inventory_items.size() - 1)

func drop_item(index: int):
	if index >= inventory_items.size() or index < 0:
		push_warning("Tried to drop inventory item out of bounds!")
		return
		
	var item: Node2D = inventory_items.pop_at(index)
	var item_pos: Vector2 = item.global_position
	item.reparent(get_tree().root) ## CHANGE THIS?
	item.global_position = item_pos
	
	if item is Area2D:
		item.monitorable = true
	
	_reset_item_positions()
	
func _reset_item_positions():
	for i in inventory_items.size():
		var item = inventory_items[i]
		item.position.x = 0.0
		item.position.y = i * -item_separation
