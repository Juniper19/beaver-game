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
		sprite.texture = data.texture_mature
		sprite.position.y = -sprite.texture.get_height() / 2.0 ### CHANGE ME WHEN TEXTURES
		health = data.health
	else:
		push_warning("Tree made without data!")


func _on_interaction(by: Variant) -> void:
	if !by is Player:
		return
	
	if !qte:
		qte = BAR_QTE.instantiate()
		$QTESpawn.add_child(qte)
		qte.hit.connect(_tree_hit)
	else:
		qte.attempt_hit()


func _tree_hit():
	health -= 1
	if health <= 0:
		_tree_die()
		qte.queue_free()
		qte = null


func _tree_die():
	$Collider.disabled = true
	var rect: Rect2 = drop_area.shape.get_rect()
	var weight_sum: float = 0
	
	for v: float in data.drops.values():
		weight_sum += v
	
	for i in data.drop_amount:
		var random_drop: ItemData
		var rnd = randf_range(0.0, weight_sum)
		for drop: ItemData in data.drops.keys():
			var weight = data.drops[drop]
			if rnd < weight:
				random_drop = drop
				break
			rnd -= weight
		
		var random_pos: Vector2 = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y),
		) + drop_area.global_position
		
		if !random_drop:
			push_warning("Nothing to drop from %s!" % data.name)
			break
			
		var item_scene = preload("res://interactables/items/item.tscn")
		var item: Item = item_scene.instantiate()
		item.data = random_drop
		print("Drop %s" % random_drop.name)
		get_tree().current_scene.add_child(item)
		item.position = random_pos
	queue_free.call_deferred()

func _on_player_left_area(_player: Player) -> void:
	if qte:
		qte.queue_free()
		qte = null
