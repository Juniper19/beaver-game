class_name BarQTE
extends Node2D

signal hit
signal miss

@onready var background: ColorRect = $Background
@onready var hit_zone: ColorRect = $HitZone
@onready var marker: ColorRect = $Marker

@export var _marker_padding: float = 0.0
@export var _hit_zone_padding: float = 2.0

## How much leeway the player has in hitting the zone
@export var _hit_margin: float = 0.0
@export var _marker_velocity: float = 50.0

var _marker_bounds: Vector2 # (min, max)
var _hit_zone_bounds: Vector2 # (min, max)


func _ready():
	_populate_y_bounds()
	_place_hit_zone()
	
	for qte in get_tree().get_nodes_in_group("qte"):
		if qte != self:
			qte.queue_free()


func set_hit_zone_size(size: float):
	hit_zone.size.y = min(size, background.size.y + _hit_zone_padding * 2.0)
	_populate_y_bounds()
	_place_hit_zone()


func get_hit_zone_size() -> float:
	return hit_zone.size.y


func set_marker_size(size: float):
	marker.size.y = min(size, background.size.y + _marker_padding * 2.0)
	_populate_y_bounds()


func get_marker_size() -> float:
	return marker.size.y


func _place_hit_zone():
	var new_y: float
	
	# try to place new hit zone that doesn't overlap it's previous zone
	# gives up after 10 tries
	for i in range(10):
		new_y = randf_range(_hit_zone_bounds.x, _hit_zone_bounds.y)
		if new_y + hit_zone.size.y < hit_zone.position.y or new_y > hit_zone.position.y + hit_zone.size.y:
			break
	
	hit_zone.position.y = new_y


func attempt_hit():
	var hit_zone_middle = hit_zone.position.y + (hit_zone.size.y / 2.0)
	var marker_middle = marker.position.y + (marker.size.y / 2.0)
	var max_hit_distance = hit_zone.size.y / 2.0 + _hit_margin
	
	if abs(hit_zone_middle - marker_middle) <= max_hit_distance:
		# HIT!
		_place_hit_zone()
		hit.emit()
	else:
		miss.emit()
		AudioManager.playSwing()


func _populate_y_bounds():
	_marker_bounds.x = background.position.y + _marker_padding
	_marker_bounds.y = background.position.y + background.size.y - marker.size.y - _marker_padding
	
	_hit_zone_bounds.x = background.position.y + _hit_zone_padding
	_hit_zone_bounds.y = background.position.y + background.size.y - hit_zone.size.y - _hit_zone_padding


func _physics_process(delta: float) -> void:
	marker.position.y += _marker_velocity * delta
	if marker.position.y < _marker_bounds.x:
		var difference: float = _marker_bounds.x - marker.position.y # positive number i think
		marker.position.y = _marker_bounds.x + difference
		_marker_velocity *= -1.0
	elif marker.position.y > _marker_bounds.y:
		var difference: float = _marker_bounds.y - marker.position.y
		marker.position.y = _marker_bounds.y - difference
		_marker_velocity *= -1.0
