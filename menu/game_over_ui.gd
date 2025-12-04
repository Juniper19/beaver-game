extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

func _ready() -> void:

	#visible = false
	# Listen to the global game_over signal
	#GlobalStats.GameOver.connect(_on_global_game_over)
	
	#pause_mode = Node.PAUSE_MODE_PROCESS  # UI still works while game paused
	#anim.animation_finished.connect(_on_animation_finished)
	
	#retry_button.pressed.connect(_on_retry_pressed)
	#main_menu_button.pressed.connect(_on_menu_pressed)
	
	%Label.text = "You didn't hit the quota! You reached Day " + str(GlobalStats.day_number)
	AudioManager.stopInsideMusic()
	
	await get_tree().create_timer(0.4).timeout
	

func _on_retry_pressed() -> void:
	anim.stop()
	anim.seek(0.0, true)
	
	#get_tree().paused = false
	SceneManager.start_new_game()
	SceneManager.load_scene(SceneManager.Scene.WORLD, SceneManager.Transition.CIRCLE)

func _on_menu_pressed() -> void:
	anim.stop()
	anim.seek(0.0, true)
	
	#get_tree().paused = false
	SceneManager.start_new_game()
	SceneManager.load_scene(SceneManager.Scene.MAIN_MENU)
