extends Node2D

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null
var storage = []

func _ready() -> void:

	# Make sure GlobalStats exists
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)
		
	%InteractLabel.visible = false
	
	GlobalStats.inventory_item_placed.connect(_on_item_placed)

func _process(_delta: float) -> void:
	if $InteractionArea.get_overlapping_bodies().size() > 0:
		%InteractLabel.visible = true
	else:
		%InteractLabel.visible = false
		
	if Input.is_action_just_pressed("ui_accept") and $InteractionArea.get_overlapping_bodies().size() > 0:
		add_item()
	
func add_item():
		GlobalStats.emit_signal("ItemInExcessChest")

func _on_item_placed(item):

	if storage.size() < GlobalStats.StorageLimit:
		storage.append(item.item_name)
		print(storage)
