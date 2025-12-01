class_name InteractionArea
extends Area2D

signal interaction(by: Node)
signal player_entered_area(player: Player)
signal player_left_area(player: Player)

func interact(by: Node):
	interaction.emit(by)


func _on_area_exited(body: Area2D) -> void:
	var parent = body.get_parent()
	if parent is Player:
		player_left_area.emit(parent)


func _on_area_entered(body: Area2D) -> void:
	var parent = body.get_parent()
	if parent is Player:
		player_entered_area.emit(parent)
