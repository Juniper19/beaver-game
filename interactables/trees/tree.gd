class_name PhysicalTree
extends StaticBody2D

const BAR_QTE: PackedScene = preload("uid://bmkceaeybu2w4")
var qte: BarQTE = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var drop_area: CollisionShape2D = $DropArea

var health = 5.0

@export var data: TreeData


func _ready():
	if data:
		_set_data(data)
	else:
		push_warning("Tree made without data!")


func _set_data(_data: TreeData):
	data = _data
	sprite.texture = data.texture_mature
	sprite.position.y = -sprite.texture.get_height() / 2.0
	health = data.health


func _on_interaction(by: Variant) -> void:
	if !by is Player:
		return

	var player := by as Player

	# First press — create QTE and start chop animation
	if !qte:
		qte = BAR_QTE.instantiate()
		$QTESpawn.add_child(qte)
		qte.hit.connect(_tree_hit)

		# Tell player to animate chopping
		player.start_cutting_animation()

	else:
		# Additional presses = QTE attempts
		qte.attempt_hit()


func _tree_hit():
	AudioManager.playWoodHit()
	health -= 1

	if health <= 0:
		_tree_die()

	# QTE bar handles rhythm, no shake needed here


func _tree_die():
	AudioManager.playQTESuccess()
	$Collider.disabled = true

	var rect: Rect2 = drop_area.shape.get_rect()
	var weight_sum: float = 0

	for v: float in data.drops.values():
		weight_sum += v

	# --- Normal drops ---
	for i in data.drop_amount:
		var random_drop: ItemData = null
		var rnd = randf_range(0.0, weight_sum)

		for drop: ItemData in data.drops.keys():
			var weight = data.drops[drop]
			if rnd < weight:
				random_drop = drop
				break
			rnd -= weight

		var random_pos: Vector2 = (
			Vector2(
				randf_range(rect.position.x, rect.position.x + rect.size.x),
				randf_range(rect.position.y, rect.position.y + rect.size.y)
			)
			+ drop_area.global_position
		)

		if !random_drop:
			push_warning("Nothing to drop from %s!" % data.name)
			break

		var item_scene = preload("res://interactables/items/item.tscn")
		var item: Item = item_scene.instantiate()
		item.data = random_drop
		get_tree().current_scene.add_child(item)
		item.position = random_pos

	# --- EXTRA DROP UPGRADE (Lumber Legend) ---
	var gs = get_node("/root/GlobalStats")

	if randf() < gs.extra_wood_chance:
		for drop: ItemData in data.drops.keys():
			var random_pos: Vector2 = (
				Vector2(
					randf_range(rect.position.x, rect.position.x + rect.size.x),
					randf_range(rect.position.y, rect.position.y + rect.size.y)
				)
				+ drop_area.global_position
			)

			var item_scene = preload("res://interactables/items/item.tscn")
			var item: Item = item_scene.instantiate()
			item.data = drop
			get_tree().current_scene.add_child(item)
			item.position = random_pos
			break

	# Clean QTE
	if qte:
		qte.queue_free()
		qte = null

	# Stop chopping animation
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.stop_cutting_animation()

	queue_free.call_deferred()


func _on_player_left_area(player: Player) -> void:
	# Player walks away mid-chop
	if qte:
		qte.queue_free()
		qte = null

	player.stop_cutting_animation()


func save() -> Dictionary:
	var save_data := {
		"position_x": global_position.x,
		"position_y": global_position.y,
		"item_resource": data.resource_path,
	}
	return save_data


func load(save_data: Dictionary):
	position = Vector2(
		save_data["position_x"],
		save_data["position_y"]
	)

	var _data = ResourceLoader.load(save_data["item_resource"])
	_set_data(_data)
