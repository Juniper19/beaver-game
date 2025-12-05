class_name Player
extends CharacterBody2D

@export var base_move_speed: float = 175.0
@export var speed_bonus: float = 1.25
@export var speed_mult_per_item: float = 0.75
var move_speed: float

@export var inventory: PlayerInventory

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var tutorial_popup: TutorialPopup = $TutorialPopup

@export var disable_camera: bool = false

var last_dir: Vector2 = Vector2.DOWN
var is_mining: bool = false


func _ready() -> void:
	_calculate_move_speed()
	_try_disconnect_tutorials()

func _physics_process(_delta: float) -> void:
	var move_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = lerp(velocity, move_dir * move_speed, 0.09)
	#velocity.x = sign(x) * floor(sign(x) * velocity.x)
	move_and_slide()
	
	var swimming = _is_swimming()
	_update_anim(move_dir, swimming)
	_calculate_move_speed(swimming)

	if move_dir != Vector2(0.0,0.0):
		if swimming:
			 # play swim sound
			AudioManager.playSplash()
		else:
			AudioManager.playFootsteps()


func _update_anim(dir: Vector2, swimming: bool = false) -> void:
	if is_mining:
		sprite.play("mine")
		return

	if is_cutting:
		sprite.play("cut")
		return

	if dir.is_zero_approx():
		if last_dir.x != 0:
			sprite.play("swim_down" if swimming else "idle_side")
			sprite.flip_h = last_dir.x > 0
		else:
			sprite.stop()
		return

	last_dir = dir

	if abs(dir.x) > abs(dir.y):
		# Horizontal movement
		sprite.play("swim_side" if swimming else "walk_side")
		sprite.flip_h = dir.x > 0
	else:
		# Vertical movement
		if dir.y < 0:
			sprite.play("swim_up" if swimming else "walk_up")
		else:
			sprite.play("swim_down" if swimming else "walk_down")


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
		var ignore_items: bool = inventory.is_full()

		for node in interaction_area.get_overlapping_areas():
			if node is InteractionArea:
				if ignore_items and node.get_parent() is Item:
					continue
				var dist = global_position.distance_squared_to(node.global_position)
				if dist < closest_dist:
					closest_dist = dist
					closest = node
		
		if closest:
			closest.interact(self)
			if tutorial_popup.current_animation == "e":
				tutorial_popup.hide_tutorial()


	if event.is_action_pressed("drop_item"):
		if GlobalStats.ExcessChestEntered == false and GlobalStats.QuotaChestEntered == false:
			inventory.drop_top_item()
			if tutorial_popup.current_animation == "q":
				tutorial_popup.hide_tutorial()
		elif tutorial_popup.current_animation == "q":
				tutorial_popup.hide_tutorial()

	if event.is_action_pressed("plant_seed"):
		inventory.try_plant_seed(global_position + Vector2(0, 32))
		if tutorial_popup.current_animation == "z":
				tutorial_popup.hide_tutorial()
	
	if event.is_action_pressed("cycle_down"):
		inventory.cycle_items(true)
	elif event.is_action_pressed("cycle_up"):
		inventory.cycle_items(false)
		if tutorial_popup.current_animation == "space":
				tutorial_popup.hide_tutorial()
	

func _calculate_move_speed(swimming: bool = false) -> void:
	var gs = get_tree().root.get_node("GlobalStats")
	var day_night = get_tree().get_first_node_in_group("day_night")

	var item_count: int = inventory.get_items().size()

	var effective_mult_per_item: float = lerp(1.0, speed_mult_per_item, gs.encumbrance_factor)

	move_speed = (
		base_move_speed
		* (1.0 + gs.move_speed_bonus)
		* pow(effective_mult_per_item, item_count)
		* (1.0 + GlobalStats.swim_speed_bonus * int(swimming)) 
	)
	

	if day_night and gs.sunrise_spark_duration > 0.0:
		if day_night.time_since_day_start < gs.sunrise_spark_duration:
			move_speed *= (1.0 + gs.sunrise_spark_bonus)
	
	move_speed = floor(move_speed)


func _on_player_inventory_item_added(_item):
	_calculate_move_speed()

func _on_player_inventory_item_removed(_item):
	_calculate_move_speed()



func _on_interaction_area_entered_tutorial_check(area: Area2D) -> void:
	if GlobalStats.tutorials_left <= 0:
		_try_disconnect_tutorials()
		return
	
	if area.get_parent() is Door:
		return
	
	if GlobalStats.tutorial_interact and area is InteractionArea and area.get_parent() is not ExcessStorage and tutorial_popup.show_tutorial("e"):
		GlobalStats.tutorial_interact = false
		GlobalStats.tutorials_left -= 1
	
	if GlobalStats.tutorial_store and area.get_parent() is ExcessStorage and !inventory.is_empty() and tutorial_popup.show_tutorial("q"):
		GlobalStats.tutorial_store = false
		GlobalStats.tutorials_left -= 1
	
	_try_disconnect_tutorials()

func _on_item_added_tutorial_check(item: Node2D) -> void:
	if GlobalStats.tutorials_left <= 0:
		_try_disconnect_tutorials()
		return
	
	if GlobalStats.tutorial_plant and (item as Item).item_name.containsn("seed") and tutorial_popup.show_tutorial("z"):
		GlobalStats.tutorial_plant = false
		GlobalStats.tutorials_left -= 1
	elif GlobalStats.tutorial_cycle and inventory.inventory_items.size() > 1 and tutorial_popup.show_tutorial("space"):
		GlobalStats.tutorial_cycle = false
		GlobalStats.tutorials_left -= 1
	elif GlobalStats.tutorial_drop and inventory.is_full() and tutorial_popup.show_tutorial("q"):
		GlobalStats.tutorial_drop = false
		GlobalStats.tutorials_left -= 1
	
	
	_try_disconnect_tutorials()

func _try_disconnect_tutorials():
	if GlobalStats.tutorials_left > 0:
		return
	
	interaction_area.area_entered.disconnect(_on_interaction_area_entered_tutorial_check)
	inventory.item_added.disconnect(_on_item_added_tutorial_check)


func _is_swimming():
	var tiles: TileMapLayer = get_tree().get_first_node_in_group("tilemap")
	if !tiles:
		return false
	
	var tile_pos = tiles.to_local(global_position)
	var cell_coords = tiles.local_to_map(tile_pos)
	var tile_data: TileData = tiles.get_cell_tile_data(cell_coords)
	return tile_data.get_custom_data("swimmable")
