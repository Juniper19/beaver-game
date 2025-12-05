class_name TutorialPopup
extends Node2D

var tween: Tween

func _show_tutorial(animation: String):
	if tween:
		tween.kill()
	$Controls.play(animation)

func _hide_tutorial():
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	#tween.tween_property(self, "modulate:x")
