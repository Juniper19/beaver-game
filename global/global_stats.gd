extends Node

var wood: int = 0
var mud: int = 0
var stone: int = 0
var water_level: int = 0
var wood_gather_rate = 1
var day_number: int = 0
var current_season: String = ""

static var ReqWood = int(randf_range(0,3))
static var ReqMud = int(randf_range(-5,0))
static var ReqStone = int(randf_range(-5,0))

var WoodHeld = 0
var MudHeld = 0
var StoneHeld = 0

var storage: Array = []
var storageNames: Array = []
var StorageLimit = 10
var ItemID = ""
var ExcessChestEntered = false
var QuotaChestEntered = false
var ExcessStorageCount = 5

signal inventory_item_added(item)
signal inventory_item_removed(item)
signal Add_to_Quota(item)
signal inventory_item_placed(item)
signal ItemInChest
signal ItemInExcessChest(chest)
signal ItemFromExcessChest

#For saving values when scene changes
var excess_chest_storages: Array = []
var excess_chest_storage_names: Array = []

# Chosen upgrades get removed from the available cards
var chosen_upgrades: Array[String] = []

# Called when an upgrade is picked
# Every upgrade/card passes a dictionary, ie: { "wood_gather_rate": +0.2 }
func apply_effect(effect: Dictionary) -> void:
	for key in effect.keys():
		if key in get_property_names():
			var old_value = get(key)
			set(key, old_value + effect[key])
			print("Stat changed:", key, "→", get(key))
		else:
			push_warning("Unknown stat: %s" % key)

func get_property_names() -> Array[String]:
	var names: Array[String] = []
	for p in get_property_list():
		names.append(p.name)
	return names
