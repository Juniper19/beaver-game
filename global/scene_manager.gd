# SceneManager
extends Node

enum Scene {
	NONE,
	WORLD,
	INSIDE_DAM,
	MAIN_MENU,
	GAME_OVER
}

enum Transition {
	NONE,
	CIRCLE,
}

var _scenes: Dictionary[Scene, String] = {
	Scene.WORLD: "res://world.tscn",
	Scene.INSIDE_DAM: "res://Dam/inside_dam.tscn",
	Scene.MAIN_MENU: "res://menu/main_menu.tscn",
	Scene.GAME_OVER: "res://menu/game_over_ui.tscn"
}

@onready var _transitions: Dictionary[Transition, Resource] = {
	Transition.CIRCLE: preload("uid://bc7t6gr8ow85a"),
}

var changing_scenes = false



func load_scene(target_scene: Scene, transition: Transition = Transition.NONE) -> void:
	if changing_scenes:
		return

	if target_scene == Scene.NONE:
		push_warning("Cannot change scene to NONE!")
		return
	
	if target_scene == Scene.INSIDE_DAM and !GlobalStats.is_quota_met():
		print("Quota not met! No inside dam, sending to game over screen")
		target_scene = Scene.GAME_OVER
	
		
	var target_path: String = _scenes[target_scene]
	if not ResourceLoader.exists(target_path):
		push_error("Target scene not found: ", target_path)
		return
	
	changing_scenes = true
	
	var current_scene: Node = get_tree().current_scene
	if current_scene.has_method("save"):
		current_scene.call("save")
	 
	var transition_node: SceneTransition = null
	if transition != Transition.NONE:
		var transition_scene = _transitions[transition]
		transition_node = transition_scene.instantiate()
		get_tree().root.add_child(transition_node)
		
		var to_follow: Node2D = get_tree().get_first_node_in_group("transition_follow")
		transition_node.play(false, to_follow)
		
		await transition_node.finished
	
	if target_scene != Scene.WORLD:
		AudioManager.playEnterDam()
		AudioManager.stopOverworldMusic()
		if target_scene == Scene.INSIDE_DAM:
			if GlobalStats.DayOne == true:
				GlobalStats.DayOne = false

			
	
	var error = get_tree().change_scene_to_file(target_path)
	if error != OK:
		if transition_node:
			transition_node.queue_free()
		push_error("Error loading scene: ", error)
		changing_scenes = false
		return
	
	
	current_scene = get_tree().current_scene
	
	if transition_node:
		await get_tree().scene_changed
		var to_follow: Node2D = get_tree().get_first_node_in_group("transition_follow")
		transition_node.play(true, to_follow)
		
		await transition_node.finished
		transition_node.queue_free()
	
	changing_scenes = false
		
func start_new_game() -> void:
	#reset globals
	GlobalStats.reset()
	#load_scene(Scene.WORLD)
