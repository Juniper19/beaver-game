class_name PhysicalTree
extends StaticBody2D

const BAR_QTE: PackedScene = preload("uid://bmkceaeybu2w4")
var qte: BarQTE = null

@export var health = 5.0

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
	print("I died")
	$Collider.disabled = true


func _on_player_left_area(_player: Player) -> void:
	if qte:
		qte.queue_free()
		qte = null
