extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null
var storage = []

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

func _process(_delta: float) -> void:
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		
	if Input.is_action_just_pressed("drop_item") and $InteractionArea.get_overlapping_bodies().size() > 0:
		a_item()
	if Input.is_action_just_pressed("interact") and $InteractionArea.get_overlapping_bodies().size() > 0:
		remove_item()
	
func a_item():
	GlobalStats.emit_signal("ItemInExcessChest")


func _on_item_placed(item):

	if storage.size() < GlobalStats.StorageLimit:
		storage.append(item.item_name)
		print(storage)
		icon()
		

func remove_item():
	if storage.size() > 0:
		GlobalStats.ItemID = storage.pop_back()
		print(storage)
		GlobalStats.emit_signal("ItemFromExcessChest")
		if storage.size() > 0:
			icon()
		else:
			%Wood.visible = false
			%Mud.visible = false
			%Stone.visible = false
		
func icon():
	if storage[-1] == "Default Item":
		%Wood.visible = true
		%Mud.visible = false
		%Stone.visible = false
	if storage[-1] == "mud":
		%Wood.visible = false
		%Mud.visible = true
		%Stone.visible = false
	if storage[-1] == "stone":
		%Wood.visible = false
		%Mud.visible = false
		%Stone.visible = true
