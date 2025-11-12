extends Node

const GlobalStatsScript = preload("res://global/global_stats.gd")
var global_stats: Node = null

# ----------CARD OPTIONS-----------------
@export var all_cards: Array[Dictionary] = [
	{"name": "Stronger Teeth", "desc": "Wood gathering +20%", "effect": {"wood_gather_rate": 0.2}},
	{"name": "Bigger Lungs", "desc": "Stamina +15", "effect": {"stamina": 15.0}},
	{"name": "Polished Dam", "desc": "Dam strength +0.3", "effect": {"dam_strength": 0.3}},
	{"name": "Streamline", "desc": "Movement speed +10", "effect": {"speed": 10.0}},
]

@onready var card_ui: CanvasLayer = $CardUI
@onready var card_container: HBoxContainer = $CardUI/CardContainer

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

func _process(_delta: float) -> void:
	# CHANGE THIS BASED ON WHEN WE WANT TO TRIGGER UPGRADES
	if Input.is_action_just_pressed("ui_accept") and not showing:
		show_three_cards()
	elif Input.is_action_just_pressed("ui_cancel") and showing:
		hide_cards()

func show_three_cards() -> void:
	showing = true
	card_ui.visible = true

	for child in card_container.get_children():
		child.queue_free()

	var selected_cards = _get_random_cards(3)
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
	var rect = ColorRect.new()
	rect.color = Color(0.15, 0.15, 0.15, 0.85)
	rect.custom_minimum_size = Vector2(220, 280)

	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.offset_left = 8
	vbox.offset_top = 8
	vbox.offset_right = -8
	vbox.offset_bottom = -8

	var name_label = Label.new()
	name_label.text = data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)

	var desc_label = Label.new()
	desc_label.text = data["desc"]
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 14)

	var button = Button.new()
	button.text = "Choose"
	button.pressed.connect(func(): _apply_card(data))

	vbox.add_child(name_label)
	vbox.add_child(desc_label)
	vbox.add_spacer(false)
	vbox.add_child(button)
	rect.add_child(vbox)

	return rect

func _apply_card(data: Dictionary) -> void:
	if global_stats:
		global_stats.apply_effect(data["effect"])
		if not global_stats.chosen_upgrades.has(data["name"]):
			global_stats.chosen_upgrades.append(data["name"])
	else:
		push_warning("GlobalStats not found!")
	hide_cards()
