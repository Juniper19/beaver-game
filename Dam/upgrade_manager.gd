extends Node

signal upgrade_selected

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null

# ----------CARD OPTIONS-----------------
@export var all_cards: Array[Dictionary] = [
	{"name": "Faster Legs", "desc": "Movement Speed +10%", "effect": {"move_speed_bonus": 0.1}},
	{"name": "Ripped!", "desc": "Carry 1 Additional Item", "effect": {"carry_capacity": 1}},
	{"name": "More Ripped!", "desc": "Carry 2 Additional Items", "effect": {"carry_capacity": 2}},
	{"name": "Stone Smasher", "desc": "50% chance for rocks to drop an extra", "effect": {"extra_rock_chance": 0.5}},
	{"name": "Thunder Thighs", "desc": "Item weight affects speed less", "effect": {"encumbrance_factor": .85}},
	{"name": "Dam Insurance", "desc": "The dam is safe from 1 missed quota.", "effect": {"free_quota_miss": 1}},
	{"name": "Early Bird", "desc": "Start each day 2 hours earlier", "effect": {"early_bird_minutes": 120}},
	{"name": "Sunrise Spark", "desc": "Move faster for the first 60 seconds of each day", "effect": {"sunrise_spark_duration": 60.0, "sunrise_spark_bonus": 0.20}},
	{"name": "True Beaver", "desc": "50% chance to get extra wood from trees", "effect": {"extra_wood_chance": 0.5}},
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
	var pool = []
	for card in all_cards:
		if not global_stats.chosen_upgrades.has(card["name"]):
			pool.append(card)

	if pool.is_empty():
		print("All upgrades already chosen!")
		return []

	pool.shuffle()
	return Array(pool.slice(0, min(count, pool.size())), TYPE_DICTIONARY, "", null)

func _create_card(data: Dictionary) -> Control:
	#var rect = ColorRect.new()
	#rect.color = Color(0.15, 0.15, 0.15, 0.85)
	#rect.custom_minimum_size = Vector2(220, 280)
#
	#var vbox = VBoxContainer.new()
	#vbox.anchor_right = 1
	#vbox.anchor_bottom = 1
	#vbox.offset_left = 8
	#vbox.offset_top = 8
	#vbox.offset_right = -8
	#vbox.offset_bottom = -8
#
	#var name_label = Label.new()
	#name_label.text = data["name"]
	#name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#name_label.add_theme_font_size_override("font_size", 32)
#
	#var desc_label = Label.new()
	#desc_label.text = data["desc"]
	#desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	#desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	#desc_label.add_theme_font_size_override("font_size", 16)
#
	#var button = Button.new()
	#button.text = "Choose"
	#button.pressed.connect(func(): _apply_card(data))
#
	#vbox.add_child(name_label)
	#vbox.add_child(desc_label)
	#vbox.add_spacer(false)
	#vbox.add_child(button)
	#rect.add_child(vbox)
	
	var card: UpgradeCard = preload("res://art_assets/upgrade_card.png").instantiate()
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
