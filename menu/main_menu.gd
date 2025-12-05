extends Control

@onready var play_button: TextureButton = $HBoxContainer/PlayButton
var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")

@export var scroll_speed: Vector2 = Vector2(40, 40)  # pixels per second
@onready var bg: TextureRect = $BG
@onready var sfx_slider: HSlider = $Panel/VBoxContainer2/HSlider
@onready var music_slider: HSlider = $Panel/VBoxContainer2/HSlider2


func _ready() -> void:
	# Send scroll speed + texture size to shader
	var mat := bg.material as ShaderMaterial
	mat.set_shader_parameter("scroll_speed", scroll_speed)
	mat.set_shader_parameter("texture_size", bg.texture.get_size())

	play_button.pressed.connect(_on_play_pressed)
	# Restore slider visuals from saved linear values
	sfx_slider.set_value_no_signal(GlobalStats.sfx_linear)
	music_slider.set_value_no_signal(GlobalStats.music_linear)

	# Apply saved volumes to AudioServer buses
	AudioServer.set_bus_volume_db(GlobalStats.SFX_BUS, linear_to_db(GlobalStats.sfx_linear))
	AudioServer.set_bus_volume_db(GlobalStats.MUSIC_BUS, linear_to_db(GlobalStats.music_linear))



func _on_play_pressed() -> void:
	SceneManager.load_scene(SceneManager.Scene.WORLD, SceneManager.Transition.CIRCLE)

func _on_audio_settings_button_pressed() -> void:
	$Panel.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_mm_button_pressed() -> void:
	$Panel.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	GlobalStats.sfx_linear = value
	AudioServer.set_bus_volume_db(sfx, linear_to_db(value))
	AudioManager.playMenuSound()


func _on_h_slider_2_value_changed(value: float) -> void:
	GlobalStats.music_linear = value
	AudioServer.set_bus_volume_db(music, linear_to_db(value))
