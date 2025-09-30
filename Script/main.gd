extends Node2D

func _process(_delta: float) -> void:
	autoClick()
	
func autoClick():
	var multiplicator = 0.5 if Global.current_dice.effect_type.has(Dice.EffectType.COSMIC) else 1.0
	for roller in Global.all_rollers.values():
		if roller.buyed > 0 and !has_node(roller.item_name):
			var new_timer = Timer.new()
			new_timer.wait_time = roller.rolling_frequence * multiplicator + Global.current_dice.roll_duration
			new_timer.one_shot = true
			new_timer.name = roller.item_name
			add_child(new_timer)
			
			new_timer.connect("timeout",self._on_roller_timer_timeout.bind(new_timer, roller))
			new_timer.start()

func _on_roller_timer_timeout(timer, roller):
	var new_score = 0
	
	if Global.current_dice.effect_type.has(Dice.EffectType.QUANTUM):
		@warning_ignore("integer_division")
		new_score += (Global.nbr_dice_face * (Global.nbr_dice_face + 1) / 2) * roller.buyed * Global.nbr_dice
	else:
		for i in range(roller.buyed * Global.nbr_dice):
			new_score += randi_range(1, Global.nbr_dice_face)
		
	$Hud.updateScore(roller.item_texture, new_score)
	timer.queue_free()

func _on_saving_timer_timeout() -> void:
	Global.saveGame()
	Global.saveHightScore()
