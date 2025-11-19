extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null


func _ready() -> void:

	# Make sure GlobalStats exists
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)
		
	%InteractLabel.visible = false
	
	GlobalStats.inventory_item_placed.connect(_on_item_placed)
	_update_icon()

func _process(_delta: float) -> void:
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		GlobalStats.ExcessChestEntered = true
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		GlobalStats.ExcessChestEntered = false
		
	if Input.is_action_just_pressed("drop_item") and $InteractionArea.get_overlapping_bodies().size() > 0:
		add_item()
	if Input.is_action_just_pressed("interact") and $InteractionArea.get_overlapping_bodies().size() > 0:
		remove_item()
	
func add_item():
	GlobalStats.emit_signal("ItemInExcessChest")


func _on_item_placed(item) -> void:
	# Only care if this came from the player inventory drop-for-chest logic
	if GlobalStats.storage.size() < GlobalStats.StorageLimit:
		if "data" in item and item.data:
			GlobalStats.storage.append(item.data)   # store the ItemData resource
			GlobalStats.storageNames.append(item.item_name)
			#print(GlobalStats.storage)
			_update_icon()

		

func remove_item() -> void:
	if GlobalStats.storage.is_empty():
		return

	var item_data = GlobalStats.storage.pop_back()   # last added first out (LIFO)
	#print(GlobalStats.storage)
	GlobalStats.storageNames.pop_back()

	# Send the ItemData to the inventory
	GlobalStats.emit_signal("ItemFromExcessChest", item_data)

	_update_icon()

func _update_icon() -> void:
	if GlobalStats.storage.is_empty():
		%Wood.visible = false
		%Mud.visible = false
		%Stone.visible = false
		return
	elif GlobalStats.storageNames[-1] == "Default Item":
		%Wood.visible = true
		%Mud.visible = false
		%Stone.visible = false
		return
	elif GlobalStats.storageNames[-1] == "mud":
		%Wood.visible = false
		%Mud.visible = true
		%Stone.visible = false
		return
	elif GlobalStats.storageNames[-1] == "stone":
		%Wood.visible = false
		%Mud.visible = false
		%Stone.visible = true
		return
	#var last_data = storage.back()
	#if "texture" in last_data:
	#	%IconSprite.texture = last_data.texture
