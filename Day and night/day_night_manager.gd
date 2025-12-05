extends Node

#-----------AM/PM Clock related stuff----------------
@export var day_color: Color = Color(1, 1, 1)
@export var night_color: Color = Color(0.25, 0.3, 0.45)
@export var evening_start: int = 18 * 60  # 6 PM - when fading should begin

@export var time_speed: float = 60.0
var current_time: float = 8 * 60.0  # Start at 8:00 AM

@export var day_start: int = 6 * 60
@export var night_start: int = 20 * 60

var saved_time_speed: float
var canvas_modulate: CanvasModulate
var clock_label: Label
var time_since_day_start: float = 0.0

@onready var warning_label: Label = $UI/WarningLabel
var has_triggered_2am: bool = false

#----------Day counting-----------
@onready var day_count_label: Label
var has_triggered_new_day = false

func _ready() -> void:
	canvas_modulate = $CanvasModulate
	clock_label = $UI/TimerLabel
	day_count_label = $UI/DayCountLabel
	saved_time_speed = time_speed

	get_tree().connect("current_scene_changed", Callable(self, "_on_scene_changed"))
	_on_scene_changed()

func _process(delta: float) -> void:
	time_since_day_start += delta

	if time_speed == 0:
		return  # Time paused (in dam)

	current_time += time_speed * delta
	current_time = fmod(current_time, 1440)  # Wrap at 24h

	var t := 0.0

	if current_time < evening_start:
		t = 0.0
	elif current_time >= night_start:
		t = 1.0
	else:
		t = float(current_time - evening_start) / float(night_start - evening_start)

	t = clamp(t, 0.0, 1.0)
	var target_color = day_color.lerp(night_color, t)
	canvas_modulate.color = canvas_modulate.color.lerp(target_color, delta * 0.75)


	canvas_modulate.color = canvas_modulate.color.lerp(target_color, delta * 1.5)
	clock_label.text = _format_time(current_time)
	
	# counting up days
	var new_day_time = 6 * 60
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
		
	# pass out at 2am
	var cutoff_time := 2 * 60  # 2 AM
	var wake_time := _get_wake_time()

	# Pass out only between 2 AM and your actual wake time
	if current_time >= cutoff_time and current_time < wake_time and not has_triggered_2am:
		_on_pass_out_time()
		has_triggered_2am = true

	# Reset flag after wake time
	if current_time >= wake_time:
		has_triggered_2am = false

func _on_new_day():
	var stats = get_node("/root/GlobalStats")
	time_since_day_start = 0.0

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
	var stats = get_node("/root/GlobalStats")

	# Base start: 8:00 AM
	var start_minutes: int = (8 * 60) - stats.early_bird_minutes

	# Prevent starting before midnight (0 = 12:00 AM)
	start_minutes = max(start_minutes, 0)

	current_time = start_minutes

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
		AudioManager.stopMusic1()

	elif scene.is_in_group("world"):
		# In outdoor world, show and reset new day
		resume_time()
		start_new_day()
		AudioManager.stopInsideMusic()
		AudioManager.playMusic1()
		

	else:
		# Any other scene, default pause and hide UI CAN CHANGE THIS IF WE WANT
		freeze_time()

func _on_pass_out_time():
	# Freeze clock and display msg
	saved_time_speed = time_speed
	time_speed = 0
	warning_label.text = "I'm passing out from exhaustion..."
	warning_label.visible = true

	# Shake clock label
	var original_pos = clock_label.position
	var shake_amount := 2.0
	var shake_times := 14

	for i in range(shake_times):
		clock_label.position = original_pos + Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		await get_tree().process_frame

	clock_label.position = original_pos
	# Fade to black
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", Color(0, 0, 0, 1), 1.2) # 1.2s fade
	await tween.finished

	# Teleport into dam after passing out
	SceneManager.load_scene(SceneManager.Scene.INSIDE_DAM, SceneManager.Transition.CIRCLE)

func _get_wake_time() -> int:
	var stats = get_node("/root/GlobalStats")
	var wake_minutes = (8 * 60) - stats.early_bird_minutes
	return max(wake_minutes, 0)
