extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")

var global_stats: Node = null
var WoodHeld = 0
var MudHeld = 0
var StoneHeld = 0

func _ready() -> void:

	# Make sure GlobalStats exists
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)
	
	GlobalStats.inventory_item_added.connect(_on_item_added)
	GlobalStats.inventory_item_removed.connect(_on_item_removed)
	
	%InteractLabel.visible = false
	
	
	
func _process(_delta: float) -> void:
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		
	if Input.is_action_just_pressed("ui_accept") and $InteractionArea.get_overlapping_bodies().size() > 0:
		add_item()
	
	var inventory = get_tree().get_root().find_child("player_inventory", true, false)
	if inventory:
		inventory.item_added.connect(_on_item_added)
	
		
func _on_item_added(item):
	if item.item_name == "Default Item":
		WoodHeld += 1
	if item.item_name == "Mud":
		MudHeld += 1
	if item.item_name == "Stone":
		StoneHeld += 1
		
func _on_item_removed(item):
	if item.item_name == "Default Item":
		WoodHeld -= 1
	if item.item_name == "Mud":
		MudHeld -= 1
	if item.item_name == "Stone":
		StoneHeld -= 1
	
func add_item():
	print(WoodHeld)
	if GlobalStats.wood < GlobalStats.ReqWood:
		if WoodHeld > 0:
			WoodHeld -= 1
			GlobalStats.wood += 1
			GlobalStats.emit_signal("ItemInChest")
