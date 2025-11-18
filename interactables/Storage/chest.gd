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
	
	
		
func _on_item_added(item):
	if item.item_name == "Default Item":
		GlobalStats.WoodHeld += 1
	if item.item_name == "Mud":
		GlobalStats.MudHeld += 1
	if item.item_name == "stone":
		GlobalStats.StoneHeld += 1
		
func _on_item_removed(item):
	if item.item_name == "Default Item":
		GlobalStats.WoodHeld -= 1
	if item.item_name == "Mud":
		GlobalStats.MudHeld -= 1
	if item.item_name == "stone":
		GlobalStats.StoneHeld -= 1
	
func add_item():
	#print(GlobalStats.WoodHeld)
	if GlobalStats.wood < GlobalStats.ReqWood:
		if GlobalStats.WoodHeld > 0:
			GlobalStats.WoodHeld -= 1
			GlobalStats.wood += 1
			GlobalStats.emit_signal("ItemInChest")
