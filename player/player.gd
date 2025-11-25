class_name Player
extends CharacterBody2D

@export var base_move_speed: float = 600.0
@export var speed_mult_per_item: float = 0.75
var move_speed: float
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

func _ready():
	move_speed = base_move_speed

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
		if GlobalStats.ExcessChestEntered == false and GlobalStats.QuotaChestEntered == false:
			inventory.drop_top_item()
	
	if event.is_action_pressed("plant_seed"):
		inventory.try_plant_seed()


func _calculate_move_speed() -> void:
	var gs = get_tree().root.get_node("GlobalStats")
	var day_night = get_tree().get_first_node_in_group("day_night")

	var item_count: int = inventory.get_items().size()

	# Encumbrance multiplier (Thunder Thighs)
	var effective_mult_per_item: float = lerp(
		1.0,
		speed_mult_per_item,
		gs.encumbrance_factor
	)

	# ----- BASE MOVEMENT -----
	move_speed = (
		base_move_speed
		* (1.0 + gs.move_speed_bonus)
		* pow(effective_mult_per_item, item_count)
	)

	# ----- SUNRISE SPARK BONUS -----
	if day_night and gs.sunrise_spark_duration > 0.0:
		if day_night.time_since_day_start < gs.sunrise_spark_duration:
			move_speed *= (1.0 + gs.sunrise_spark_bonus)


func _on_player_inventory_item_added(_item):
	_calculate_move_speed()

func _on_player_inventory_item_removed(_item):
	_calculate_move_speed()
