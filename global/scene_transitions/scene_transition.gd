class_name SceneTransition
extends CanvasLayer

signal finished

@onready var color_rect: ColorRect = $SubViewport/ColorRect
@onready var animation_player: AnimationPlayer = $SubViewport/ColorRect/AnimationPlayer
@onready var shader: ShaderMaterial = ($SubViewport/ColorRect.material as ShaderMaterial)

var _following: Node2D

func _ready():
	animation_player.animation_finished.connect(finished.emit)

func play(transition_out: bool = true, follow: Node2D = null):
	
	_following = follow
	_physics_process(0.0)
	$TextureRect.show()
	
	shader.set_shader_parameter("asp", color_rect.size.aspect())
	
	if transition_out:
		animation_player.play("transition_out")
	else:
		animation_player.play_backwards("transition_out")

func _physics_process(_delta: float):
	if _following and shader:
		var screen_pos = get_node_screen_position(_following)
		shader.set_shader_parameter("center", screen_pos)


func get_node_screen_position(node: Node2D) -> Vector2:
	var viewport = node.get_viewport()
	var screen_pos = node.get_global_transform_with_canvas().origin
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var normalized_pos: Vector2 = screen_pos / viewport_size
	return normalized_pos
