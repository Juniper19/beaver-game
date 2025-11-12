extends Node2D
const GlobalStatsScript = preload("res://global/global_stats.gd")
const WorldScript = preload("res://Day and night/day_night_manager.gd")
var global_stats: Node = null
var world: Node = null

@onready var vbox: VBoxContainer = $InteractionArea/BoardUI/PanelContainer/VBoxContainer
#CHANGE THESE 3 VALUES BELOW FOR BALANCING
static var ReqWood = int(randf_range(0,3))
static var ReqMud = int(randf_range(-5,0))
static var ReqStone = int(randf_range(-5,0))
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
	print(Day)
	print(GlobalStats.day_number)
	%PhysLabel1.text = "Wood " + str(GlobalStats.wood) + "/" + str(ReqWood)
	%PhysLabel2.text = "Mud " + str(GlobalStats.mud) + "/" + str(ReqMud)
	%PhysLabel3.text = "Stone " + str(GlobalStats.stone) + "/" + str(ReqStone)
	#If player failed to meet the quota the day before
	if GlobalStats.day_number != Day and (GlobalStats.wood < ReqWood or GlobalStats.mud < ReqMud or GlobalStats.stone < ReqStone):
		print("Failed to Hit Quota")
		%TextTimer.start()
		%QuotaLabel.visible = true
		%QuotaLabel.text = "You failed to hit the quota yesterday..."
	#Increasing Quota Requirements as days progress
	if GlobalStats.day_number != Day:
		GlobalStats.wood = clamp(GlobalStats.wood - ReqWood, 0, GlobalStats.wood)
		GlobalStats.mud = clamp(GlobalStats.mud - ReqMud, 0, GlobalStats.mud)
		GlobalStats.stone = clamp(GlobalStats.stone - ReqStone, 0, GlobalStats.stone)

		#CHANGE THESE 3 VALUES BELOW FOR BALANCING
		ReqWood += int(randf_range(1,5))
		ReqMud += int(randf_range(1,3))
		ReqStone += int(randf_range(1,2))
		if ReqWood > 0:
			%Label1.visible = true
			%PhysLabel1.visible = true
		if ReqMud > 0:
			%Label2.visible = true
			%PhysLabel2.visible = true
		if ReqStone > 0:
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
	GlobalStats.wood +=10
	GlobalStats.mud +=3
	GlobalStats.stone +=1
	
	%Label1.text = "Wood: " + str(GlobalStats.wood) + " / " + str(ReqWood)
	%Label2.text = "Mud: " + str(GlobalStats.mud) + " / " + str(ReqMud)
	%Label3.text = "Stone: " + str(GlobalStats.stone) + " / " + str(ReqStone)
	#Player Reaches Daily Quota
	if GlobalStats.wood >= ReqWood and GlobalStats.mud >= ReqMud and GlobalStats.stone >= ReqStone:
		%CheckIMG.visible = true
		%TextTimer.start()
		%QuotaLabel.visible = true
		%QuotaLabel.text = "You hit the quota!"

	%BoardUI.visible = true
	
func hide_quota():
	%BoardUI.visible = false


func _on_text_timer_timeout() -> void:
	%QuotaLabel.visible = false
