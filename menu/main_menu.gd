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

	$Panel/VBoxContainer2/HSlider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(sfx)))
	$Panel/VBoxContainer2/HSlider2.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(music)))


func _on_play_pressed() -> void:
	SceneManager.load_scene(SceneManager.Scene.WORLD, SceneManager.Transition.CIRCLE)

func _on_audio_settings_button_pressed() -> void:
	$Panel.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_mm_button_pressed() -> void:
	$Panel.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx, linear_to_db(value))

func _on_h_slider_2_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value))
