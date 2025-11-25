class_name InteractionArea
extends Area2D

signal interaction(by: Node)
signal player_entered_area(player: Player)
signal player_left_area(player: Player)

func interact(by: Node):
	interaction.emit(by)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_left_area.emit(body)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered_area.emit(body)
