extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null

var Inside: bool

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
	GlobalStats.Add_to_Quota.connect(_on_Add_to_Quota)
	
	%InteractLabel.visible = false
	
	
	
func _process(_delta: float) -> void:
	#print($InteractionArea.get_overlapping_areas().size())
	#if $InteractionArea.get_overlapping_areas().size() > 0:
		#%InteractLabel.visible = true
		#GlobalStats.QuotaChestEntered = true
	#else:
		#%InteractLabel.visible = false
		#GlobalStats.QuotaChestEntered = false
		
	if Input.is_action_just_pressed("drop_item") and Inside == true:
		print("Yes")
		GlobalStats.ItemInChest.emit()
		#GlobalStats.emit_signal("ItemInChest", item_data)
		#add_item(item)
	
	
		
func _on_item_added(item):
	if item.item_name == "Oak Log":
		GlobalStats.WoodHeld += 1
	if item.item_name == "Pine Log":
		GlobalStats.PineLogHeld += 1
	if item.item_name == "Aspen Log":
		GlobalStats.AspenLogHeld += 1
	if item.item_name == "Mud":
		GlobalStats.MudHeld += 1
	if item.item_name == "Stone":
		GlobalStats.StoneHeld += 1
		
func _on_item_removed(item):
	
	if item.item_name == "Oak Log":
		GlobalStats.WoodHeld -= 1
	if item.item_name == "Pine Log":
		GlobalStats.PineLogHeld -= 1
	if item.item_name == "Aspen Log":
		GlobalStats.AspenLogHeld -= 1
	if item.item_name == "Mud":
		GlobalStats.MudHeld -= 1
	if item.item_name == "Stone":
		GlobalStats.StoneHeld -= 1
	
func _on_Add_to_Quota(item):
	if item.item_name == "Oak Log":
		if GlobalStats.wood < GlobalStats.ReqWood:
			if GlobalStats.WoodHeld > 0:
				GlobalStats.WoodHeld -= 1
				GlobalStats.wood += 1
				#GlobalStats.emit_signal("ItemInChest")
	if item.item_name == "Pine Log":
		if GlobalStats.pine_log < GlobalStats.ReqPineLog:
			if GlobalStats.PineLogHeld > 0:
				GlobalStats.PineLogHeld -= 1
				GlobalStats.pine_log += 1
				#GlobalStats.emit_signal("ItemInChest")
	if item.item_name == "Aspen Log":
		if GlobalStats.aspen_log < GlobalStats.ReqAspenLog:
			if GlobalStats.AspenLogHeld > 0:
				GlobalStats.AspenLogHeld -= 1
				GlobalStats.aspen_log += 1
				#GlobalStats.emit_signal("ItemInChest")
	elif item.item_name == "Mud":
		if GlobalStats.mud < GlobalStats.ReqMud:
			if GlobalStats.MudHeld > 0:
				GlobalStats.MudHeld -= 1
				GlobalStats.mud += 1
				#GlobalStats.emit_signal("ItemInChest")
	elif item.item_name == "Stone":
		if GlobalStats.stone < GlobalStats.ReqStone:
			if GlobalStats.StoneHeld > 0:
				GlobalStats.StoneHeld -= 1
				GlobalStats.stone += 1
				#GlobalStats.emit_signal("ItemInChest")
	


func _on_interaction_area_player_entered_area(player: Player) -> void:
	%InteractLabel.visible = true
	GlobalStats.QuotaChestEntered = true
	Inside = true

func _on_interaction_area_player_left_area(player: Player) -> void:
	%InteractLabel.visible = false
	GlobalStats.QuotaChestEntered = false
	Inside = false
