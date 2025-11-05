class_name InteractionArea
extends Area2D

signal interaction(by)

func interact(by: Node):
	interaction.emit(by)
	
