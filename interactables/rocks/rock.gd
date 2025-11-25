class_name PhysicalRock
extends StaticBody2D

## QTE Data
const CHARGE_QTE: PackedScene = preload("uid://y8wjhrnqgdyp")
var qte: ChargeQTE = null

## Shake data
var _default_shake_position: Vector2
var _shake_strength: float = 0.0

## Useful children
@onready var sprite: Sprite2D = $Sprite2D
@onready var drop_area: CollisionShape2D = $DropArea

## Rock stats
@export var health: float = 5.0
@export var drop_amount: int = 3
@export var drops: Dictionary[ItemData, float] = {
	preload("res://interactables/items/item_resources/stone.tres"): 1.0
}


func _ready():
	_default_shake_position = sprite.position


func _physics_process(_delta):
	_do_shake()


func _on_interaction(by: Variant) -> void:
	if !by is Player:
		return
	
	if !qte:
		qte = CHARGE_QTE.instantiate()
		$QTESpawn.add_child(qte)
		qte.hit.connect(_rock_hit)
	else:
		qte.attempt_hit()


func _rock_hit(progress: float):
	## TODO
	## Change this for balancing
	## Progress is in [0-1]
	
	var damage = progress * (GlobalStats.rock_max_damage - GlobalStats.rock_min_damage) + GlobalStats.rock_min_damage
	AudioManager.playRockHit(damage)
	health -= damage
	if health <= 0:
		_rock_die()
	
	# make shake
	_shake_strength = pow(progress, 2.0) * 5.0

func _rock_die():
	AudioManager.playQTESuccess()
	$Collider.disabled = true
	var rect: Rect2 = drop_area.shape.get_rect()
	var weight_sum: float = 0
	
	for v: float in drops.values():
		weight_sum += v
	
	# --- Normal drops ---
	for i in drop_amount:
		var random_drop: ItemData = null
		var rnd = randf_range(0.0, weight_sum)

		for drop: ItemData in drops.keys():
			var weight = drops[drop]
			if rnd < weight:
				random_drop = drop
				break
			rnd -= weight
		
		var random_pos: Vector2 = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		) + drop_area.global_position
		
		if !random_drop:
			push_warning("Nothing to drop from rock!")
			break
			
		var item_scene = preload("res://interactables/items/item.tscn")
		var item: Item = item_scene.instantiate()
		item.data = random_drop
		get_tree().current_scene.add_child(item)
		item.position = random_pos


	# --- EXTRA DROP UPGRADE (Stone Smasher) ---
	var gs = get_node("/root/GlobalStats")
	if randf() < gs.extra_rock_chance:
		# pick first available drop type (stone)
		for drop: ItemData in drops.keys():
			var random_pos: Vector2 = Vector2(
				randf_range(rect.position.x, rect.position.x + rect.size.x),
				randf_range(rect.position.y, rect.position.y + rect.size.y)
			) + drop_area.global_position

			var item_scene = preload("res://interactables/items/item.tscn")
			var item: Item = item_scene.instantiate()
			item.data = drop
			get_tree().current_scene.add_child(item)
			item.position = random_pos
			break
	qte.queue_free()
	qte = null
	queue_free.call_deferred()


func _on_player_left_area(_player: Player) -> void:
	if qte:
		qte.queue_free()
		qte = null

func _do_shake() -> void:
	if _shake_strength <= 0.0 or is_zero_approx(_shake_strength):
		return
	
	var rand_angle = randf_range(0.0, TAU)
	var offset_direction = Vector2(cos(rand_angle), sin(rand_angle))
	sprite.position = _default_shake_position + offset_direction * _shake_strength
	
	_shake_strength = lerpf(_shake_strength, 0.0, 0.15)

## This assumes all rocks are the same... 
## which they are for now
func save() -> Dictionary:
	var save_data = {
		"position_x": position.x,
		"position_y": position.y
	}
	
	return save_data

func load(save_data: Dictionary):
	position = Vector2(
		save_data["position_x"],
		save_data["position_y"]
	)
