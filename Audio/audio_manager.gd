extends Node2D

@export var mute: bool = false
var drop: int =1
var dep: int =1
var depE: int =1
var wait: bool = false
var song = 1

func playItemPickUp():
	if not mute:
		$ItemPickUp.play()
		
func playQTESuccess():
	if not mute:
		var Random = randf_range(0,3)
		if Random < 1:
			$QTESuccess1.play()
		elif Random >= 1 and Random < 2:
			$QTESuccess2.play()
		elif Random >= 2:
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
		$DropTimer.start()
		if drop == 1:
			$Drop5.play()
		elif drop == 2:
			$Drop4.play()
		elif drop == 3:
			$Drop3.play()
		elif drop == 4:
			$Drop2.play()
		elif drop == 5:
			$Drop1.play()
			drop = 0
		drop += 1

func _on_drop_timer_timeout() -> void:
	drop = 1
	
	
func playDeposit():
	if not mute:
		$DepositTimer.start()
		if dep == 1:
			$Deposit1.play()
		elif dep == 2:
			$Deposit2.play()
		elif dep == 3:
			$Deposit3.play()
			dep = 0
		dep +=1

func _on_deposit_timer_timeout() -> void:
	dep = 1
	
	
func playDepositE():
	if not mute:
		$DepositETimer.start()
		if depE == 1:
			$DepositE1.play()
		elif depE == 2:
			$DepositE2.play()
		elif depE == 3:
			$DepositE3.play()
			depE = 0
		depE +=1

func _on_deposit_e_timer_timeout() -> void:
	depE = 1
	
func playFootsteps():
	if not mute and not wait:
		var Random = randf_range(0,4)
		if Random < 1:
			$Footstep1.play()
			wait = true
			$FootstepTimer.start()
		elif Random >= 1 and Random < 2:
			$Footstep2.play()
			wait = true
			$FootstepTimer.start()
		elif Random >= 2 and Random < 3:
			$Footstep3.play()
			wait = true
			$FootstepTimer.start()
		elif Random >= 3:
			$Footstep4.play()
			wait = true
			$FootstepTimer.start()
		

func _on_footstep_timer_timeout() -> void:
	wait = false
	
func playMusic1():
	if not mute:
		if song == 1:
			$Music1.play()
		elif song == 2:
			$Music2.play()
		song +=1
		if song == 3:
			song = 1
		
		
func stopMusic1():
	$Music1.stop()

func playInsideMusic():
	if not mute:
		$InsideMusic.play()
		$InsideMusic.finished.connect($InsideMusic.play)
		
func stopAllMusic():
	$Music1.stop()
	$Music2.stop()
	$InsideMusic.stop()
	
func stopOverworldMusic():
	$Music1.stop()
	$Music2.stop()
		
func stopInsideMusic():
	$InsideMusic.stop()
	
func playJackhammer():
	if not mute:
		$Jackhammer.play()

func stopJackhammer():
	$Jackhammer.stop()
	
func playChainsaw():
	if not mute:
		$Chainsaw.play()

func stopChainsaw():
	$Chainsaw.stop()
	
func playMudScoop():
	if not mute:
		$MudScoop.play()

func playSleep():
	if not mute:
		$Sleep.play()
		
func playEnterDam():
	if not mute:
		$EnterDam.play()
