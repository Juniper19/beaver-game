extends Node

# ---------------- Settings ----------------
@export var day_length: float = 10.0
@export var night_length: float = 8.0
@export var day_color: Color = Color(1, 1, 1)
@export var night_color: Color = Color(0.25, 0.3, 0.45)
@export var transition_speed: float = 1.5

# ---------------- State ----------------
var is_day: bool = true
var canvas_modulate: CanvasModulate
var day_timer: Timer
var night_timer: Timer
var timer_label: Label
var current_timer: Timer

# ---------------- Lifecycle ----------------
func _ready() -> void:
	canvas_modulate = $CanvasModulate
	day_timer = $DayTimer
	night_timer = $NightTimer
	timer_label = $UI/TimerLabel

	day_timer.wait_time = day_length
	night_timer.wait_time = night_length

	day_timer.timeout.connect(_on_day_ended)
	night_timer.timeout.connect(_on_night_ended)

	start_day()

func start_day() -> void:
	is_day = true
	canvas_modulate.color = day_color
	current_timer = day_timer
	print("☀️ Day started!")
	day_timer.start()

func _on_day_ended() -> void:
	print("🌙 Day ended. Night begins!")
	is_day = false
	day_timer.stop()
	current_timer = night_timer
	night_timer.start()

func _on_night_ended() -> void:
	print("☀️ Night ended. Day begins!")
	is_day = true
	night_timer.stop()
	current_timer = day_timer
	day_timer.start()

# ---------------- Update ----------------
func _process(delta: float) -> void:
	# Fade between colors
	var target_color: Color = day_color if is_day else night_color
	canvas_modulate.color = canvas_modulate.color.lerp(target_color, delta * transition_speed)

	# Display countdown
	if current_timer and current_timer.time_left > 0:
		timer_label.text = ("%s: %.1f" % ["Day" if is_day else "Night", current_timer.time_left]).to_upper()
