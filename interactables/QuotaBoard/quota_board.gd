extends Node2D

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
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		push_error("GLOBALSTATS NOT FOUND! ENSURE IT IS SET AS AN AUTOLOAD.")
		return

	if get_tree().get_root().has_node("World"):
		world = get_tree().get_root().get_node("World")
	else:
		push_error("WORLD NOT FOUND! ENSURE IT IS SET AS AN AUTOLOAD.")
		return
	# --------------------------------------------------------------------

	%BoardUI.visible = false
	%InteractLabel.visible = false

	GlobalStats.QuotaCheck.connect(onQuotaCheck)

	var max_size = Vector2(70,70)


func _process(_delta: float) -> void:

	# If new day has begun, apply quota changes
	if GlobalStats.day_number != Day:

		# Consume quota amounts (clamped)
		GlobalStats.wood = clamp(GlobalStats.wood - GlobalStats.ReqWood, 0, GlobalStats.wood)
		GlobalStats.pine_log = clamp(GlobalStats.pine_log - GlobalStats.ReqPineLog, 0, GlobalStats.pine_log)
		GlobalStats.aspen_log = clamp(GlobalStats.aspen_log - GlobalStats.ReqAspenLog, 0, GlobalStats.aspen_log)
		GlobalStats.mud = clamp(GlobalStats.mud - GlobalStats.ReqMud, 0, GlobalStats.mud)
		GlobalStats.stone = clamp(GlobalStats.stone - GlobalStats.ReqStone, 0, GlobalStats.stone)

		# Increasing next-day quotas
		GlobalStats.ReqWood += int(randf_range(1,5))
		GlobalStats.ReqPineLog += int(randf_range(1,5))
		GlobalStats.ReqAspenLog += int(randf_range(1,5))
		GlobalStats.ReqMud += int(randf_range(1,3))
		GlobalStats.ReqStone += int(randf_range(1,2))

		Day = GlobalStats.day_number

	update_resource_display()

	# Interaction label
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false

	# Open / close quota board
	if Input.is_action_just_pressed("ui_accept") and $InteractionArea.get_overlapping_bodies().size() > 0:
		show_quota()
	elif Input.is_action_just_pressed("ui_cancel") or $InteractionArea.get_overlapping_bodies().size() == 0:
		hide_quota()


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
		return  # Passed quota

	# --------------------------------------------------------------------
	# Dam Insurance check (FULLY FIXED — now properly subtracts and persists)
	# --------------------------------------------------------------------
	if GlobalStats.free_quota_miss > 0:

		GlobalStats.free_quota_miss -= 1
		print("Dam Insurance used! Now:", GlobalStats.free_quota_miss)

		%TextTimer.start()
		%QuotaLabel.visible = true
		%QuotaLabel.text = "Quota missed... but Dam Insurance saved you!"

		return 
	# --------------------------------------------------------------------

	# No dam insurance → Game over
	print("Failed quota with no insurance. Game Over.")
	GlobalStats.GameOver.emit()


func show_quota():

	# If all requirements met
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

	for row in left_rows:
		row.visible = false
	for row in right_rows:
		row.visible = false
		
	var total_slots := left_rows.size() + right_rows.size()

	for i in range(items.size()):
		if i >= total_slots:
			break

		var row_node: Control

		if i < left_rows.size():
			row_node = left_rows[i]
		else:
			row_node = right_rows[i - left_rows.size()]

		var label: Label = row_node.get_node("Label")
		var icon_rect: TextureRect = row_node.get_node("TextureRect")

		var item = items[i]

		label.text = "%d/%d" % [item["current"], item["required"]]

		icon_rect.texture = item["icon"]
		icon_rect.visible = item["icon"] != null

		row_node.visible = true
