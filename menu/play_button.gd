extends TextureButton

@export var hover_lighten := 0.2

func _ready():
	self_modulate = Color(1, 1, 1, 1)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	AudioManager.playMenuSound()
	self_modulate = Color(
		1.0 + hover_lighten,
		1.0 + hover_lighten,
		1.0 + hover_lighten,
		1.0
	)

func _on_exit():
	self_modulate = Color(1, 1, 1, 1)
