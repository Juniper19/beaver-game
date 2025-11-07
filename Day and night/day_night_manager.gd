extends Node

#-----------AM/PM Clock related stuff----------------
@export var day_color: Color = Color(1, 1, 1)
@export var night_color: Color = Color(0.25, 0.3, 0.45)

@export var time_speed: float = 60.0
var current_time: float = 8 * 60.0  # Start at 8:00 AM

@export var day_start: int = 6 * 60
@export var night_start: int = 20 * 60

var saved_time_speed: float = 60.0
var canvas_modulate: CanvasModulate
var clock_label: Label

@onready var warning_label: Label = $UI/WarningLabel

#----------Day counting-----------
@onready var day_count_label: Label
var has_triggered_new_day = false

func _ready() -> void:
	canvas_modulate = $CanvasModulate
	clock_label = $UI/TimerLabel
	day_count_label = $UI/DayCountLabel

	get_tree().connect("current_scene_changed", Callable(self, "_on_scene_changed"))
	_on_scene_changed()

func _process(delta: float) -> void:
	if time_speed == 0:
		return  # Time paused (in dam)

	current_time += time_speed * delta
	current_time = fmod(current_time, 1440)  # Wrap at 24h

	var is_day = current_time >= day_start and current_time < night_start
	var target_color = day_color if is_day else night_color

	canvas_modulate.color = canvas_modulate.color.lerp(target_color, delta * 1.5)
	clock_label.text = _format_time(current_time)
	
	# counting up days
	var new_day_time = 8 * 60
	if current_time >= new_day_time and not has_triggered_new_day:
		_on_new_day()
		has_triggered_new_day = true
	if current_time < new_day_time:
		has_triggered_new_day = false
	
	var stats = get_node("/root/GlobalStats")
	day_count_label.text = "Day: " + str(stats.day_number)
	
	# ----------- Time Warnings -----------
	var hour = int(current_time / 60) % 24
	if hour >= 22 and hour < 24:
		# 10 PM to Midnight
		warning_label.text = "It's getting late..."
		warning_label.visible = true
	elif hour >= 0 and hour < 2:
		# Midnight to 2 AM
		warning_label.text = "I need to sleep before 2AM..."
		warning_label.visible = true
	else:
		warning_label.visible = false

func _on_new_day():
	var stats = get_node("/root/GlobalStats")
	stats.day_number += 1
	print("Day:", stats.day_number)
	
func _format_time(minutes: float) -> String:
	var hour = int(minutes / 60) % 24
	var minute = int(minutes) % 60
	var ampm = "AM" if hour < 12 else "PM"
	var display_hour = hour % 12
	if display_hour == 0:
		display_hour = 12
	return "%d:%02d %s" % [display_hour, minute, ampm]

func start_new_day() -> void:
	current_time = 8 * 60  # Reset to 8:00 AM

func freeze_time() -> void:
	saved_time_speed = time_speed
	time_speed = 0

func resume_time() -> void:
	time_speed = saved_time_speed

func _on_scene_changed() -> void:
	var scene = get_tree().current_scene
	if not scene:
		return

	if scene.is_in_group("dam"):
		# Inside dam, stop clock + hide UI
		freeze_time()

	elif scene.is_in_group("world"):
		# In outdoor world, show and reset new day
		resume_time()
		start_new_day()

	else:
		# Any other scene, default pause and hide UI CAN CHANGE THIS IF WE WANT
		freeze_time()
