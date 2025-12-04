class_name UpgradeCard
extends TextureButton

@onready var highlight = $TextureRect
var tween: Tween


func _ready():
	update_highlight(is_hovered())


func update_highlight(hovered: bool):
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).tween_property(highlight, "modulate:a", 1.0 if hovered else 0.0, 0.3);


func set_data(_name: String, description: String):
	$VBoxContainer/Name.text = _name
	$VBoxContainer/Description.text = description


func _on_mouse_entered():
	update_highlight(true)


func _on_mouse_exited():
	update_highlight(false)
