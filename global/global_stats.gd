extends Node

var wood: int = 0
var mud: int = 0
var stone: int = 0
var water_level: int = 0
var wood_gather_rate = 1
var day_number: int = 0
var current_season: String = ""

var rock_min_damage: float = 0
var rock_max_damage: float = 1

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
