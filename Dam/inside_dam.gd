extends Node2D

var has_slept: bool = false


func _ready():
	AudioManager.playInsideMusic()



func _on_bed_player_entered_area(_player):
	_transition_node_alpha($SleepText, 1.0)




func _on_bed_player_left_area(_player):
	_transition_node_alpha($SleepText, 0.0)

func _transition_node_alpha(node: CanvasItem, alpha: float):
	var t: Tween = get_tree().create_tween()
	t.tween_property(node, "modulate:a", alpha, 0.2)

func _on_bed_interaction(_by):
	
	%Player.process_mode = Node.PROCESS_MODE_DISABLED
	_transition_node_alpha($SleepText, 0.0)
	
	$Bed.queue_free() # no more interaction!!
	$UpgradeManager.show_three_cards()


func _on_upgrade_selected():
	AudioManager.playSleep()
	#%Player.process_mode = Node.PROCESS_MODE_INHERIT
	$AnimationPlayer.play("sleep")
	get_node("/root/GlobalStats").calendar_day += 1
	AudioManager.playPageTurn()
	$Door.process_mode = Node.PROCESS_MODE_INHERIT
