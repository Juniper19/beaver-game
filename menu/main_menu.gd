extends Control

@onready var play_button: Button = $VBoxContainer/Button

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	var world_scene: PackedScene = load("res://world.tscn")
	get_tree().change_scene_to_packed(world_scene)
