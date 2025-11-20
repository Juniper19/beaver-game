extends Node2D
#@export var target_scene:String, FILE, ".tscn,*.scn"
@export var target_scene: SceneManager.Scene

func _process(delta: float) -> void:
	var scene = get_tree().current_scene
	if scene.is_in_group("dam"):
		if $InteractionArea.get_overlapping_bodies().size() > 0:
			%GoOutsideLabel.visible = true
		else:
			%GoOutsideLabel.visible = false
	elif scene.is_in_group("world"):
		if $InteractionArea.get_overlapping_bodies().size() > 0:
			%SleepLabel.visible = true
		else:
			%SleepLabel.visible = false


func next_level():
	SceneManager.load_scene(target_scene)


func _on_interaction(by):
	if by is Player:
		SceneManager.load_scene(target_scene)
