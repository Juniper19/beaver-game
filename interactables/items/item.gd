@tool

class_name Item
extends Node2D

signal picked_up(by: Node)
signal dropped(by: Node)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape: CollisionShape2D = $InteractionArea/CollisionShape2D


@export var data: ItemData:
	set(value):
		data = value
		if Engine.is_editor_hint() and value:
			var sprite := get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = value.texture

var item_name: String = "NO NAME"
var _held_by: Node

func _ready():
	if Engine.is_editor_hint():
		return
	
	if data:
		item_name = data.name
		sprite_2d.texture = data.texture
	
	interaction_area.interaction.connect(_on_interaction)


func _item_dropped_from_inventory(node: Node2D):
	if node != self:
		return
	
	collision_shape.disabled = false
	if _held_by and _held_by.has_signal("item_removed"):
		_held_by.disconnect("item_removed", _item_dropped_from_inventory)
	dropped.emit(_held_by)


func _on_interaction(by: Node):
	if by is Player and GlobalStats.ExcessChestEntered == false and GlobalStats.QuotaChestEntered == false:
		player_pickup(by as Player)
		return
	
	push_warning("Undandled interaction on item by %s" % by.get_class())


func player_pickup(player: Player):
	if player.inventory.add_item(self) :
		picked_up.emit(player)
		collision_shape.disabled = true
		_held_by = player.inventory
		
		player.inventory.connect("item_removed", _item_dropped_from_inventory)
