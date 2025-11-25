extends Node2D
const GlobalStatsScript = preload("res://global/global_stats.gd")
const WorldScript = preload("res://Day and night/day_night_manager.gd")
var global_stats: Node = null
var world: Node = null

@onready var vbox: VBoxContainer = $InteractionArea/BoardUI/PanelContainer/VBoxContainer
#CHANGE THESE 3 VALUES BELOW FOR BALANCING

var Day = GlobalStats.day_number


func _ready() -> void:
	# Make sure GlobalStats exists
	
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)
	
	if get_tree().get_root().has_node("World"):
		world = get_tree().get_root().get_node("World")
	else:
		world = WorldScript.new()
		world.name = "World"
		get_tree().get_root().add_child(world)

	
	%BoardUI.visible = false
	%Label1.visible = false
	%Label2.visible = false
	%Label3.visible = false
	%CheckIMG.visible = false
	%InteractLabel.visible = false
	
	var TexRect = %CheckIMG
	var max_size = Vector2(70,70)
	TexRect.custom_minimum_size = TexRect.get_size().clamp(Vector2.ZERO, max_size)
	

func _process(_delta: float) -> void:
	#print(world.current_time)
	#print(Day)
	#print(GlobalStats.day_number)
	%PhysLabel1.text = "Wood " + str(GlobalStats.wood) + "/" + str(GlobalStats.ReqWood)
	%PhysLabel2.text = "Mud " + str(GlobalStats.mud) + "/" + str(GlobalStats.ReqMud)
	%PhysLabel3.text = "Stone " + str(GlobalStats.stone) + "/" + str(GlobalStats.ReqStone)
	#If player failed to meet the quota the day before
	if GlobalStats.day_number != Day:
		var failed_quota := (
			GlobalStats.wood < GlobalStats.ReqWood or
			GlobalStats.mud < GlobalStats.ReqMud or
			GlobalStats.stone < GlobalStats.ReqStone
		)

		if failed_quota:
			if GlobalStats.free_quota_miss > 0:
				# Consume the free pass
				GlobalStats.free_quota_miss -= 1
				print("Quota missed... but Dam Insurance has been used!")
				
				%TextTimer.start()
				%QuotaLabel.visible = true
				%QuotaLabel.text = "Quota missed... but Dam Insurance saved you!"
			else:
				# No free pass → THIS IS A REAL FAIL
				print("Failed to Hit Quota (no free pass)")
				
				%TextTimer.start()
				%QuotaLabel.visible = true
				%QuotaLabel.text = "You failed to hit the quota yesterday..."
				# TODO trigger gmae over

	#Increasing Quota Requirements as days progress
	if GlobalStats.day_number != Day:
		GlobalStats.wood = clamp(GlobalStats.wood - GlobalStats.ReqWood, 0, GlobalStats.wood)
		GlobalStats.mud = clamp(GlobalStats.mud - GlobalStats.ReqMud, 0, GlobalStats.mud)
		GlobalStats.stone = clamp(GlobalStats.stone - GlobalStats.ReqStone, 0, GlobalStats.stone)

		#CHANGE THESE 3 VALUES BELOW FOR BALANCING
		GlobalStats.ReqWood += int(randf_range(1,5))
		GlobalStats.ReqMud += int(randf_range(1,3))
		GlobalStats.ReqStone += int(randf_range(1,2))
		if GlobalStats.ReqWood > 0:
			%Label1.visible = true
			%PhysLabel1.visible = true
		if GlobalStats.ReqMud > 0:
			%Label2.visible = true
			%PhysLabel2.visible = true
		if GlobalStats.ReqStone > 0:
			%Label3.visible = true
			%PhysLabel3.visible = true
		Day = GlobalStats.day_number
	
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		
	if Input.is_action_just_pressed("ui_accept") and $InteractionArea.get_overlapping_bodies().size() > 0:
		show_quota()
	elif Input.is_action_just_pressed("ui_cancel") or $InteractionArea.get_overlapping_bodies().size() == 0:
		hide_quota()	
		
	#if current_time >= cutoff_time and current_time < 8 * 60 and not has_triggered_2am:

		
func show_quota():
	#Testing Purposes *DELETE WHEN WE MERGE*
	#GlobalStats.wood +=10
	#GlobalStats.mud +=3
	#GlobalStats.stone +=1
	
	%Label1.text = "Wood: " + str(GlobalStats.wood) + " / " + str(GlobalStats.ReqWood)
	%Label2.text = "Mud: " + str(GlobalStats.mud) + " / " + str(GlobalStats.ReqMud)
	%Label3.text = "Stone: " + str(GlobalStats.stone) + " / " + str(GlobalStats.ReqStone)
	#Player Reaches Daily Quota
	if GlobalStats.wood >= GlobalStats.ReqWood and GlobalStats.mud >= GlobalStats.ReqMud and GlobalStats.stone >= GlobalStats.ReqStone:
		%CheckIMG.visible = true
		%TextTimer.start()
		%QuotaLabel.visible = true
		%QuotaLabel.text = "You hit the quota!"

	%BoardUI.visible = true
	
func hide_quota():
	%BoardUI.visible = false


func _on_text_timer_timeout() -> void:
	%QuotaLabel.visible = false
