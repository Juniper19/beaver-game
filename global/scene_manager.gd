# SceneManager
extends Node

enum Scene {
	NONE,
	WORLD,
	INSIDE_DAM,
	#MAIN_MENU
}

enum Transition {
	NONE,
	CIRCLE,
}

var _scenes: Dictionary[Scene, String] = {
	Scene.WORLD: "uid://cl1jmkdurg2bg",
	Scene.INSIDE_DAM: "uid://cus4fv7iknxoj"
	#Scene.MAIN_MENU: <main menu path>
}

var _transitions: Dictionary[Transition, String] = {
	Transition.CIRCLE: "uid://bc7t6gr8ow85a",
}

var changing_scenes = false



func load_scene(target_scene: Scene, transition: Transition = Transition.NONE) -> void:
	if changing_scenes:
		return

	if target_scene == Scene.NONE:
		push_warning("Cannot change scene to NONE!")
		return
		
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
		var transition_scene = load(_transitions[transition])
		transition_node = transition_scene.instantiate()
		get_tree().root.add_child(transition_node)
		
		var player: Player = get_tree().get_first_node_in_group("player")
		transition_node.play(false, player)
		
		await transition_node.finished
	
	
	var error = get_tree().change_scene_to_file(target_path)
	
	
	if error != OK:
		if transition_node:
			transition_node.queue_free()
		push_error("Error loading scene: ", error)
		changing_scenes = false
		return
	
	
	current_scene = get_tree().current_scene
	
	if target_scene == Scene.INSIDE_DAM:
		if GlobalStats.DayOne == true:
			GlobalStats.DayOne=false
		AudioManager.stopMusic1()
		
		
	if transition_node:
		await get_tree().scene_changed
		var player: Player = get_tree().get_first_node_in_group("player")
		transition_node.play(true, player)
		
		await transition_node.finished
		transition_node.queue_free()
	
	changing_scenes = false
