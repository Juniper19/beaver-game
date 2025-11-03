extends Area2D
#@export var target_scene:String, FILE, ".tscn,*.scn"
@export_file("*.tscn", ".scn") var target_scene: String

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if !target_scene: #is null
			print("no scene in this door")
			return
		if get_overlapping_bodies().size() > 0:
			next_level()
	
func next_level():
	var packed_scene = load(target_scene)
	var ERR = get_tree().change_scene_to_packed(packed_scene)
	print(target_scene)
	if ERR != OK:
		print("something failed in the door scene")
