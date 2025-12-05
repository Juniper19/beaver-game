extends Control

@onready var play_button: TextureButton = $HBoxContainer/PlayButton
var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")

@export var scroll_speed: Vector2 = Vector2(40, 40)  # pixels per second

@onready var bg: TextureRect = $BG

func _ready() -> void:
	# Send scroll speed + texture size to shader
	var mat := bg.material as ShaderMaterial
	mat.set_shader_parameter("scroll_speed", scroll_speed)
	mat.set_shader_parameter("texture_size", bg.texture.get_size())

	play_button.pressed.connect(_on_play_pressed)
	if not GlobalStats.initialized:
		GlobalStats.sfx_volume_db = AudioServer.get_bus_volume_db(sfx)
		GlobalStats.music_volume_db = AudioServer.get_bus_volume_db(music)
		GlobalStats.initialized = true


	$Panel/VBoxContainer2/HSlider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(GlobalStats.sfx_volume_db)))
	$Panel/VBoxContainer2/HSlider2.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(GlobalStats.music_volume_db)))


func _on_play_pressed() -> void:
	SceneManager.load_scene(SceneManager.Scene.WORLD, SceneManager.Transition.CIRCLE)

func _on_audio_settings_button_pressed() -> void:
	$Panel.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_mm_button_pressed() -> void:
	$Panel.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	GlobalStats.sfx_volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx, GlobalStats.sfx_volume_db)
	AudioManager.playMenuSound()


func _on_h_slider_2_value_changed(value: float) -> void:
	GlobalStats.music_volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(music, GlobalStats.music_volume_db)
