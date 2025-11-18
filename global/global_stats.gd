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

signal inventory_item_added(item)
signal inventory_item_removed(item)
signal ItemInChest

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
