extends Control

func open():
	visible = true
	get_tree().paused = true

func close():
	visible = false
	get_tree().paused = false

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		close()
