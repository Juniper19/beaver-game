extends Area2D
const GlobalStatsScript = preload("res://global/global_stats.gd")

@onready var vbox: VBoxContainer = $BoardUI/PanelContainer/VBoxContainer


func _ready() -> void:
	vbox.anchor_right = 100
	vbox.anchor_bottom = 1
	vbox.offset_left = 8
	vbox.offset_top = 8
	vbox.offset_right = -8
	vbox.offset_bottom = -8
	$BoardUI.visible = false

func _process(delta: float) -> void:
	if get_overlapping_bodies().size() > 0:
		$InteractLabel.visible = true
	else:
		$InteractLabel.visible = false
		
	# CHANGE THIS BASED ON WHEN WE WANT TO TRIGGER UPGRADES
	if Input.is_action_just_pressed("ui_accept") and get_overlapping_bodies().size() > 0:
		show_quota()
	elif Input.is_action_just_pressed("ui_cancel") or get_overlapping_bodies().size() == 0:
		hide_quota()	
		
func show_quota():
	$BoardUI.visible = true
	
func hide_quota():
	$BoardUI.visible = false
