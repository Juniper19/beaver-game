class_name Door
extends Node2D
#@export var target_scene:String, FILE, ".tscn,*.scn"
@export var target_scene: SceneManager.Scene


func next_level():
	SceneManager.load_scene(target_scene, SceneManager.Transition.CIRCLE)


func _on_interaction(by):
	if by is Player:
		SceneManager.load_scene(target_scene, SceneManager.Transition.CIRCLE)


func _on_interaction_area_player_entered_area(_player):
	var scene = get_tree().current_scene
	if scene.is_in_group("dam"):
		%GoOutsideLabel.visible = true
	elif scene.is_in_group("world"):
		%SleepLabel.visible = true


func _on_interaction_area_player_left_area(_player):
	%GoOutsideLabel.visible = false
	%SleepLabel.visible = false
