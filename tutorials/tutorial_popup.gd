class_name TutorialPopup
extends Node2D

var tween: Tween
var current_animation: String = ""

func _ready():
	modulate.a = 0.0

func show_tutorial(animation: String) -> bool:
	if current_animation:
		return false
	
	if tween:
		tween.kill()
	$AnimatedSprite2D.play(animation)
	
	current_animation = animation
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	return true



func hide_tutorial():
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	#tween.finished.connect(func(): current_animation = "")
	current_animation = ""
