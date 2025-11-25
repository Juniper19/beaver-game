# SceneManager
extends Node

enum Scene {
	NONE,
	WORLD,
	INSIDE_DAM,
	#MAIN_MENU
}

var _scenes: Dictionary[Scene, String] = {
	Scene.WORLD: "res://world.tscn",
	Scene.INSIDE_DAM: "res://Dam/inside_dam.tscn"
	#Scene.MAIN_MENU: <main menu path>
}



func load_scene(target_scene: Scene) -> void:
	if target_scene == Scene.NONE:
		push_warning("Cannot change scene to NONE!")
		return
		
	var target_path: String = _scenes[target_scene]
	if not ResourceLoader.exists(target_path):
		push_error("Target scene not found: ", target_path)
		return
	
	var current_scene: Node = get_tree().current_scene
	print(current_scene)
	print(Scene.INSIDE_DAM)
	if current_scene.has_method("save"):
		current_scene.call("save")

	var error = get_tree().change_scene_to_file(target_path)
	if error != OK:
		push_error("Error loading scene: ", error)
		return
	current_scene = get_tree().current_scene
	#print(current_scene)
	#if current_scene == Scene.INSIDE_DAM:
		#AudioManager.stopMusic1()
