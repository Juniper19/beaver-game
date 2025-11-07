extends Node

@export var day_color: Color = Color(1, 1, 1)
@export var night_color: Color = Color(0.25, 0.3, 0.45)

@export var time_speed: float = 60.0
var current_time: float = 8 * 60.0  # Start at 8:00 AM

@export var day_start: int = 6 * 60
@export var night_start: int = 20 * 60

var saved_time_speed: float = 60.0
var canvas_modulate: CanvasModulate
var clock_label: Label

func _ready() -> void:
	canvas_modulate = $CanvasModulate
	clock_label = $UI/TimerLabel

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
	$UI.visible = false

func resume_time() -> void:
	time_speed = saved_time_speed
	$UI.visible = true

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
