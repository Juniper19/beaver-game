extends Node2D

@export var mute: bool = false
var drop: int =1
var dep: int =1

func playItemPickUp():
	if not mute:
		$ItemPickUp.play()
		
func playQTESuccess():
	if not mute:
		var Random = randf_range(0,3)
		if Random < 1:
			$QTESuccess1.play()
		elif Random > 1 and Random < 2:
			$QTESuccess2.play()
		elif Random > 2:
			$QTESuccess3.play()
			
func playMenuSound():
	if not mute:
		$MenuSound.play()
		
func playRockHit(damage):
	if not mute:
		if damage < 0.5:
			$RockHit.volume_db = -3.0
		elif damage > 0.5 and damage >= 0.75:
			$RockHit.volume_db = 2.0
		elif damage > 0.75 and damage >= 0.9:
			$RockHit.volume_db = 7.0
		elif damage > 0.9:
			$RockHit.volume_db = 20.0
		$RockHit.play()
		
func playWoodHit():
	if not mute:
		$WoodHit.play()
		
func playSwing():
	if not mute:
		$Swing.play()
		
func playQuotaMet():
	if not mute:
		$QuotaMet.play()
	
func playDrop():
	if not mute:
		print(drop)
		$DropTimer.start()
		if drop == 1:
			$Drop1.play()
		elif drop == 2:
			$Drop2.play()
		elif drop == 3:
			$Drop3.play()
		elif drop == 4:
			$Drop4.play()
		elif drop == 5:
			$Drop5.play()
			drop = 0
		drop += 1

func _on_drop_timer_timeout() -> void:
	drop = 1
	
	
func playDeposit():
	if not mute:
		if dep == 1:
			$Deposit1.play()
		elif dep == 2:
			$Deposit2.play()
		elif dep == 3:
			$Deposit3.play()
			dep = 0
		dep +=1
