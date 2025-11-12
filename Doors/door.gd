extends Area2D
#@export var target_scene:String, FILE, ".tscn,*.scn"
@export_file("*.tscn", ".scn") var target_scene: String

func _process(delta: float) -> void:
	var scene = get_tree().current_scene
	if scene.is_in_group("dam"):
		if get_overlapping_bodies().size() > 0:
			$GoOutsideLabel.visible = true
		else:
			$GoOutsideLabel.visible = false
	elif scene.is_in_group("world"):
		if get_overlapping_bodies().size() > 0:
			$SleepLabel.visible = true
		else:
			$SleepLabel.visible = false
	
func _input(event):
	if event.is_action_pressed("ui_accept"): #if enter key is pressed
		if !target_scene: #is null
			print("no scene in this door")
			return
		if get_overlapping_bodies().size() > 0:
			next_level()
	
func next_level():
	var packed_scene = load(target_scene)
	var ERR = get_tree().change_scene_to_packed(packed_scene)
	if ERR != OK:
		print("something failed in the door scene")
