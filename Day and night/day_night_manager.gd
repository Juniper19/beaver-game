extends Node

@export var day_length: float = 10.0
@export var night_length: float = 8.0
@export var day_color: Color = Color(1, 1, 1)
@export var night_color: Color = Color(0.25, 0.3, 0.45)
@export var transition_speed: float = 1.5

var is_day: bool = true
var _initialized: bool = false
var canvas_modulate: CanvasModulate
var day_timer: Timer
var night_timer: Timer
var timer_label: Label
var current_timer: Timer

func _ready() -> void:
	if _initialized:
		return
	_initialized = true

	canvas_modulate = $CanvasModulate
	day_timer = $DayTimer
	night_timer = $NightTimer
	timer_label = $UI/TimerLabel

	day_timer.wait_time = day_length
	night_timer.wait_time = night_length

	day_timer.timeout.connect(_on_day_ended)
	night_timer.timeout.connect(_on_night_ended)

	start_day()

	get_tree().connect("current_scene_changed", Callable(self, "_on_scene_changed"))

func _on_scene_changed() -> void:
	# Ensure the manager stays attached to the root
	if get_parent() != get_tree().get_root():
		get_tree().get_root().add_child(self)
		set_owner(get_tree().get_root())

	var ui_node := $UI
	if ui_node and ui_node.is_inside_tree():
		ui_node.raise()  # valid for Control nodes, works like move_to_front()

func start_day() -> void:
	is_day = true
	canvas_modulate.color = day_color
	current_timer = day_timer
	day_timer.start()

func _on_day_ended() -> void:
	is_day = false
	day_timer.stop()
	current_timer = night_timer
	night_timer.start()

func _on_night_ended() -> void:
	is_day = true
	night_timer.stop()
	current_timer = day_timer
	day_timer.start()

func _process(delta: float) -> void:
	if not canvas_modulate or not current_timer:
		return
	var target_color: Color = day_color if is_day else night_color
	canvas_modulate.color = canvas_modulate.color.lerp(target_color, delta * transition_speed)
	if timer_label and current_timer.time_left > 0.0:
		timer_label.text = ("%s: %.1f" % ["Day" if is_day else "Night", current_timer.time_left]).to_upper()

func freeze_time() -> void:
	if current_timer:
		current_timer.paused = true

func resume_time() -> void:
	if current_timer:
		current_timer.paused = false

# ---------------- ONLY SPAWN ONE, important----------------
static var instance: DayNightManager

func _enter_tree() -> void:
	if instance and instance != self:
		queue_free()
		return
	instance = self
