class_name DepositZone
extends Area2D

func _physics_process(_delta):
	GlobalStats.WoodHeld = 0
	GlobalStats.PineLogHeld = 0
	GlobalStats.AspenLogHeld = 0
	GlobalStats.MudHeld = 0
	GlobalStats.StoneHeld = 0
	
	var oak: int = 0
	var aspen: int = 0
	var pine: int = 0
	var mud: int = 0
	var stone: int = 0
	
	for node in get_overlapping_areas():
		if node.get_parent() is not Item:
			continue
		
		var item: Item = node.get_parent() as Item
		
		if item.item_name == "Oak Log":
			oak += 1
		elif item.item_name == "Pine Log":
			pine += 1
		elif item.item_name == "Aspen Log":
			aspen += 1
		elif item.item_name == "Mud":
			mud += 1
		elif item.item_name == "Stone":
			stone += 1
	
	GlobalStats.wood = oak
	GlobalStats.pine_log = pine
	GlobalStats.aspen_log = aspen
	GlobalStats.mud = mud
	GlobalStats.stone = stone
