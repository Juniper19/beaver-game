class_name ChargeQTE
extends Node2D

signal hit(_progress: float)

@export var time_to_max: float = 1.5
@export_range(0.0, 1.0, 0.01) var min_progress: float = 0.1
@export_range(1.0, 100.0, 0.01) var difficulty: float = 3.0
var _on_cooldown: bool = false

@onready var progress_bar = $TextureProgressBar
@onready var timer = $Timer
@onready var cooldown_timer = $CooldownTimer

var progress: float = 0.0
var _bar_texture_width: int

func _ready():
	timer.wait_time = time_to_max
	_bar_texture_width = progress_bar.texture_progress.get_width()


func _calculate_and_set_progress():
	if _on_cooldown:
		return
	
	var unscaled_progress: float = 1 - abs(timer.time_left / timer.wait_time * 2.0 - 1)
	var scaled_progress = pow(unscaled_progress, difficulty)
	progress = scaled_progress * (1.0 - min_progress) + min_progress # so minimum isn't zero


func _process(_delta):
	_calculate_and_set_progress()
	progress_bar.value = progress * float(_bar_texture_width)


func _off_cooldown():
	_on_cooldown = false
	timer.paused = false
	timer.start()
	_calculate_and_set_progress()
	

func attempt_hit():
	if _on_cooldown:
		return
	_on_cooldown = true
	cooldown_timer.start()
	timer.paused = true
	
	_calculate_and_set_progress()
	var adjusted_progress = ceil(progress * _bar_texture_width) / _bar_texture_width
	hit.emit(adjusted_progress)
	
	
	
