extends Node2D
const GlobalStatsScript = preload("res://global/global_stats.gd")
const WorldScript = preload("res://Day and night/day_night_manager.gd")
var global_stats: Node = null
var world: Node = null
var failed_quota: bool = false


@onready var left_rows := [
	%HBoxLeft1,
	%HBoxLeft2,
	%HBoxLeft3,
]

@onready var right_rows := [
	%HBoxRight1,
	%HBoxRight2,
	%HBoxRight3,
]

@export var oak_icon: Texture2D
@export var pine_icon: Texture2D
@export var aspen_icon: Texture2D
@export var mud_icon: Texture2D
@export var stone_icon: Texture2D


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
	%InteractLabel.visible = false
	
	GlobalStats.QuotaCheck.connect(onQuotaCheck)
	#var TexRect = %CheckIMG
	var max_size = Vector2(70,70)
	#TexRect.custom_minimum_size = TexRect.get_size().clamp(Vector2.ZERO, max_size)
	

func _process(_delta: float) -> void:
	#If player failed to meet the quota the day before
	#if GlobalStats.day_number != Day:
		#if GlobalStats.DayOne == false:
			#if(
				#GlobalStats.wood < GlobalStats.ReqWood or
				#GlobalStats.pine_log < GlobalStats.ReqPineLog or
				#GlobalStats.aspen_log < GlobalStats.ReqAspenLog or
				#GlobalStats.mud < GlobalStats.ReqMud or
				#GlobalStats.stone < GlobalStats.ReqStone
				#
			#):
				#failed_quota = true
		#
		#if failed_quota:
			#if GlobalStats.free_quota_miss > 0:
				## Consume the free pass
				#GlobalStats.free_quota_miss -= 1
				#print("Quota missed... but Dam Insurance has been used!")
				#
				#%TextTimer.start()
				#%QuotaLabel.visible = true
				#%QuotaLabel.text = "Quota missed... but Dam Insurance saved you!"
			#else:
				## No free pass → THIS IS A REAL FAIL
				#print("Failed to Hit Quota (no free pass)")
				#
				#%TextTimer.start()
				#%QuotaLabel.visible = true
				#%QuotaLabel.text = "You failed to hit the quota yesterday..."
				## TODO trigger gmae over

	#Increasing Quota Requirements as days progress
	if GlobalStats.day_number != Day:
		#Resetting quota values
		GlobalStats.wood = clamp(GlobalStats.wood - GlobalStats.ReqWood, 0, GlobalStats.wood)
		GlobalStats.pine_log = clamp(GlobalStats.pine_log - GlobalStats.ReqPineLog, 0, GlobalStats.pine_log)
		GlobalStats.aspen_log = clamp(GlobalStats.aspen_log - GlobalStats.ReqAspenLog, 0, GlobalStats.aspen_log)
		GlobalStats.mud = clamp(GlobalStats.mud - GlobalStats.ReqMud, 0, GlobalStats.mud)
		GlobalStats.stone = clamp(GlobalStats.stone - GlobalStats.ReqStone, 0, GlobalStats.stone)

		#CHANGE THESE 3 VALUES BELOW FOR BALANCING
		GlobalStats.ReqWood += int(randf_range(1,5))
		GlobalStats.ReqPineLog += int(randf_range(1,5))
		GlobalStats.ReqAspenLog += int(randf_range(1,5))
		GlobalStats.ReqMud += int(randf_range(1,3))
		GlobalStats.ReqStone += int(randf_range(1,2))
		
		Day = GlobalStats.day_number
		
	update_resource_display()
	
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		
	if Input.is_action_just_pressed("ui_accept") and $InteractionArea.get_overlapping_bodies().size() > 0:
		show_quota()
	elif Input.is_action_just_pressed("ui_cancel") or $InteractionArea.get_overlapping_bodies().size() == 0:
		hide_quota()	
		
	#if current_time >= cutoff_time and current_time < 8 * 60 and not has_triggered_2am:
func onQuotaCheck():
	if GlobalStats.DayOne:
		return
	
	var missed := (
		GlobalStats.wood < GlobalStats.ReqWood or
		GlobalStats.pine_log < GlobalStats.ReqPineLog or
		GlobalStats.aspen_log < GlobalStats.ReqAspenLog or
		GlobalStats.mud < GlobalStats.ReqMud or
		GlobalStats.stone < GlobalStats.ReqStone
	)

	if not missed:
		return  # Quota passed, nothing to do

	# Check dam insurance
	if GlobalStats.free_quota_miss > 0:
		GlobalStats.free_quota_miss -= 1
		print("Quota missed... but Dam Insurance has been used!")

		%TextTimer.start()
		%QuotaLabel.visible = true
		%QuotaLabel.text = "Quota missed... but Dam Insurance saved you!"

		return 

	print("Failed quota with no insurance. Game Over.")
	GlobalStats.GameOver.emit()

func show_quota():
	#Testing Purposes *DELETE WHEN WE MERGE*
	#GlobalStats.wood +=10
	#GlobalStats.mud +=3
	#GlobalStats.stone +=1
	
	#%Label1.text = "Wood: " + str(GlobalStats.wood) + " / " + str(GlobalStats.ReqWood)
	#%Label2.text = "Mud: " + str(GlobalStats.mud) + " / " + str(GlobalStats.ReqMud)
	#%Label3.text = "Stone: " + str(GlobalStats.stone) + " / " + str(GlobalStats.ReqStone)
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
	
func update_resource_display() -> void:
	var items: Array = []

	# Show only if there is a requirement for that resource
	if GlobalStats.ReqWood > 0:
		items.append({
			"name": "Oak",
			"current": GlobalStats.wood,
			"required": GlobalStats.ReqWood,
			"icon": oak_icon,
		})

	if GlobalStats.ReqPineLog > 0:
		items.append({
			"name": "Pine",
			"current": GlobalStats.pine_log,
			"required": GlobalStats.ReqPineLog,
			"icon": pine_icon,
		})

	if GlobalStats.ReqAspenLog > 0:
		items.append({
			"name": "Aspen",
			"current": GlobalStats.aspen_log,
			"required": GlobalStats.ReqAspenLog,
			"icon": aspen_icon,
		})

	if GlobalStats.ReqMud > 0:
		items.append({
			"name": "Mud",
			"current": GlobalStats.mud,
			"required": GlobalStats.ReqMud,
			"icon": mud_icon,
		})

	if GlobalStats.ReqStone > 0:
		items.append({
			"name": "Stone",
			"current": GlobalStats.stone,
			"required": GlobalStats.ReqStone,
			"icon": stone_icon,
		})

	_fill_columns(items)


func _fill_columns(items: Array) -> void:
	# First hide all slots
	for row in left_rows:
		row.visible = false
	for row in right_rows:
		row.visible = false
		
	var total_slots := left_rows.size() + right_rows.size()

	# Now place items: index 0–2 → left column, 3–5 → right column
	for i in range(items.size()):
		if i >= total_slots:
			break  # safety, only *have* 6 slots

		var row_node: Control

		if i < left_rows.size():
			row_node = left_rows[i]
		else:
			row_node = right_rows[i -  left_rows.size()]

		# Get the Label inside the row (adjust path if needed)
		var label: Label = row_node.get_node("Label")
		var icon_rect: TextureRect = row_node.get_node("TextureRect")
		var item = items[i]

		# Example label text: "Oak: 5"
		#label.text = "%s: %d/%d" % [item["name"], item["current"], item["required"]]
		label.text = "%d/%d" % [item["current"], item["required"]]

		icon_rect.texture = item["icon"]
		icon_rect.visible = item["icon"] != null

		row_node.visible = true
