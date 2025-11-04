extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var timer_label: Label = $UI/TimerLabel

func _ready() -> void:
	DayNightManager.refresh_scene_links(canvas_modulate, timer_label)
