extends Node

var initialize_world: bool = true # whether or not to set world to initial, deletes save

var wood: int = 0
var mud: int = 0
var stone: int = 0
var water_level: int = 0
var wood_gather_rate = 1
var day_number: int = 0
var current_season: String = ""
var DayOne: bool = true

## Upgradable Stats
var rock_min_damage: float = 0
var rock_max_damage: float = 1

static var ReqWood = int(randf_range(0,3))
static var ReqMud = int(randf_range(-5,0))
static var ReqStone = int(randf_range(-5,0))

var WoodHeld = 0
var MudHeld = 0
var StoneHeld = 0

var storage: Array = []
var storageNames: Array = []
var StorageLimit = 5
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

# UPGRADABLE STATS
var carry_capacity: int = 3
var move_speed_bonus: int = 0
var encumbrance_factor: float = 1.0 # 1 is default slow, .5 half as much punishing, etc.
var extra_rock_chance: float = 0.0
var extra_wood_chance: float = 0.0
var free_quota_miss: int = 0
var early_bird_minutes: int = 0   # subtract from start time
var sunrise_spark_duration: float = 0.0   # seconds
var sunrise_spark_bonus: float = 0.0      # multiplier (e.g. 0.2 = +20%)


## Janky-ass way to do it but... it works
const ITEM_TO_TREE: Dictionary[String, String] = {
	"Oak Seed": "uid://dps300dufah0",
	"Aspen Seed": "uid://de4jpe12kbg52",
	"Pine Seed": "uid://coq60gmhpggti",
}


# Called when an upgrade is picked
# Every upgrade/card passes a dictionary, ie: { "wood_gather_rate": +0.2 }
func apply_effect(effect: Dictionary) -> void:
	for key in effect.keys():
		
		# Upgrade: carry capacity
		if key == "carry_capacity":
			carry_capacity += int(effect[key])
			print("Carry Capacity increased to:", carry_capacity)
			continue

		if key == "move_speed_bonus":
			move_speed_bonus += float(effect[key])
			print("MOVE SPEED BONUS NOW =", move_speed_bonus)
			continue
			
		if key == "encumbrance_factor":
			encumbrance_factor *= float(effect[key])
			print("Encumbrance factor is now:", encumbrance_factor)
			continue
					
		if key == "extra_rock_chance":
			extra_rock_chance += float(effect[key])
			print("Extra rock chance now:", extra_rock_chance)
			continue
			
		if key == "extra_wood_chance":
			extra_wood_chance += float(effect[key])
			print("Extra wood chance now:", extra_wood_chance)
			continue

		if key == "free_quota_miss":
			free_quota_miss += int(effect[key])
			print("Free quota misses now:", free_quota_miss)
			continue

		if key == "early_bird_minutes":
			early_bird_minutes += int(effect[key])
			print("Early bird bonus now:", early_bird_minutes, "minutes")
			continue
			
		if key == "sunrise_spark_duration":
			sunrise_spark_duration += float(effect[key])
			continue

		if key == "sunrise_spark_bonus":
			sunrise_spark_bonus += float(effect[key])
			continue


		# Default stat behavior
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
