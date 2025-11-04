class_name Item
extends Area2D

func interact(player: Player):
	player.inventory.add_item(self)
