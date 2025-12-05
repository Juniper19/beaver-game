extends Node

var initialize_world: bool = true # whether or not to set world to initial, deletes save
var wood: int = 0
var pine_log: int = 0
var aspen_log: int = 0
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

static var ReqWood = int(randf_range(0,1))
static var ReqPineLog = int(randf_range(-10,-5))
static var ReqAspenLog = int(randf_range(-10,-5))
static var ReqMud = int(randf_range(-5,0))
static var ReqStone = int(randf_range(-5,0))

var WoodHeld:int = 0
var PineLogHeld:int = 0
var AspenLogHeld:int = 0
var MudHeld:int = 0
var StoneHeld:int = 0

var storage: Array = []
var storageNames: Array = []
var StorageLimit = 5
var ItemID = ""
var ExcessChestEntered = false
var QuotaChestEntered = false

var MaxedInv: bool = false


var tutorial_interact = true
var tutorial_drop = true
var tutorial_store = true
var tutorial_cycle = true
var tutorial_plant = true
var tutorials_left = 5


	#For saving values when scene changes
var excess_chest_storages: Array = []
var excess_chest_storage_names: Array = []

	# Chosen upgrades get removed from the available cards
var chosen_upgrades: Array[String] = []

	# UPGRADABLE STATS
var ExcessStorageCount = 5
var carry_capacity: int = 3
var move_speed_bonus: float = 0
var encumbrance_factor: float = 1.0 # 1 is default slow, .5 half as much punishing, etc.
var extra_rock_chance: float = 0.0
var extra_wood_chance: float = 0.0
var free_quota_miss: int = 0
var early_bird_minutes: int = 0   # subtract from start time
var sunrise_spark_duration: float = 0.0   # seconds
var sunrise_spark_bonus: float = 0.0      # multiplier (e.g. 0.2 = +20%)

#All start game values reset with new game
func reset():
	initialize_world = true
	
	wood = 0
	pine_log = 0
	aspen_log = 0
	mud = 0
	stone = 0
	water_level = 0
	wood_gather_rate = 1
	day_number = 0
	current_season = ""
	DayOne = true

	## Upgradable Stats
	rock_min_damage = 0
	rock_max_damage = 1

	ReqWood = int(randf_range(0,1))
	ReqPineLog = int(randf_range(-10,-5))
	ReqAspenLog = int(randf_range(-10,-5))
	ReqMud = int(randf_range(-5,0))
	ReqStone = int(randf_range(-5,0))

	WoodHeld = 0
	PineLogHeld = 0
	AspenLogHeld = 0
	MudHeld = 0
	StoneHeld= 0

	storage = []
	storageNames = []
	StorageLimit = 5
	ItemID = ""
	ExcessChestEntered = false
	QuotaChestEntered = false
	ExcessStorageCount = 5
	MaxedInv = false
	#For saving values when scene changes
	excess_chest_storages = []
	excess_chest_storage_names = []

	# Chosen upgrades get removed from the available cards
	chosen_upgrades = []

	# UPGRADABLE STATS
	carry_capacity = 3
	move_speed_bonus = 0
	encumbrance_factor = 1.0 # 1 is default slow, .5 half as much punishing, etc.
	extra_rock_chance = 0.0
	extra_wood_chance = 0.0
	free_quota_miss = 0
	early_bird_minutes= 0   # subtract from start time
	sunrise_spark_duration = 0.0   # seconds
	sunrise_spark_bonus = 0.0      # multiplier (e.g. 0.2 = +20%)

signal inventory_item_added(item)
signal inventory_item_removed(item)
signal Add_to_Quota(item)
signal inventory_item_placed(item)
signal ItemInChest
signal ItemInExcessChest(chest)
signal ItemFromExcessChest
signal GameOver

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


func is_quota_met() -> bool:
	#if DayOne:
		#return true

	var missed := (
		wood < ReqWood or
		pine_log < ReqPineLog or
		aspen_log < ReqAspenLog or
		mud < ReqMud or
		stone < ReqStone
	)

	if not missed:
		return true

	# --------------------------------------------------------------------
	# Dam Insurance check (FULLY FIXED — now properly subtracts and persists)
	# --------------------------------------------------------------------
	if free_quota_miss > 0:

		free_quota_miss -= 1
		print("Dam Insurance used! Now:", free_quota_miss)

		%TextTimer.start()
		%QuotaLabel.visible = true
		%QuotaLabel.text = "Quota missed... but Dam Insurance saved you!"

		return true
	# --------------------------------------------------------------------

	# No dam insurance → Game over
	print("Failed quota with no insurance. Game Over.")
	return false
