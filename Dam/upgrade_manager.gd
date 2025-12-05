extends Node

signal upgrade_selected

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null

# ----------CARD OPTIONS-----------------
@export var all_cards: Array[Dictionary] = [
	{"name": "Faster Legs", "desc": "Movement Speed +10%", "effect": {"move_speed_bonus": 0.1}},
	{"name": "Depth Strider", "desc": "+30% speed boost when swimming", "effect": {"swim_speed_bonus": 0.3}},
	{"name": "Ripped!", "desc": "Carry 1 Additional Item", "effect": {"carry_capacity": 1}},
	{"name": "More Ripped!", "desc": "Carry 2 Additional Items", "effect": {"carry_capacity": 2}},
	{"name": "Stone Smasher", "desc": "50% chance for rocks to drop an extra", "effect": {"extra_rock_chance": 0.5}},
	{"name": "Thunder Thighs", "desc": "Item weight affects speed less", "effect": {"encumbrance_factor": .85}},
	{"name": "Dam Insurance", "desc": "The dam is safe from 1 missed quota.", "effect": {"free_quota_miss": 1}},
	{"name": "Early Bird", "desc": "Start each day 2 hours earlier", "effect": {"early_bird_minutes": 120}},
	{"name": "Sunrise Spark", "desc": "Move faster for the first 60 seconds of each day", "effect": {"sunrise_spark_duration": 60.0, "sunrise_spark_bonus": 0.20}},
	{"name": "True Beaver", "desc": "50% chance to get extra wood from trees", "effect": {"extra_wood_chance": 0.5}},
	{"name": "Storage I", "desc": "Gain an extra storage unit.", "effect": {"ExcessStorageCount": 1}},
	{"name": "Storage II", "desc": "Gain an extra storage unit.", "effect": {"ExcessStorageCount": 1}, "requires": "Bigger Barn I"},
	{"name": "Storage III", "desc": "Gain an extra storage unit.", "effect": {"ExcessStorageCount": 1}, "requires": "Bigger Barn II"},

]

@onready var card_ui: CanvasLayer = $CardUI
@onready var card_container: HBoxContainer = $CardUI/CenterContainer/CardContainer

var showing: bool = false

# ----------------------------
func _ready() -> void:
	# Make sure GlobalStats exists
	if get_tree().get_root().has_node("GlobalStats"):
		global_stats = get_tree().get_root().get_node("GlobalStats")
	else:
		global_stats = GlobalStatsScript.new()
		global_stats.name = "GlobalStats"
		get_tree().get_root().add_child(global_stats)

	card_ui.visible = false

#func _process(_delta: float) -> void:
	## CHANGE THIS BASED ON WHEN WE WANT TO TRIGGER UPGRADES
	#if Input.is_action_just_pressed("ui_accept") and not showing:
		#show_three_cards()
	#elif Input.is_action_just_pressed("ui_cancel") and showing:
		#hide_cards()

func show_three_cards() -> void:
	showing = true
	card_ui.visible = true

	for child in card_container.get_children():
		child.queue_free()

	var selected_cards = _get_random_cards(2)
	for card_data in selected_cards:
		var card = _create_card(card_data)
		card_container.add_child(card)

func hide_cards() -> void:
	showing = false
	card_ui.visible = false

func _get_random_cards(count: int) -> Array[Dictionary]:
	var pool: Array = []
	for card in all_cards:
		if global_stats.chosen_upgrades.has(card["name"]):
			continue

		# Check requirements
		if card.has("requires"):
			if not global_stats.chosen_upgrades.has(card["requires"]):
				continue

		pool.append(card)

	if pool.is_empty():
		print("All upgrades already chosen!")
		return []

	pool.shuffle()
	return Array(pool.slice(0, min(count, pool.size())), TYPE_DICTIONARY, "", null)

func _create_card(data: Dictionary) -> Control:
	var card: UpgradeCard = preload("res://Dam/upgrade_card.tscn").instantiate()
	card.set_data(data["name"], data["desc"])
	card.pressed.connect(_apply_card.bind(data))

	return card

func _apply_card(data: Dictionary) -> void:
	upgrade_selected.emit()
	if global_stats:
		global_stats.apply_effect(data["effect"])
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player._calculate_move_speed()
		if not global_stats.chosen_upgrades.has(data["name"]):
			global_stats.chosen_upgrades.append(data["name"])
	else:
		push_warning("GlobalStats not found!")
	hide_cards()
