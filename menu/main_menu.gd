extends Control

@onready var play_button: Button = $VBoxContainer/Button
var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	$Panel/VBoxContainer2/HSlider.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(sfx)))
	$Panel/VBoxContainer2/HSlider2.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(music)))

func _on_play_pressed() -> void:
	var world_scene: PackedScene = load("res://world.tscn")
	get_tree().change_scene_to_packed(world_scene)


func _on_audio_settings_button_pressed() -> void:
	$Panel.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_mm_button_pressed() -> void:
	$Panel.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx, linear_to_db(value)) # Replace with function body.

func _on_h_slider_2_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value)) # Replace with function body.
