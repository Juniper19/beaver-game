extends Node2D

const Columns = 3
const Starting_Pos = Vector2(100,200)
const Cell_Size = Vector2(110,110)

const ExcessStorage = preload("res://interactables/Storage/excess_storage.tscn")
@onready var inventory_ui := get_node("Player/PlayerInventory")

func _ready():
	GlobalStats.ItemInExcessChest.connect(inventory_ui._on_item_in_excess_chest)
	spawn_storage_grid(GlobalStats.ExcessStorageCount)
		
		
func spawn_storage_grid(count: int):
	for i in range(count):
		var Storage = ExcessStorage.instantiate()
		
		Storage.chest_id = i
		
		add_child(Storage)

		var row = i / Columns
		var col = i % Columns
		
		Storage.position = Vector2(col *Cell_Size.x + Starting_Pos.x, row *Cell_Size.y + Starting_Pos.y)
