class_name Player
extends CharacterBody2D

@export var move_speed: float = 600.0
@export var inventory: PlayerInventory
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var interaction_area: Area2D = $InteractionArea

## TODO
# Add player sprite (delete placeholder)
# Add player animation
# Adjust player speed
# Adjust collision shape
# Adjust interaction area size
# !!! Set collision mask for interaction area !!!
# Update how things are interacted with (the logic of it)


func _process(_delta: float) -> void:
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = move_direction * move_speed
	move_and_slide()

func _unhandled_key_input(event): # unhandled? maybe just use _input? _unhandled_input?
	if event.is_action_pressed("interact"):
		
		# Get closest ineractable and interact with it
		var closest_interactable: InteractionArea = null
		var closest_distance: float = INF;
		for node in interaction_area.get_overlapping_areas():
			if node is InteractionArea: ## TODO UPDATE THIS LOGIC
				var distance: float = global_position.distance_squared_to(node.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_interactable = node
					
		if closest_interactable:
			closest_interactable.interact(self)
	
	if event.is_action_pressed("drop_item"):
		inventory.drop_top_item()
