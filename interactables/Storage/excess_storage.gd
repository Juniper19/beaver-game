extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null

@export var item_separation: Vector2 = Vector2(0.0, -12.0)
var original: Sprite2D

var storage: Array = []
var storage_names: Array = []

@export var chest_id: int = -1

func _ready() -> void:

	# Make sure GlobalStats exists
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)
	
	#connecting this chest to its slot in GlobalStats
	if chest_id >=0:
		if GlobalStats.excess_chest_storages.size() <= chest_id:
			GlobalStats.excess_chest_storages.resize(chest_id+1)
			GlobalStats.excess_chest_storage_names.resize(chest_id+1)
			
		if GlobalStats.excess_chest_storages[chest_id] == null:
			GlobalStats.excess_chest_storages[chest_id] = []
			GlobalStats.excess_chest_storage_names[chest_id] = []
			
		storage = GlobalStats.excess_chest_storages[chest_id]
		storage_names = GlobalStats.excess_chest_storage_names[chest_id]
	
	%InteractLabel.visible = false
	
	GlobalStats.inventory_item_placed.connect(_on_item_placed)
	_update_icon()

func _process(_delta: float) -> void:
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		GlobalStats.ExcessChestEntered = true
		%InteractLabel.visible = true
	#else:
		
			#%InteractLabel.visible = false
			#GlobalStats.ExcessChestEntered = false
		
	if Input.is_action_just_pressed("drop_item") and $InteractionArea.get_overlapping_bodies().size() > 0:
		add_item()
	if Input.is_action_just_pressed("interact") and $InteractionArea.get_overlapping_bodies().size() > 0:
		remove_item()
	
func add_item():
	GlobalStats.emit_signal("ItemInExcessChest", self)


func _on_item_placed(item) -> void:
	if $InteractionArea.get_overlapping_bodies().size() == 0:
		return
	# Only care if this came from the player inventory drop-for-chest logic
	if storage.size() < GlobalStats.StorageLimit:
			if "data" in item and item.data:
				if storage.size() != 0:
					if item.item_name != storage_names[-1]:
						return
				storage.append(item.data)   # store the ItemData resource
				storage_names.append(item.item_name)
				#GlobalStats.storage.append(item.item_name)
				#GlobalStats.storageNames.append(item.item_name)
				#print(GlobalStats.storage)
				_update_icon()

func remove_item() -> void:
	if storage.is_empty():
		return
	var item_data = storage.pop_back()   # last added first out (LIFO)
	#print(GlobalStats.storage)
	storage_names.pop_back()
	#GlobalStats.storage.pop_back()
	#GlobalStats.storageNames.pop_back()
	# Send the ItemData to the inventory
	GlobalStats.emit_signal("ItemFromExcessChest", item_data)

	_update_icon()

func _update_icon() -> void:
	if storage.is_empty():
		%Wood.visible = false
		%Mud.visible = false
		%Stone.visible = false
		%OakSeed.visible = false
		%PineLog.visible = false
		%AspenLog.visible = false
		return
	else:
		if storage_names[-1] == "Oak Log":
			original = %Wood
			#%Mud.visible = false
			#%Stone.visible = false
		if storage_names[-1] == "Oak Seed":
			original = %OakSeed
		if storage_names[-1] == "Mud":
			original = %Mud
			#%Wood.visible = false
			#%Stone.visible = false
		if storage_names[-1] == "Stone":
			original = %Stone
			#%Wood.visible = false
			#%Mud.visible = false
		original.visible = true
		for child in %ItemStack.get_children():
			if child != original:
				child.queue_free()
		for i in range(1, storage_names.size()):
			var copy = original.duplicate()
			copy.position = original.position + (item_separation*i)
			%ItemStack.add_child(copy)
	#var last_data = storage.back()
	#if "texture" in last_data:
	#	%IconSprite.texture = last_data.texture


func _on_interaction_area_player_left_area(player: Player) -> void:
	%InteractLabel.visible = false
	GlobalStats.ExcessChestEntered = false
