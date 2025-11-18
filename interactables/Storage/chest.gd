extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")
#const InventoryScript = preload("res://player/inventory/player_inventory.gd")

var global_stats: Node = null
var WoodHeld = 0
#var Inventory: Node = null


func _ready() -> void:
	
	# Make sure GlobalStats exists
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)
	
	#Make sure inventory exists
	#if get_tree().get_root().has_node("INVENTORY"):
	#	Inventory = get_tree().get_root().get_node("INVENTORY")
	#else:
	#	Inventory = InventoryScript.new()
	#	Inventory.name = "INVENTORY"
	#	get_tree().get_root().add_child(Inventory)

	GlobalStats.inventory_item_added.connect(_on_item_added)
	GlobalStats.inventory_item_removed.connect(_on_item_removed)
	
	%InteractLabel.visible = false
	
	
	
func _process(_delta: float) -> void:
	#print(Inventory.inventory_items.size)
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		
	if Input.is_action_just_pressed("ui_accept") and $InteractionArea.get_overlapping_bodies().size() > 0:
		add_item()
	
	var inventory = get_tree().get_root().find_child("player_inventory", true, false)
	#print(inventory)
	if inventory:
		inventory.item_added.connect(_on_item_added)
	
		
func _on_item_added(item):
	if item.item_name == "Default Item":
		WoodHeld += 1
		print(WoodHeld)
		

func _on_item_removed(item):
	if item.item_name == "Default Item":
		WoodHeld -= 1
		print(WoodHeld)

	
func add_item():
	print(WoodHeld)
	#print(Inventory.ItemCount)
	if WoodHeld > 0:
		WoodHeld -= 1
		GlobalStats.wood += 1
		GlobalStats.emit_signal("ItemInChest")
