class_name Player
extends CharacterBody2D

@export var base_move_speed: float = 250.0
@export var speed_mult_per_item: float = 0.75
var move_speed: float

@export var inventory: PlayerInventory

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var last_dir: Vector2 = Vector2.DOWN
var is_mining: bool = false


func _ready() -> void:
	move_speed = base_move_speed

func _process(delta: float) -> void:
	var move_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * move_speed
	move_and_slide()

	_update_anim(move_dir)

func _update_anim(dir: Vector2) -> void:
	if is_mining:
		sprite.play("mine")
		return
	
	if dir == Vector2.ZERO:
		if last_dir.x != 0:
			sprite.play("idle_side")
			sprite.flip_h = last_dir.x > 0
		elif last_dir.y < 0:
			sprite.play("idle_up")
		else:
			sprite.play("idle_down")
		return

	# Walking
	last_dir = dir

	if abs(dir.x) > abs(dir.y):
		sprite.play("walk_side")
		sprite.flip_h = dir.x > 0
	elif dir.y < 0:
		sprite.play("walk_up")
	else:
		sprite.play("walk_down")

func start_mining_animation() -> void:
	is_mining = true
	sprite.play("mine")

func stop_mining_animation() -> void:
	is_mining = false
var is_cutting: bool = false

func start_cutting_animation() -> void:
	is_cutting = true
	sprite.play("cut")

func stop_cutting_animation() -> void:
	is_cutting = false

func _unhandled_key_input(event):
	if event.is_action_pressed("interact"):
		var closest: InteractionArea = null
		var closest_dist: float = INF

		for node in interaction_area.get_overlapping_areas():
			if node is InteractionArea:
				var dist = global_position.distance_squared_to(node.global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest = node
		
		if closest:
			closest.interact(self)

	if event.is_action_pressed("drop_item"):
		if GlobalStats.ExcessChestEntered == false and GlobalStats.QuotaChestEntered == false:
			inventory.drop_top_item()

	if event.is_action_pressed("plant_seed"):
		inventory.try_plant_seed()


func _calculate_move_speed() -> void:
	var gs = get_tree().root.get_node("GlobalStats")
	var day_night = get_tree().get_first_node_in_group("day_night")

	var item_count: int = inventory.get_items().size()

	var effective_mult_per_item: float = lerp(1.0, speed_mult_per_item, gs.encumbrance_factor)

	move_speed = (
		base_move_speed
		* (1.0 + gs.move_speed_bonus)
		* pow(effective_mult_per_item, item_count)
	)

	if day_night and gs.sunrise_spark_duration > 0.0:
		if day_night.time_since_day_start < gs.sunrise_spark_duration:
			move_speed *= (1.0 + gs.sunrise_spark_bonus)


func _on_player_inventory_item_added(_item):
	_calculate_move_speed()

func _on_player_inventory_item_removed(_item):
	_calculate_move_speed()
